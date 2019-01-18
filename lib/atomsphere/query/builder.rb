module Atomsphere
  class Query
    class Builder
      attr_reader :query

      def initialize(object_type)
        @query = object_type.nil? ? Query.new : Query.new(object_type)
      end

      def group operator, &block
        new_group = GroupingExpression.new(operator)
        Group.new(new_group).instance_eval(&block)

        if @query.filter
          @query.filter.nested_expression << new_group
        else
          @query.filter = new_group
        end
      end

      def method_missing m, *args, &block
        @query.filter = GroupingExpression.new(:and) unless @query.filter
        Group.new(@query.filter).instance_eval do
          send(m, *args, &block)
        end
      end
    end
  end

  def self.query(object_type=nil, &block)
    q = Query::Builder.new(object_type)
    q.instance_eval(&block) if block_given?

    q.query
  end

  require "#{ROOT}/query/builder/property"
  require "#{ROOT}/query/builder/group"
end
