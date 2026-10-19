# frozen_string_literal: true

module JH
  module Projects
    module RepositoriesController
      extend ::Gitlab::Utils::Override

      override :archive
      def archive
        return render_404 if ::Gitlab::CurrentSettings.disable_download_button_enabled?

        super
      end
    end
  end
end
