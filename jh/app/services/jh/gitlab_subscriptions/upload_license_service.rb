# frozen_string_literal: true

module JH
  module GitlabSubscriptions
    module UploadLicenseService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute
        return super if ::Feature.disabled?(:jh_enable_upload_cloud_license)

        return error_response(license_file_error) if license_file_missing?

        # JH skip check this condition for online cloud license
        # return error_response(online_license_error) if license.online_cloud_license?

        if license.save
          update_add_on_purchases

          ServiceResponse.success(payload: { license: license }, message: success_message)
        else
          error_response(license.errors.full_messages.join.html_safe, license: license) # rubocop:disable Rails/OutputSafety -- Calling html_safe should be fine here
        end
      end

      override :update_add_on_purchases
      def update_add_on_purchases
        return super if ::Feature.disabled?(:jh_enable_upload_cloud_license)

        # JH skip check this condition, allow online_cloud_license
        # return unless license.offline_cloud_license?

        ::GitlabSubscriptions::AddOnPurchases::SelfManaged::ProvisionServices::AddOns.new.execute
      end
    end
  end
end
