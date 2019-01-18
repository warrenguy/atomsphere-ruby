require 'json'

module Atomsphere
  module Api
    class Response
      attr_reader :request, :code, :response, :message

      def initialize(request, response)
        @request  = request
        @response = response
        @code     = response.nil? ? nil : response.code.to_i
        @message  = response.nil? ? nil : response.message
      end

      def to_hash
        begin
          JSON.parse @response.body
        rescue JSON::ParserError
          @response.body
        end if @response
      end
    end
  end
end
