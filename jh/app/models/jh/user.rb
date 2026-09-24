# frozen_string_literal: true

module JH
  # User JH mixin
  #
  # This module is intended to encapsulate JH-specific model logic
  # and be prepended in the  model

  module User
    include TimeZoneHelper
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      attribute :preferred_language, default: -> {
        ::Feature.enabled?(:qa_enforce_locale_to_en) ? 'en' : ::Gitlab::CurrentSettings.default_preferred_language
      }

      # Vertual attribute for receive verification code in register form
      attr_accessor :verification_code
      attr_accessor :area_code

      delegate :phone, :phone=, to: :user_detail, allow_nil: true

      include ContentValidateable

      validates :name, content_validation: true, if: :should_validate_content?

      validates_inclusion_of :preferred_language, in: ::Gitlab::I18n.available_locales, if: :new_record?

      before_update :update_password_last_changed_at_to_now
      public :set_reset_password_token

      scope :by_encrypted_phone, ->(phone) do
        return none if phone.blank?

        joins(:user_detail).where(
          user_detail: { phone: ::Gitlab::CryptoHelper.aes256_gcm_encrypt(phone) }
        )
      end

      scope :not_admins, -> { where(admin: false) }
    end

    def phone_required?
      ::Gitlab::RealNameSystem.enabled? && !project_bot? && !service_account? && !skip_real_name_verification?
    end

    def phone_present?
      phone.present?
    end

    def jh_password_expired?
      return false unless ::Gitlab::PasswordExpirationSystem.enabled?
      return false if user_detail.password_last_changed_at.blank?

      (user_detail.password_last_changed_at + ::Gitlab::CurrentSettings.password_expires_in_days.day).past?
    end

    def skip_real_name_verification?
      # rubocop:disable Gitlab/AvoidFeatureGet -- get feature to process
      feature_values = ::Feature.get(:skip_real_name_verification).gate_values
      # rubocop:enable Gitlab/AvoidFeatureGet
      enabled_groups = feature_values.actors
      user_groups = groups.map(&:flipper_id).to_set

      !feature_values.boolean && enabled_groups.intersect?(user_groups)
    end

    override :can?
    def can?(action, subject = :global, **opts)
      # This is almost equivalent to:
      #
      #   rule { blocked }.policy do
      #     enable :log_in
      #   end
      #
      # JiHu cannot override the Upstream Policy, so we handle it here specifically.
      # See: https://jihulab.com/gitlab-cn/gitlab/-/issues/4566
      #
      # We use the conditional statement `state == 'blocked'` instead of the function "blocked?".
      # Because we only want to affect "blocked" state, not "ldap_blocked", "blocked_pending_approval", "banned"
      return true if action == :log_in && state == 'blocked' && ::Gitlab.jh? && ::Gitlab.com?

      super
    end

    # temp-email-for-oauth with omniauth
    # temp-email-for-phone with phone
    override :temp_oauth_email?
    def temp_oauth_email?
      email.start_with?('temp-email-for-')
    end

    def self.search_by_phone(scope, phone_number)
      phone_user_detail = ::UserDetail.by_encrypted_phone(phone_number).first
      return scope unless phone_user_detail

      scope.or(::User.where(id: phone_user_detail.user_id)
                     .reorder(scope.order_values)
                     .limit(scope.limit_value)
                     .offset(scope.offset_value))
    end

    class_methods do
      extend ::Gitlab::Utils::Override

      override :find_for_database_authentication
      def find_for_database_authentication(warden_conditions)
        return super unless ::Gitlab.jh? && ::Gitlab.com? \
          && ::Feature.enabled?(:phone_authenticatable)

        conditions = warden_conditions.dup
        login = conditions.delete(:login)

        if login
          super || where(conditions).by_encrypted_phone(wrap_phone(login)).take
        else
          super
        end
      end

      # override :by_login
      def by_login(login)
        return none if login.blank?

        query = super

        return query unless ::Gitlab.jh? && ::Gitlab.com? &&
          ::Feature.enabled?(:phone_authenticatable)

        return query if query.exists?

        by_encrypted_phone(wrap_phone(login))
      end

      def phone_registration_experience_hours
        ENV.fetch('PHONE_REGISTRATION_EXPERIENCE_HOURS', '24').to_i
      end

      private

      def wrap_phone(login)
        login = login.strip

        if login.match?(/^\d{11}$/)
          "#{::JH::Sms::AreaCode::MAINLAND}#{login}"
        else
          login
        end
      end
    end

    def require_email_skippable?
      ::Feature.enabled?(:soft_email_required_flow) &&
        ::Gitlab::RealNameSystem.enabled? &&
        phone_present? &&
        temp_oauth_email? &&
        phone_registration_experience_expires_at.future?
    end

    def phone_registration_experience_expires_at
      created_at.in_time_zone(local_timezone_instance(timezone)) + self.class.phone_registration_experience_hours.hours
    end

    override :requires_usage_stats_consent?
    def requires_usage_stats_consent?
      return false unless ::Feature.enabled?(:jh_usage_statistics)

      super
    end

    def last_custom_attribute
      custom_attributes.order(:created_at)&.last
    end

    FREE_TRIAL_LEFT_DAYS = 'free_trial_left_days'

    def mark_free_trial_left_days(days_count)
      value = days_count < 0 ? 0 : days_count
      UserCustomAttribute.upsert_custom_attributes([{ user_id: id, key: FREE_TRIAL_LEFT_DAYS, value: value }])
    end

    def remove_free_trial_left_days
      UserCustomAttribute.by_key(FREE_TRIAL_LEFT_DAYS).by_user_id(id).delete_all
    end

    private

    override :check_dap_self_hosted_feature
    def check_dap_self_hosted_feature(feature_setting)
      response = super
      return response if response.nil? || response.allowed?

      response unless ::GitlabSubscriptions::AddOnPurchase.for_self_managed.for_duo_enterprise.active.exists?
    end

    def update_password_last_changed_at_to_now
      user_detail.password_last_changed_at = Time.current if encrypted_password_changed?
    end
  end
end
