require 'json'

module Atomsphere
  class Query

    # @see GroupingExpression
    # @see SimpleExpression
    class Expression
    end
  end

  Dir["#{ROOT}/query/expression/*.rb"].each{ |f| require f }
end
