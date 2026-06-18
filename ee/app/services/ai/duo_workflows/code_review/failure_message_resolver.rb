# frozen_string_literal: true

module Ai
  module DuoWorkflows
    module CodeReview
      class FailureMessageResolver
        KNOWN_FAILURE_MESSAGES = {
          flow_not_enabled: ->(_user) {
            ::Ai::CodeReviewMessages.foundational_flow_not_enabled_error
          },
          invalid_service_account: ->(_user) {
            ::Ai::CodeReviewMessages.missing_service_account_error
          },
          usage_quota_exceeded: ->(_user) {
            ::Ai::CodeReviewMessages.usage_quota_exceeded_error
          },
          namespace_missing: ->(user) {
            ::Ai::CodeReviewMessages.namespace_missing_error(user)
          },
          cannot_create_workflow_pipeline: ->(user) {
            ::Ai::CodeReviewMessages.insufficient_workload_permissions_error(user)
          },
          workload_failure: ->(_user) {
            ::Ai::CodeReviewMessages.workload_creation_error
          },
          workflow_workload_failure: ->(_user) {
            ::Ai::CodeReviewMessages.workload_creation_error
          },
          feature_unavailable: ->(_user) {
            ::Ai::CodeReviewMessages.feature_unavailable_error
          },
          invalid_duo_workflow_token: ->(_user) {
            ::Ai::CodeReviewMessages.invalid_token_error
          },
          invalid_oauth_token: ->(_user) {
            ::Ai::CodeReviewMessages.invalid_token_error
          },
          source_ref_not_found: ->(_user) {
            ::Ai::CodeReviewMessages.source_ref_not_found_error
          }
        }.freeze

        DEFAULT_FAILURE_MESSAGE = ->(_user) {
          ::Ai::CodeReviewMessages.could_not_start_workflow_error
        }

        def initialize(user:)
          @user = user
        end

        def resolve(reason)
          KNOWN_FAILURE_MESSAGES.fetch(reason, DEFAULT_FAILURE_MESSAGE).call(user)
        end

        def known_reason?(reason)
          KNOWN_FAILURE_MESSAGES.key?(reason)
        end

        private

        attr_reader :user
      end
    end
  end
end
