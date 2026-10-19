# frozen_string_literal: true

module JH
  module Nav
    module GitlabDuoSettingsPage
      extend ::Gitlab::Utils::Override
      extend ActiveSupport::Concern

      override :show_gitlab_duo_settings_app?
      def show_gitlab_duo_settings_app?(group)
        ::Feature.enabled?(:jh_open_duo_chat, group) && super
      end
    end
  end
end
