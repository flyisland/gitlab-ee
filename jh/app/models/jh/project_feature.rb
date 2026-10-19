# frozen_string_literal: true

module JH
  module ProjectFeature
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Utils::StrongMemoize

    # force set access_level to private only for jihulab saas but no HK
    def pages_access_level
      access_level = super

      if ::Gitlab.com? && ::Feature.enabled?(:jh_hide_pages_access_level) &&
          access_level != ::ProjectFeature::DISABLED && ::Gitlab::Pages.access_control_is_forced?
        access_level = ::ProjectFeature::PRIVATE
      end

      access_level
    end

    private

    override :set_pages_access_level
    def set_pages_access_level
      if ::Gitlab.com? && pages_access_level != ::ProjectFeature::DISABLED && ::Gitlab::Pages.access_control_is_forced?
        self.pages_access_level = ::ProjectFeature::PRIVATE
      else
        super
      end
    end
  end
end
