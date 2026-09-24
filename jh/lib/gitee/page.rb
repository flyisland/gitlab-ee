# frozen_string_literal: true

module Gitee
  class Page
    attr_reader :response, :items, :current_page, :type

    def initialize(response, type, current_page)
      @response = response
      @type = type
      @items = parse_values(response)
      @current_page = current_page
    end

    def has_next_page?
      total_page.present? && (total_page.to_i > current_page)
    end

    private

    def total_page
      response.headers['total_page']
    end

    def parse_values(response)
      body = ::Gitlab::Json.parse(response.body)
      return [] unless body && body.is_a?(Array)

      representation_class(type).decorate(body)
    end

    def representation_class(type)
      Gitee::Representation.const_get(type.to_s.camelize, false)
    end
  end
end
