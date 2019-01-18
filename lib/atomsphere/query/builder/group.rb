module Atomsphere
  class Query
    class Builder
      class Group
        def initialize expression
          @expression = expression
        end

        def group operator, &block
          new_group = GroupingExpression.new(operator)
          Group.new(new_group).instance_eval(&block)
          @expression.nested_expression << new_group
        end

        def method_missing m, *args, &block
          __property(@expression, m)
        end

        private
        def __property(expression, property)
          Property.new(expression, property)
        end
      end
    end
  end
end
