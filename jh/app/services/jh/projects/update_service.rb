# frozen_string_literal: true

module JH
  module Projects
    module UpdateService
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      override :after_update
      def after_update
        result = super

        # When change visibility_level from private to public or internal
        if ::ContentValidation::Setting.check_enabled?(project) &&
            project.saved_change_to_visibility_level? &&
            project.visibility_level_previously_was == ::Gitlab::VisibilityLevel::PRIVATE
          ::ContentValidation::ContainerService.new(container: project, user: current_user).execute

          if project.wiki.exists?
            ::ContentValidation::ContainerService.new(container: project.wiki, user: current_user).execute
          end

          ::ContentValidation::ProjectVisibilityChangedWorker.perform_async(project.id, current_user.id)
        end

        result
      end
    end
  end
end
