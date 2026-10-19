# frozen_string_literal: true

module JH
  module Profiles
    module EmailsController
      extend ::Gitlab::Utils::Override

      override :resend_confirmation_instructions
      def resend_confirmation_instructions
        if ::Emails::ConfirmService.new(current_user, user: current_user).execute(@email)
          flash[:notice] = format(
            s_("JH|ResendConfirmationEmail|Confirmation email sent to %{email}"),
            email: @email.email)
        else
          # rubocop:disable Gitlab/NoCodeCoverageComment
          # :nocov:
          flash[:alert] = s_("JH|ResendConfirmationEmail|Your operations are too frequent, " \
            "or there was a problem sending the confirmation email")
          # :nocov:
          # rubocop:enable Gitlab/NoCodeCoverageComment
        end

        redirect_to profile_emails_url
      end
    end
  end
end
