# frozen_string_literal: true

# LicenseTemplateFinder
#
# To inject `Mulan-PSL` License into public License template
module JH
  module LicenseTemplateFinder
    extend ::Gitlab::Utils::Override

    private

    override :available_licenses
    def available_licenses
      return super if popular_only?

      jh_licenses = [Licensee::License["mulanpsl-2.0"]]
      super + jh_licenses
    end
  end
end
