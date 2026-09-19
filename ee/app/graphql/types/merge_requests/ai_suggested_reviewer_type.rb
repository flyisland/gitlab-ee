# frozen_string_literal: true

module Types
  module MergeRequests
    class AiSuggestedReviewerType < BaseObject
      graphql_name 'AiSuggestedReviewer'
      description 'AI-recommended reviewer for a merge request.'
      authorize :read_user
      authorize_granular_token permissions: :read_merge_request, boundary: :project, boundary_type: :project

      field :id, GraphQL::Types::ID,
        null: false,
        description: 'ID of the suggested reviewer.'

      field :user, ::Types::UserType,
        null: true,
        description: 'User recommended as a reviewer.'

      field :reason, GraphQL::Types::String,
        null: true,
        description: 'Model rationale for recommending the user.'

      field :created_at, ::Types::TimeType,
        null: false,
        description: 'Timestamp of when the suggestion was created.'

      field :approval_rule, ::Types::ApprovalRuleType,
        null: true,
        description: 'Approval rule the user was suggested as a reviewer for.'

      def approval_rule
        rule = object.approval_rule
        return unless rule

        ApprovalWrappedRule.wrap(object.merge_request, rule)
      end
    end
  end
end
