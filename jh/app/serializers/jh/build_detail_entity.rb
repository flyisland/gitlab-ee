# frozen_string_literal: true

module JH
  module BuildDetailEntity
    extend ActiveSupport::Concern

    prepended do
      expose :update_tags_path,
        if: ->(*) {
          build.pending? && build.runner_id.nil? &&
            ::Ci::UpdateJobTagsService.permitted?(build, current_user: current_user)
        } do |build|
        update_tags_project_job_path(project, build)
      end
    end
  end
end
