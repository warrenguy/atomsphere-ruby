require 'net/https'
require 'uri'
require 'json'
require 'rotp'

module Atomsphere
  module Api
    class Client
      def initialize
        validate!
      end

      def post path, data
        header = {
          'Content-Type' => 'application/json',
          'Accept'       => ' application/json'
        }

        request = Net::HTTP::Post.new api_uri(path), header
        request.body = (String === data ? data : data.to_json)
        request.basic_auth config.username, config.password

        http_request request
      end

      def get path
        header = {'Accept' => 'application/json'}

        request = Net::HTTP::Get.new api_uri(path), header
        request.basic_auth config.username, config.password

        http_request request
      end

      def bulk_get path, ids
        request = { type: 'GET', request: ids.map{ |id| {id: id} } }
        path = [*path] << :bulk
        post path, request
      end

      %w(query create update execute).each do |v|
        define_method :"#{v}" do |path, data|
          [*path] << v
          post path, data
        end
      end

      private
      def validate!
        raise ArgumentError, "Atomsphere not configured" if config.nil?

        required_vars = Atomsphere::Configuration::REQUIRED
        if (missing_vars = required_vars.select{ |v| config.send(v).nil? }).size > 0
          raise ArgumentError, "Atomsphere configuration incomplete," +
            " required vars missing: #{missing_vars.join('; ')}"
        end
      end

      def config
        @config ||= Atomsphere.configuration
      end

      def totp
        ROTP::TOTP.new(config.otp_secret) if config.otp_secret
      end

      def generate_otp
        totp.now
      end

      def api_uri path=nil
        URI.parse config.base_uri + 
          config.account_id + 
          '/' + (Array === path ? path.join('/') : path.to_s)
      end

      def http
        h = Net::HTTP.new api_uri.host, api_uri.port
        h.use_ssl = true

        h
      end

      def http_request request
        request['X-Boomi-OTP'] = generate_otp if config.otp_secret

        begin
          response = Response.new(request, http.request(request))
        rescue => e
          raise ApiError.new(request, response)
        else
          raise ApiError.new(
            request,
            response,
            e,
            'response code was nil'
          ) if response.code.nil?

          if response.code >= 400
            begin
              json = JSON.parse(response.response.body)
              if json['@type'].downcase.eql?('error')
                 message = json['message']
              end
            rescue JSON::ParserError
            ensure
              message ||= "API responded with error #{response.code}: #{response.message}"
            end

            raise ApiError.new(
              request,
              response,
              e,
              message
            )
          end
        end

        response
      end
    end

    class ApiError < StandardError
      attr_reader :request, :response, :original, :message

      def initialize(request, response, original=nil, message=nil)
        @request  = request
        @response = response
        @original = original
        @message  = message

        super(message)
      end
    end
  end
end
