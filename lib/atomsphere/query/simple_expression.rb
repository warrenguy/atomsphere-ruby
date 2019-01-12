require 'json'

module Atomsphere
  class Query
    class SimpleExpression
      attr_accessor :operator, :property, :argument

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

      def validate!
        methods.select{ |m| m =~ /^validate_[a-z0-9_]\!$/ }.each{ |v| send(v) }
        true
      end

      def to_hash
        {
          expression: {
            operator: operator.upcase,
            property: property,
            argument: [*argument]
          }
        }
      end

      def to_json
        to_hash.to_json
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
        unless argument.is_a?(Array) && argument.size.eql?(OPERATORS[operator])
          raise ArgumentError, "'#{operator}' expects #{OPERATORS[operator]} argument(s)"
        end
      end
    end
  end
end
