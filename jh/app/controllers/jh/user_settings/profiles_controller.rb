# frozen_string_literal: true

module JH
  module UserSettings
    module ProfilesController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override
      include CheckPhoneAndCode

      prepended do
        prepend_before_action :verify_code_received_by_phone, only: [:update], if: :verify_code_received_by_phone?
        before_action :set_empty_phone_param_to_nil, only: [:update], if: -> { user.skip_real_name_verification? }
        before_action :set_skippable_email_banner, only: [:show], if: :being_redirected?
        skip_before_action :onboarding_redirect
      end

      override :show
      def show
        if @user && !@user.frozen?
          begin
            @user.phone = ::Gitlab::CryptoHelper.aes256_gcm_decrypt(@user.phone)
          rescue TypeError
          end
        end

        super
      end

      private

      override :user_params_attributes
      def user_params_attributes
        if ::Gitlab::RealNameSystem.enabled?
          super + [:phone, :verification_code, :area_code]
        else
          super
        end
      end

      def verify_code_received_by_phone
        check_verification_code
      end

      def verify_code_received_by_phone?
        ::Gitlab::RealNameSystem.enabled? && params[:user][:phone].present?
      end

      def being_redirected?
        params[:redirected]
      end

      def set_empty_phone_param_to_nil
        # In postgreSQL, the `''` and the `nil` are different values.
        # For a unique index, multiple `nil` are allowed, but multiple `''` will raise a duplicate key error.
        # Users who skip real name verification are allowed to set `phone` to be empty. Convert blank to nil.
        params[:user][:phone] = nil if params[:user].key?(:phone) && params[:user][:phone].blank?
      end

      def set_skippable_email_banner
        flash[:warning] = safe_format(
          s_('JH|Profiles|Please complete your profile with email address before making purchases')
        )
      end
    end
  end
end
