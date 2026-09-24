# frozen_string_literal: true

FactoryBot.define do
  factory :content_blocked_state, class: 'ContentValidation::ContentBlockedState' do
    commit_sha { RepoHelpers.sample_commit.id }
    blob_sha { RepoHelpers.sample_blob.oid }
    path { RepoHelpers.sample_blob.path }
    container_identifier { "project-xxx" }

    transient do
      container { nil }
    end

    after(:build) do |content_blocked_state, evaluator|
      if evaluator.container
        repo_type =
          case evaluator.container
          when Project
            ::Gitlab::GlRepository::PROJECT
          when Wiki
            ::Gitlab::GlRepository::WIKI
          when Snippet
            ::Gitlab::GlRepository::SNIPPET
          end

        content_blocked_state.container_identifier = repo_type.identifier_for_container(evaluator.container)
      end
    end
  end
end
