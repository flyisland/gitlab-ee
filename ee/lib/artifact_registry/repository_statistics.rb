# frozen_string_literal: true

module ArtifactRegistry
  class RepositoryStatistics
    def initialize(attributes = {})
      @attributes = attributes || {}
    end

    def packages_count
      @attributes['packages_count']
    end

    def images_count
      @attributes['images_count']
    end
  end
end
