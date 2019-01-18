module Atomsphere
  class Query
    class Builder
      class Property
        def initialize(expression, property)
          @expression = expression
          @property = property
        end

        def method_missing m, *args, &block
          __operator(m, *args) if SimpleExpression::OPERATORS.keys.include? m
        end

        private
        def __operator(operator, *args)
          @expression.nested_expression << SimpleExpression.new(
            property: @property,
            operator: operator,
            argument: args
          )
        end
      end
    end
  end
end
