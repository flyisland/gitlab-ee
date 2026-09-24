# frozen_string_literal: true

module JH
  module OmniauthCallbacksController
    extend ::Gitlab::Utils::Override

    prepended do
      protect_from_forgery except: [:cas3, :failure] + ::AuthHelper.saml_providers, with: :exception, prepend: true
    end

    def cas3
      ticket = params['ticket']
      handle_service_ticket oauth['provider'], ticket if ticket

      handle_omniauth
    end

    private

    # Devise fails to the sign-in page, which bounces a signed-in user straight
    # back and drops the alert on the way (SkipsAlreadySignedInMessage), so a
    # failed binding looks like a successful one. Only that destination is
    # replaced; admin mode re-authentication keeps failing to its own page.
    override :after_omniauth_failure_path_for
    def after_omniauth_failure_path_for(scope)
      path = super
      return path unless current_user && path == new_session_path(scope)

      profile_two_factor_auth_path
    end

    def handle_service_ticket(provider, ticket)
      ::Gitlab::Auth::OAuth::Session.create provider, ticket
      session[:service_tickets] ||= {}
      session[:service_tickets][provider] = ticket
    end
  end
end
