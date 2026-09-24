# frozen_string_literal: true

module JH
  module Members
    module InviteService
      extend ::Gitlab::Utils::Override

      private

      override :validate_invitable!
      def validate_invitable!
        super

        return unless ::Feature.enabled?(:ff_invitation_email_rate_limit)

        parsed_emails.each do |email|
          next unless ::Member.valid_email?(email)
          next unless ::Gitlab::ApplicationRateLimiter.throttled?(:invitation_email, scope: [current_user])

          raise ::Members::CreateService::TooManyInvitesError, s_('JH|inviteEmail|Invite email rate limit exceeded')
        end
      end
    end
  end
end
