# frozen_string_literal: true

module JH
  module Ai
    module DuoWorkflows
      module StartWorkflowService
        extend ::Gitlab::Utils::Override

        JH_IMAGE_PATH = 'registry.jihulab.com/gitlab-cn/modelops/duo-workflow/default-docker-image/' \
          'workflow-generic-image'

        private

        override :instance_image
        def instance_image
          return super unless ::Gitlab.jh?

          path = ENV['JH_WORKFLOW_IMAGE_PATH'].presence || JH_IMAGE_PATH
          instance_image_version = ::Ai::DuoWorkflows::StartWorkflowService::IMAGE_PATH.split(':').last

          "#{path}:#{instance_image_version}"
        end
      end
    end
  end
end
