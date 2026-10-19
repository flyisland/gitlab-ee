# frozen_string_literal: true

module JH
  module SidebarsHelper
    extend ::Gitlab::Utils::Override

    GITLAB_NEXT_COOKIE = 'gitlab_canary'

    override :super_sidebar_context
    def super_sidebar_context(user, group:, project:, panel:, panel_type:)
      return super unless user

      context = super

      context.merge!(jihu_account_data)
      context.merge!(jh_gitlab_next_data)
    end

    private

    def jihu_account_data
      {
        trial_widget_data_attrs: {}
      }
    end

    def jh_gitlab_next_data
      { gitlab_com_and_canary: ::Gitlab.com? && gitlab_next_enabled? }
    end

    def gitlab_next_enabled?
      ::Gitlab.canary? || request.cookies[GITLAB_NEXT_COOKIE] == 'true'
    end
  end
end
