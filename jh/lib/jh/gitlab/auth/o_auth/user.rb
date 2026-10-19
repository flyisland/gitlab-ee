# frozen_string_literal: true

module JH
  module Gitlab
    module Auth
      module OAuth
        module User
          extend ::Gitlab::Utils::Override
          include JH::Gitlab::Auth::OAuth::AuthHash

          override :save
          def save(provider = protocol_name)
            super.tap do |result|
              ::Gitlab::Dingtalk::Recipient.capture(result, auth_hash.auth_hash) if result.is_a?(::User)
            end
          end

          protected

          override :signup_enabled?
          def signup_enabled?
            auth_hash.provider != 'feishu' && super
          end

          override :auto_link_user?
          def auto_link_user?
            auth_hash.provider != 'feishu' && super
          end

          override :auto_link_ldap_user?
          def auto_link_ldap_user?
            auth_hash.provider != 'feishu' && super
          end

          override :build_new_user
          def build_new_user(skip_confirmation: true)
            super.tap do |user|
              next unless signup_identity_verification_enabled?(user)

              # Do not set the "confirmed_at" to "nil" to resolve the confirmation email issue during registration.
              # "nil" will be considered as the email not verified, causing new registered users to be redirected
              # to the email verification page.
              # Issue: https://jihulab.com/gitlab-cn/gitlab/-/issues/4683
              user.confirmed_at = Time.current if user_is_registered_by_oauth?(user)
            end
          end

          def user_is_registered_by_oauth?(user)
            user.email.start_with?(temporarily_email_prefix)
          end
        end
      end
    end
  end
end
