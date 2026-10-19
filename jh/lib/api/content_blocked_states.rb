# frozen_string_literal: true

module API
  class ContentBlockedStates < ::API::Base
    feature_category :not_owned

    resource :content_blocked_states do
      desc 'Create content blocked state' do
        success ::API::Entities::ContentBlockedState
      end
      params do
        requires :commit_sha, type: String, desc: 'The commit sha'
        requires :blob_sha, type: String, desc: 'The blob sha'
        requires :path, type: String, desc: "The blob file path"
        requires :container_identifier, type: String, desc: "The project container identifier"
      end
      post do
        authenticated_as_admin!

        state_params = declared_params.slice(:commit_sha, :blob_sha, :path, :container_identifier)

        container, _, _ = Gitlab::GlRepository.parse(state_params[:container_identifier])

        content_blocked_state = ContentValidation::ContentBlockedState.find_by_container_commit_path(
          container,
          state_params[:commit_sha],
          state_params[:path]
        )

        if content_blocked_state.blank?
          content_blocked_state = ContentValidation::ContentBlockedState.create(state_params)
        end

        present content_blocked_state, with: ::API::Entities::ContentBlockedState
      end

      desc 'Delete a content blocked state'
      delete ':id' do
        authenticated_as_admin!

        content_blocked_state = ContentValidation::ContentBlockedState.find(params[:id])

        not_found!('content blocked state') unless content_blocked_state

        content_blocked_state.destroy

        no_content!
      end

      desc "User Complaint for blocked content"
      params do
        requires :description, type: String, desc: 'The complaint description'
      end
      post ":id/complaint" do
        content_blocked_state = ContentValidation::ContentBlockedState.find(params[:id])

        ContentValidation::ComplaintService.new(
          content_blocked_state: content_blocked_state,
          user: current_user,
          description: params[:description]).execute

        no_content!
      end

      desc "Scan project files"
      params do
        requires :project_id, type: Integer, desc: 'The ID of project'
        optional :ref, type: String, desc: 'The branch ref'
        optional :scan_path, type: String, desc: 'The scan path'
        optional :recursive, type: Boolean, desc: 'Recursive scan'
        optional :include_binary, type: Boolean, desc: 'Include binary file'
      end
      post "project_scan" do
        authenticated_as_admin!

        project = find_project!(params[:project_id])
        options = declared_params(include_missing: false).except(:project_id)
        ::ContentValidation::ProjectScanWorker.perform_async(project.id, options)

        no_content!
      end
    end
  end
end
