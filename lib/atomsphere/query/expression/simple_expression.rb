require 'json'

module Atomsphere
  class Query

    # @see http://help.boomi.com/atomsphere/GUID-4CAE5616-76EB-4C58-B2E3-4173B65EA7EC.html
    class SimpleExpression < Expression
      attr_accessor :operator, :property, :argument

      # allowed values for {#operator=}
      OPERATORS = {
        equals:       1,
        like:         1,
        not_equals:   1,
        is_null:      0,
        is_not_null:  0,
        starts_with:  1,
        between:      2,
        greater_than: 1,
        less_than:    1,
        greater_than_or_equal: 1,
        less_than_or_equal: 1
      }

      # @param [Hash] params
      # @option params [String] :property the property/field to query
      # @option params [:equals,:like,:not_equals,:is_null,:is_not_null,:starts_with,:between,:greater_than,:less_than,:greater_than_or_equal,:less_than_or_equal] :operator query operator
      # @option params [Array] :argument array containing the number of arguments specified in the {OPERATORS} constant, as arguments to the query {#operator}
      def initialize(params={})
        params = {
          operator: :equals,
          property: nil,
          argument: []
        }.merge(params)

        %w(operator property argument).each do |v|
          send :"#{v}=", params[v.to_sym]
        end
      end

      def property= arg
        instance_variable_set :@property,
          case arg
          when String
            arg
          when Symbol
            arg.to_s.lower_camelcase
          end
      end

      def argument= arg
        instance_variable_set :@argument, arg.map(&:to_s)
      end

      # run all `validate_*!` private methods to ensure validity of expression parameters
      # @return [true, false]
      def validate!
        private_methods.select{ |m| m =~ /^validate_[a-z0-9_]+\!$/ }.each{ |v| send(v) }
        true
      end

      # returns a hash of the expression that will be sent to the boomi api with {Query#to_hash}
      # @see #to_json
      # @return [Hash] hash representation of query that will be sent to the boomi api
      def to_hash
        {
          expression: {
            operator: operator.to_s.upcase,
            property: property.to_s,
            argument: [*argument].map(&:to_s)
          }
        }
      end

      def operator= arg
        unless OPERATORS.keys.include? arg.to_sym
          raise ArgumentError, "operator must be one of: #{OPERATORS.keys.join(', ')}"
        end

        instance_variable_set :@operator, arg.to_sym
      end

      private
      def validate_operator!
        unless OPERATORS.include? operator
          raise ArgumentError, "operator must be one of #{OPERATORS.join(', ')}"
        end
      end

      def validate_property!
        raise ArgumentError, "property must be specified" unless @property
      end

      def validate_argument!
        unless [*argument].size.eql?(OPERATORS[operator])
          raise ArgumentError, "'#{operator}' expects #{OPERATORS[operator]} argument(s)"
        end
      end
    end
  end
end
