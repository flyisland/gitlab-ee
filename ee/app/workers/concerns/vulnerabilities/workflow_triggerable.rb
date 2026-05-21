# frozen_string_literal: true

module Vulnerabilities
  module WorkflowTriggerable
    extend ActiveSupport::Concern

    private

    def resolve_workflow_user(vulnerability, project)
      author = vulnerability.author

      return author if Ability.allowed?(author, :duo_workflow, project)

      Gitlab::AppLogger.info(
        message: 'Vulnerability author does not have duo_workflow permission, falling back to project owner',
        vulnerability_id: vulnerability.id,
        project_id: project.id,
        author_id: author&.id
      )

      project.first_human_owner
    end

    def log_no_eligible_user(vulnerability, project)
      Gitlab::AppLogger.error(
        message: 'No eligible user found for vulnerability workflow, ' \
          'author lacks permission and project has no human owner',
        vulnerability_id: vulnerability.id,
        project_id: project.id
      )
    end
  end
end
