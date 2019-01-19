module Atomsphere
  class Query

    # DSL for onstructing an {Atomsphere::Query}
    # @see Atomsphere#query
    # @attr_reader [Atomsphere::Query] query output query object
    class Builder
      attr_reader :query

      def initialize(object_type)
        @query = object_type.nil? ? Query.new : Query.new(object_type)
      end

      # Define a {GroupingExpression} at the top level of the query. If called
      # more than once, subsequent calls create a grouping expression within
      # the first created {GroupingExpression}.
      def group operator, &block
        new_group = GroupingExpression.new(operator)
        Group.new(new_group).instance_eval(&block)

        if @query.filter
          @query.filter.nested_expression << new_group
        else
          @query.filter = new_group
        end
      end

      # Allows for defining of {SimpleExpression}s at the top level of the
      # query. Creates a top level {GroupingExpression} if none yet exists
      # to contain it.
      def method_missing m, *args, &block
        @query.filter = GroupingExpression.new(:and) unless @query.filter
        Group.new(@query.filter).instance_eval do
          send(m, *args, &block)
        end
      end
    end
  end

  # Invoke the DSL for constructing an {Atomsphere::Query}
  #
  # @example without an expression, returns all possible results
  #   Atomsphere.query('Process')
  #
  # @example a simple query expression for online Atoms
  #   Atomsphere.query('Atom') { status.equals :online }
  #
  # @example a query expression for online cloud Atoms (implied `and` group)
  #   Atomsphere.query('Atom') do
  #     status.equals :online
  #     type.equals :cloud
  #   end
  #
  # @example a more complex example with nested group expressions
  #   Atomsphere.query('Atom') do
  #     group :or do
  #       date_installed.less_than '2018-12-01T00:00:00Z'
  #       group :and do
  #         status.not_equals :online
  #         type.not_equals :cloud
  #       end
  #     end
  #   end
  def self.query(object_type=nil, &block)
    q = Query::Builder.new(object_type)
    q.instance_eval(&block) if block_given?

    q.query
  end

  require "#{ROOT}/query/builder/property"
  require "#{ROOT}/query/builder/group"
end
