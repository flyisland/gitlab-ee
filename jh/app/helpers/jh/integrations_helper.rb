# frozen_string_literal: true

module JH
  module IntegrationsHelper
    def ones_issue_breadcrumb_link(issue)
      external_issue_breadcrumb_link('logos/ones.svg', issue[:id], issue[:url], target: '_blank')
    end

    # rubocop:disable Gitlab/ModuleWithInstanceVariables
    def ones_issues_show_data
      {
        issues_show_path: project_integrations_ones_issue_path(@project, params[:id], format: :json),
        issues_list_path: @project.ones_integration.issue_tracker_path
      }
    end

    def ligaai_issue_breadcrumb_link(issue)
      external_issue_breadcrumb_link('logos/ligaai.svg', issue[:id].to_s, issue[:url], target: '_blank')
    end

    def ligaai_issues_show_data
      {
        issues_show_path: project_integrations_ligaai_issue_path(@project, params[:id], format: :json),
        issues_list_path: project_integrations_ligaai_issues_path(@project)
      }
    end
    # rubocop:enable Gitlab/ModuleWithInstanceVariables
  end
end
