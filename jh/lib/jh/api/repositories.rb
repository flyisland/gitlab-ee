# frozen_string_literal: true

module JH
  module API
    module Repositories
      extend ActiveSupport::Concern
      prepended do
        params do
          requires :id, type: String, desc: 'The ID of a project'
        end
        resource :projects, requirements: ::API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
          desc 'Get a project repository tree content blocked state' do
            success ::API::Entities::ContentBlockedState
          end
          params do
            optional :ref, type: String, desc: 'The name of a repository branch or tag'
            optional :path, type: String, desc: 'The path of the tree'
          end
          get ':id/repository/tree/content_blocked_state' do
            break no_content! unless ::ContentValidation::Setting.block_enabled?(user_project)

            ref = declared_params[:ref] || user_project.default_branch
            commit = user_project.commit(ref)
            path = declared_params[:path]

            not_found!("Tree") unless commit

            tree = user_project.repository.tree(commit.id, path)

            not_found!("Tree") unless tree

            content_blocked_state = ::ContentValidation::ContentBlockedState.find_by_container_commit_path(
              user_project,
              commit.id,
              path)

            present content_blocked_state, with: ::API::Entities::ContentBlockedState
          end
        end
      end
    end
  end
end
