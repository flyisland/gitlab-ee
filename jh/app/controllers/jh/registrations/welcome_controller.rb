# frozen_string_literal: true

module JH
  module Registrations
    module WelcomeController
      extend ::Gitlab::Utils::Override

      protected

      # override the ConfirmEmailWarning method in order to skip
      def show_confirm_warning?
        return super unless ::Gitlab.jh? && ::Gitlab.com?

        false
      end
    end
  end
end
