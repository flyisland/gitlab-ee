# frozen_string_literal: true

module JH
  module Emails
    module ConfirmService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(email)
        return if email.confirmed_at.present? || email.updated_at > 1.minute.ago

        super.tap { email.touch }
      end
    end
  end
end
