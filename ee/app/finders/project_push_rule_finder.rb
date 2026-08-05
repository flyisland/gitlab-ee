# frozen_string_literal: true

class ProjectPushRuleFinder
  def initialize(project)
    @project = project
  end

  def execute
    project.push_rule
  end

  private

  attr_reader :project
end
