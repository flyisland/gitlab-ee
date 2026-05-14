# frozen_string_literal: true

class ProjectPushRuleFinder
  def initialize(project)
    @project = project
  end

  def execute
    if ::Feature.enabled?(:read_project_push_rules, project)
      project.project_push_rule
    else
      project.push_rule
    end
  end

  private

  attr_reader :project
end
