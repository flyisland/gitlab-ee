# frozen_string_literal: true

module ArtifactRegistry
  class UpstreamRepositorySummary
    attr_reader :permissions

    def initialize(attributes = {}, permissions = nil)
      @attributes = attributes || {}
      @permissions = permissions
    end

    def id
      @attributes['id']
    end

    def name
      @attributes['name']
    end

    def format
      @attributes['format']
    end

    def kind
      @attributes['kind']
    end

    def visibility
      @attributes['visibility']
    end

    def size_bytes
      @attributes['size_bytes']
    end

    def settings
      settings = @attributes['settings']

      settings.is_a?(Hash) ? settings.presence : nil
    end
  end
end
