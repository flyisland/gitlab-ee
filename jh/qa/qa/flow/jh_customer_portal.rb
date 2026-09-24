# frozen_string_literal: true

module QA
  module Flow
    module JhCustomerPortal
      extend self

      def page
        Capybara.current_session
      end

      def sign_in(user:)
        sign_in_to_gitlab(user)
        sign_out_from_portal_if_signed_in

        visit_portal
        ThirdPartyPage::CustomerPortal::SignIn.perform(&:sign_in_with_jihulab)

        wait_for_oauth_or_portal
        Page::Main::OAuth.perform(&:authorize!) if Page::Main::OAuth.perform(&:needs_authorization?)

        Support::Waiter.wait_until(message: 'Wait for Customer Portal OAuth callback') do
          ThirdPartyPage::CustomerPortal::Home.perform { |home| home.signed_in_to_portal(wait: 0) }
        end
      end

      private

      def sign_out_from_portal_if_signed_in
        visit_portal

        signed_in = ThirdPartyPage::CustomerPortal::Home.perform do |home|
          home.signed_in_to_portal(wait: 0)
        end

        ThirdPartyPage::CustomerPortal::Home.perform(&:sign_out) if signed_in
      end

      def visit_portal
        page.visit(Runtime::Env.customer_portal_url)

        Support::Waiter.wait_until(message: 'Wait for Customer Portal') do
          ThirdPartyPage::CustomerPortal::Home.perform { |home| home.signed_in_to_portal(wait: 0) } ||
            ThirdPartyPage::CustomerPortal::SignIn.perform { |sign_in| sign_in.has_sign_in_button?(wait: 0) }
        end
      end

      def sign_in_to_gitlab(user)
        Runtime::Browser.visit(:gitlab, Page::Dashboard::Welcome)
        Page::Main::Login.perform do |login|
          login.sign_out_and_sign_in_as(user: user)
        end
      end

      def wait_for_oauth_or_portal
        Support::Waiter.wait_until(message: 'Wait for GitLab OAuth authorization') do
          Page::Main::OAuth.perform(&:needs_authorization?) ||
            ThirdPartyPage::CustomerPortal::Home.perform { |home| home.signed_in_to_portal(wait: 0) }
        end
      end
    end
  end
end
