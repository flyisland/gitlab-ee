# frozen_string_literal: true

module JH
  module Projects
    module MergeRequestsController
      extend ActiveSupport::Concern

      prepended do
        before_action :ensure_monorepo!, only: [:bulk_merge]
        before_action :assign_variables_to_gon, only: [:show]

        def bulk_merge
          monorepo_service.bulk_merge!(current_user)
          render json: { status: :success }
        rescue ::MergeRequests::MonorepoService::ObtainLeaseError,
          ::MergeRequests::MonorepoService::BulkMergeError,
          ::Gitlab::Access::AccessDeniedError => err
          render json: { status: :failed, merge_error: err.message }
        end

        private

        def monorepo_service
          @monorepo_service ||= ::MergeRequests::MonorepoService.new(
            @merge_request.project.root_ancestor,
            @merge_request.topic_label_name
          )
        end

        def ensure_monorepo!
          access_denied! unless ::MergeRequests::MonorepoService.monorepo_enabled?(@merge_request)
        end

        def assign_variables_to_gon
          gon.push(jh_monorepo_enabled: ::MergeRequests::MonorepoService.monorepo_enabled?(@merge_request))
        end
      end
    end
  end
end
