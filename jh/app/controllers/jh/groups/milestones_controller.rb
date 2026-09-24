# frozen_string_literal: true

module JH
  module Groups
    module MilestonesController
      extend ::Gitlab::Utils::Override

      private

      override :group_projects_with_access
      def group_projects_with_access
        return [] if params[:only_group]

        super
      end
    end
  end
end
