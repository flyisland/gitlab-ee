# frozen_string_literal: true

module JH
  module PreferredLanguageSwitcherHelper
    extend ::Gitlab::Utils::Override

    def self.prepended(base)
      base.send(:remove_const, :SWITCHER_MINIMUM_TRANSLATION_LEVEL) # rubocop:disable GitlabSecurity/PublicSend -- constant
      base.const_set(:SWITCHER_MINIMUM_TRANSLATION_LEVEL, 70)
    end
  end
end
