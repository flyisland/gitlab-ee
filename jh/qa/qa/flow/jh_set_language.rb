# frozen_string_literal: true

module QA
  module Flow
    module JhSetLanguage
      extend self

      def set_language(language)
        Flow::Login.sign_in
        Page::Main::Menu.perform(&:click_edit_profile_link)
        Page::Profile::Menu.perform(&:click_preferences)
        ThirdPartyPage::Profile::Preferences.perform do |preferences|
          preferences.choose_language(language)
        end
        # sign for sanity check
        Page::Main::Menu.perform(&:sign_out)
      end
    end
  end
end
