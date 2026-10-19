# frozen_string_literal: true

module QA
  module Flow
    module JhSignUp
      extend self

      def sign_up_with_email(user)
        Page::Main::Menu.perform(&:sign_out_if_signed_in)
        Page::Main::Login.perform(&:switch_to_register_page)

        Page::Registration::SignUp.perform do |sign_up|
          sign_up.register_user(user)
        end
      end
    end
  end
end
