# frozen_string_literal: true

module JH
  module Gitlab
    module OmniauthInitializer
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      OAUTH2_TIMEOUT_SECONDS = 10

      class_methods do
        extend ::Gitlab::Utils::Override

        override :default_arguments_for
        def default_arguments_for(provider_name)
          case provider_name
          when 'cas3'
            { on_single_sign_out: cas3_signout_handler }
          when 'shibboleth'
            { fail_with_empty_uid: true }
          when 'google_oauth2'
            { client_options: { connection_opts: { request: { timeout: OAUTH2_TIMEOUT_SECONDS } } } }
          when 'gitlab'
            {
              authorize_params: { gl_auth_type: 'login' }
            }
          when ->(provider_name) { ::AuthHelper.saml_providers.include?(provider_name.to_sym) }
            { attribute_statements: ::Gitlab::Auth::Saml::Config.default_attribute_statements }
          else
            {}
          end
        end

        private

        def cas3_signout_handler
          ->(request) do
            ticket = request.params[:session_index]
            raise "Service Ticket not found." unless ::Gitlab::Auth::OAuth::Session.valid?(:cas3, ticket)

            ::Gitlab::Auth::OAuth::Session.destroy(:cas3, ticket)
            true
          end
        end
      end
    end
  end
end
