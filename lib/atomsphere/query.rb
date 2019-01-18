module Atomsphere

  # @attr         [String]               object_type   name of the object to query
  # @attr         [GroupingExpression]   filter        top level {GroupingExpression} for query
  # @attr_reader  [Integer]              page          the number of pages retrieved
  # @attr_reader  [Array<Api::Response>] result_pages  array of api responses for each page retrieved
  class Query
    attr_accessor :object_type, :filter
    attr_reader   :query_token, :result_pages, :page

    # accepts either a string of the name of the object to query, or a hash of options
    # @param          [String] params       name of the object to query
    # @param          [Hash]   params       parameters to initialize query with
    # @option params  [String]              :object_type  name of the object to query
    # @option params  [GroupingExpression]  :filter       top level {GroupingExpression}
    def initialize(params={})
      case params
      when String
        params = {object_type: params}
      end

      params = {
        object_type: nil,
        page: 0,
        result_pages: [],
        filter: GroupingExpression.new
      }.merge(Hash[params.select{|k,v| [:object_type, :filter].include? k}])

      %w(object_type page result_pages filter).each do |v|
        instance_variable_set :"@#{v}", params[v.to_sym]
      end

      self
    end

    # run all `validate_*!` private methods to ensure validity of query parameters
    # @return [true, false]
    def validate!
      private_methods.select{ |m| m =~ /^validate_[a-z0-9_]+\!$/ }.each{ |v| send(v) }
      filter.validate!

      true
    end

    # @see #next_page
    def run
      next_page
    end

    # returns rows from {#result_pages} that have been retrieved
    # @return [Array<Hash>] Array of returned rows as hashes
    def results
      result_pages.map(&:to_hash).map{ |h| h['result'] }.map(&:compact).flatten(1)
    end

    # runs {#next_page} to retrieve all {#result_pages} until {#last_page?} is `false`,
    # and then returns all rows
    # @return [Array<Hash>] Array of returned rows as hashes
    def all_results
      next_page until last_page?
      results
    end

    # returns `true` when any pages have been retrieved the value of {#query_token} is `nil`
    # @return [true, false]
    def last_page?
      !page.eql?(0) && query_token.nil?
    end

    # retrieve the next page for the query
    # @return [Api::Response, false] returns the response, or `false` if {#last_page?} is `true`
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

    # validates all parameters with {#validate!} and returns a hash of the query
    # that will be sent to the boomi api
    # @see #to_json
    # @return [Hash] hash representation of query that will be sent to the boomi api
    def to_hash
      validate!

      { QueryFilter: filter.to_hash }
    end

    # query json that will be sent to the boomi api
    # @see #to_hash
    # @return [String] JSON query string
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

    # an instance of the API client
    # @return [Api::Client]
    def api_client
      Api::Client.new
    end

    # if any pages have been retrieved, the value of `queryToken` from the
    # last response
    # @return [String, nil] value of `queryToken`, or `nil`
    def query_token
      if result_pages.last.nil? || !result_pages.last.to_hash.keys.include?('queryToken')
        nil
      else
        result_pages.last.to_hash['queryToken']
      end
    end
  end

  require "#{ROOT}/query/builder"
  require "#{ROOT}/query/expression"
end
