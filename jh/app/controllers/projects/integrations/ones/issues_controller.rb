# frozen_string_literal: true

module Projects
  module Integrations
    module Ones
      class IssuesController < ::Projects::ApplicationController
        feature_category :integrations

        before_action :check_feature_enabled!

        rescue_from ::Gitlab::Ones::Client::Error, with: :render_error

        def index
          respond_to do |format|
            format.html
            format.json do
              render json: issues_json
            end
          end
        end

        def show
          @issue_json = issue_json
          respond_to do |format|
            format.html
            format.json do
              render json: @issue_json
            end
          end
        end

        private

        def query_params
          params.permit(:id, :page, :limit, :search, :sort, :state, labels: [])
        end

        def query
          ::Gitlab::Ones::Query.new(project.ones_integration, query_params)
        end

        def issue_json
          ::Integrations::OnesSerializers::IssueDetailSerializer \
            .new.represent(query.issue, project: project)
        end

        def issues_json
          ::Integrations::OnesSerializers::IssueSerializer \
            .new.with_pagination(request, response).represent(query.issues, project: project)
        end

        def check_feature_enabled!
          render_404 unless project&.licensed_feature_available?(:ones_issues_integration) && \
            project&.ones_integration&.active?
        end

        def render_error(exception)
          log_exception(exception)

          render json: {
            errors: [s_('JH|Integration|An error occurred while requesting data from the third party service.')]
          }, status: :bad_request
        end
      end
    end
  end
end
