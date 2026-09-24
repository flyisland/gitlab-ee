# frozen_string_literal: true

module JH
  module Gitlab
    module Auth
      module OAuth
        module User
          extend ::Gitlab::Utils::Override
          include JH::Gitlab::Auth::OAuth::AuthHash

          protected

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
