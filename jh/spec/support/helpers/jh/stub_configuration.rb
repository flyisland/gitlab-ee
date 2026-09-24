# frozen_string_literal: true

module JH
  module StubConfiguration
    def stub_jh_application_setting(messages)
      add_predicates(messages)

      # Stubbing both of these because we're not yet consistent with how we access
      # current application settings
      allow_any_instance_of(JH::ApplicationSetting).to receive_messages(to_settings(messages))
      allow(::Gitlab::CurrentSettings.current_application_settings)
        .to receive_messages(to_settings(messages))
    end

    def stub_application_setting(message)
      if ::JH::ApplicationSetting::OVERRIDE_SETTINGS.include?(message.each_key.first)
        stub_jh_application_setting(message)
      else
        super
      end
    end
  end
end
