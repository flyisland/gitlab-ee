# frozen_string_literal: true

module Projects
  module Integrations
    module Ligaai
      class IssuesController < Projects::ApplicationController
        include RecordUserLastActivity

        before_action :check_feature_enabled!

        rescue_from ::Gitlab::Ligaai::Client::Error, with: :render_error

        feature_category :integrations

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
          ::Gitlab::Ligaai::Query.new(project.ligaai_integration, query_params)
        end

        def issue_json
          ::Integrations::LigaaiSerializers::IssueDetailSerializer.new
                                                                  .represent(query.issue, project: project)
        end

        def issues_json
          ::Integrations::LigaaiSerializers::IssueSerializer.new
                                                            .with_pagination(request, response)
                                                            .represent(query.issues, project: project)
        end

        def check_feature_enabled!
          render_404 unless project&.licensed_feature_available?(:ligaai_issues_integration) && \
            project&.ligaai_integration&.active?
        end

        def render_error(exception)
          log_exception(exception)

          respond_to do |format|
            format.html do
              render action_name
            end
            format.json do
              render json: { errors: [
                s_("JH|LigaaiIntegration|An error occurred while requesting data from the LigaAI service.")
              ] },
                status: :bad_request
            end
          end
        end
      end
    end
  end
end
