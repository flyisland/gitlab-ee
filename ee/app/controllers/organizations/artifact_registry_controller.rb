# frozen_string_literal: true

module Organizations
  class ArtifactRegistryController < ApplicationController
    include ArtifactRegistryGating

    feature_category :artifact_registry

    def index; end
  end
end
