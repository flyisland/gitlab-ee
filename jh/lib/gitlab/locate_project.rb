# frozen_string_literal: true

module Gitlab
  module LocateProject
    def locate_project(id_or_path)
      return unless id_or_path

      # rubocop: disable CodeReuse/ActiveRecord
      projects = Project.without_deleted.not_hidden

      if id_or_path.is_a?(Integer) || id_or_path =~ /^\d+$/
        projects.find_by(id: id_or_path)
      else
        projects.find_by_full_path(id_or_path) ||
          (::License.feature_available?(:project_aliases) ? ProjectAlias.find_by_name(id_or_path)&.project : nil)
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
