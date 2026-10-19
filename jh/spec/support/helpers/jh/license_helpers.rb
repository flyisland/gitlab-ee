# frozen_string_literal: true

module JH
  module LicenseHelpers
    extend ActiveSupport::Concern

    prepended do
      ::Project.prepend JHClearLicensedFeatureAvailableCache
      ::Namespace.prepend JHClearLicensedFeatureAvailableCache
    end

    module JHClearLicensedFeatureAvailableCache
      def licensed_feature_available?(*)
        if ::EE::LicenseHelpers::ClearLicensedFeatureAvailableCache.clear_cache
          clear_memoization(:jh_licensed_feature_available)
        end

        super
      end
    end
  end
end
