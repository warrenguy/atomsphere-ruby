require 'facets/string/camelcase'
require 'facets/string/snakecase'

module Atomsphere
  module Action
    module ClassMethods
      def self.included base
      end

      def initialize params={}
        set_params params
        validate!
      end

      def fields
        %w(required one_of optional).map do |m|
          self.class.class_variable_get :"@@#{m}"
        end.flatten
      end

      def run
        @api_response ||= api_client.send(*[
          api_method,
          action,
          api_method.eql?(:get) ? nil : request
        ].compact)

        @response ||= @api_response.to_hash
        self
      end

      private
      %w(required one_of optional).each do |m|
        define_method(:"#{m}") { self.class.class_variable_get(:"@@#{m}") }
      end

      def action
        if self.class.class_variable_defined? :@@action
          self.class.class_variable_get :@@action
        else
          self.class.name.split('::').last.lower_camelcase
        end
      end

      def api_method
        if self.class.class_variable_defined? :@@api_method
          self.class.class_variable_get :@@api_method
        else
          :post
        end
      end
      
      def set_params params
        fields.each{ |f| send(:"#{f}=", params[f]) }
      end

      def api_client
        Api::Client.new
      end

      def validate!
        required.each do |f|
          raise ArgumentError, "#{f} is required" unless send(:"#{f}")
        end

        one_of.each do |fs|
          unless fs.map{ |f| send(:"#{f}") }.compact.size == 1
            raise ArgumentError, "requires one of: #{fs.join(', ')}"
          end
        end
      end
    end

    module InstanceMethods
      def self.extended base
        %w(required one_of optional).each do |m|
          base.class_variable_set :"@@#{m}", []
        end

        method_name = base.name.split('::').last.snakecase
        Atomsphere.define_singleton_method(method_name) do |*params|
          base.new(*params).run
        end
      end

      def action a
        class_variable_set :@@action, a
      end

      def api_method m
        class_variable_set :@@api_method, m
      end

      def required *params
        params.each do |param|
          class_variable_get(:@@required) << param
          attr_accessor param
        end
      end

      def optional *params
        params.each do |param|
          class_variable_get(:@@optional) << param
          attr_accessor param
        end
      end

      def one_of *params
        if params.size < 2
          raise ArgumentError, "one_of requires two or more parameters"
        end

        class_variable_get(:@@one_of) << [*params]
        params.each{ |param| attr_accessor param }
      end
    end

    class Action
      def self.inherited(other)
        other.extend InstanceMethods
        other.include ClassMethods
      end

      attr_reader :api_response, :response
    end
  end
end

Dir["#{Atomsphere::ROOT}/action/*.rb"].each{ |f| require f }
