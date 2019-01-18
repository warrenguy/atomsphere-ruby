require 'json'

module Atomsphere
  class Query
    class GroupingExpression
      attr_accessor :operator, :nested_expression

      OPERATORS = :and, :or

      def initialize(params={})
        params = {
          operator: :and,
          nested_expression: []
        }.merge(params)

        @operator = params[:operator]
        @nested_expression = params[:nested_expression]
      end

      def validate!
        private_methods.select{ |m| m =~ /^validate_[a-z0-9_]+\!$/ }.each{ |v| "#{v}"; send(v) }
        @nested_expression.each(&:validate!)

        true
      end

      def to_hash
        {
          expression: {
            operator: operator.to_s,
            nestedExpression: nested_expression.
              map(&:to_hash).
              map{ |h| h[:expression] }
          }
        }
      end

      def to_json
        JSON.pretty_generate to_hash
      end

      private
      def validate_operators!
        unless OPERATORS.include? @operator
          raise ArgumentError, "operator must be one of #{OPERATORS.join(', ')}"
        end
      end

      def validate_expressions!
        raise ArgumentError, "nested_expression must be an array" unless @nested_expression.is_a?(Array)

        not_expressions = @nested_expression.map(&:class).reject do |k|
          [GroupingExpression, SimpleExpression].include? k
        end

        if not_expressions.size > 0
          raise ArgumentError,
            "invalid expression class(es): #{not_expressions.map(&:class).join(', ')}"
        end
      end

      def validate_expressions_size!
        raise ArgumentError, "at least one expression required" if (@nested_expression.size < 1)
      end
    end
  end
end
