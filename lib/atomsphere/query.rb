module Atomsphere
  class Query
    attr_accessor :object_type, :filter
    attr_reader   :query_token, :result_pages, :page

    def initialize object_type=nil
      @object_type ||= object_type
      @page = 0
      @result_pages = []
      @filter = GroupingExpression.new
    end

    def validate!
      private_methods.select{ |m| m =~ /^validate_[a-z0-9_]+\!$/ }.each{ |v| send(v) }
      filter.validate!

      true
    end

    def run
      next_page
    end
    
    def results
      result_pages.map(&:to_hash).map{ |h| h['result'] }.map(&:compact).flatten(1)
    end

    def all_results
      next_page until last_page?
      results
    end

    def last_page?
      !page.eql?(0) && query_token.nil?
    end

    def next_page
      return false if last_page?

      begin
        response = if query_token.nil?
          @page = 1
          api_client.post([object_type, :query], to_hash)
        else
          api_client.post([object_type, :queryMore], query_token)
        end
      rescue => e
        @page -= 1
        raise e
      end

      result_pages[page-1] = response
    end

    def to_hash
      validate!

      { QueryFilter: filter.to_hash }
    end

    def to_json
      JSON.pretty_generate to_hash
    end

    private
    def validate_object_type!
      raise ArgumentError, "object_type is required" if @object_type.nil?
    end

    def validate_filter!
      unless filter.is_a? GroupingExpression
        raise ArgumentError, 'filter must be a GroupingExpression'
      end
    end

    def api_client
      Api::Client.new
    end

    def query_token
      if result_pages.last.nil? || !result_pages.last.to_hash.keys.include?('queryToken')
        nil
      else
        result_pages.last.to_hash['queryToken']
      end
    end
  end

  %w(grouping_expression simple_expression).each{ |m| require "#{ROOT}/query/#{m}" }
end
