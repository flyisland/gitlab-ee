# frozen_string_literal: true

module Gitee
  class Paginator
    PAGE_LENGTH = 50 # The minimum length is 10 and the maximum is 100.

    def initialize(connection, url, type, options)
      @connection = connection
      @type = type
      @url = url
      @page = nil
      @options = options
    end

    def items
      raise StopIteration unless has_next_page?

      @page = fetch_next_page
      @page.items
    end

    private

    attr_reader :connection, :page, :url, :type, :current_page

    def has_next_page?
      page.nil? || page.has_next_page?
    end

    def next_page
      page.nil? ? 1 : page.current_page + 1
    end

    def fetch_next_page
      response = connection.get(url, @options.merge(page: next_page, per_page: PAGE_LENGTH))
      Page.new(response, type, next_page)
    end
  end
end
