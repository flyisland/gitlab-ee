# frozen_string_literal: true

module API
  module Entities
    class ContentBlockedState < Grape::Entity
      expose :id
      expose :commit_sha
      expose :blob_sha
      expose :path
      expose :container_identifier
      expose :project_full_path
    end
  end
end
