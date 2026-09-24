# frozen_string_literal: true

module JH
  module TrialRegistrationsHelper
    extend ::Gitlab::Utils::Override

    def self.prepended(base)
      base.send(:remove_const, :TRUSTED_BY_LOGOS) # rubocop:disable GitlabSecurity/PublicSend -- constant
      base.const_set(:TRUSTED_BY_LOGOS, JH_TRUSTED_BY_LOGOS)
    end

    JH_TRUSTED_BY_LOGOS = [
      {
        path: 'marketing/1@2x.png',
        alt: '禅道',
        title: '禅道'
      },
      {
        path: 'marketing/2@2x.png',
        alt: '中智行',
        title: '中智行'
      },
      {
        path: 'marketing/3@2x.png',
        alt: '云骥',
        title: '云骥'
      }
    ].freeze
  end
end
