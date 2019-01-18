require 'json'

module Atomsphere
  class Query

    # @see http://help.boomi.com/atomsphere/GUID-4CAE5616-76EB-4C58-B2E3-4173B65EA7EC.html
    class GroupingExpression < Expression
      attr_accessor :operator, :nested_expression

      # allowed values for {#operator=}
      OPERATORS = :and, :or

      # @param [Hash] params
      # @option params [:and, :or] :operator query operator
      # @option params [Array<Expression>] :nested_expression one or more {Expression}s
      def initialize(params={})
        params = {
          operator: :and,
          nested_expression: []
        }.merge(params)

        @operator = params[:operator]
        @nested_expression = params[:nested_expression]
      end

      def operator= arg
        unless OPERATORS.include? arg.to_sym
          raise ArgumentError, "operator must be one of: #{OPERATORS.join(', ')}"
        end

        instance_variable_set :@operator, arg.to_sym
      end

      # run all `validate_*!` private methods to ensure validity of expression parameters
      # @return [true, false]
      def validate!
        private_methods.select{ |m| m =~ /^validate_[a-z0-9_]+\!$/ }.each{ |v| "#{v}"; send(v) }
        @nested_expression.each(&:validate!)

        true
      end

      # returns a hash of the expression that will be sent to the boomi api with {Query#to_hash}
      # @see #to_json
      # @return [Hash] hash representation of query that will be sent to the boomi api
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

      private
      def validate_operators!
        unless OPERATORS.include? @operator
          raise ArgumentError, "operator must be one of #{OPERATORS.join(', ')}"
        end
      end

      def validate_expressions!
        raise ArgumentError, "nested_expression must be an array" unless @nested_expression.is_a?(Array)

        not_expressions = @nested_expression.map(&:class).map(&:ancestors).reject do |k|
          k.include? Atomsphere::Query::Expression
        end

        if not_expressions.size > 0
          raise ArgumentError,
            "Expressions must be an object of a subclass of Atomsphere::Query::Expression"
        end
      end

      def validate_expressions_size!
        raise ArgumentError, "at least one expression required" if (@nested_expression.size < 1)
      end
    end
  end
end
