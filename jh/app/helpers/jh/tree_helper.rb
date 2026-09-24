# frozen_string_literal: true

module JH
  module TreeHelper
    extend ::Gitlab::Utils::Override

    override :download_links
    def download_links(project, ref, archive_prefix, ref_type)
      return [] if ::Gitlab::CurrentSettings.disable_download_button_enabled?

      super
    end
  end
end
