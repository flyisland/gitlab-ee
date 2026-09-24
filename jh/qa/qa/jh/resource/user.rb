# frozen_string_literal: true

# Prepended onto ::QA::Resource::User
module QA
  module JH
    module Resource
      module User
        attr_accessor :preferred_language

        # We ignore rubocop here because it is hard to workaround it
        # rubocop:disable Gitlab/ModuleWithInstanceVariables
        def phone
          return @phone if @phone.present?

          api_resource&.dig(:phone)
        end
        # rubocop:enable Gitlab/ModuleWithInstanceVariables

        # We ignore rubocop here because it is hard to workaround it
        def phone=(value)
          @phone = value # rubocop:disable Gitlab/ModuleWithInstanceVariables
        end

        # We ignore rubocop here because it is hard to workaround it
        def user_preferred_language
          @preferred_language || "en" # rubocop:disable Gitlab/ModuleWithInstanceVariables
        end

        def api_post_body
          super.merge(preferred_language: user_preferred_language)
        end

        def api_phone_path
          "#{api_put_path}/phone"
        end

        def api_put_phone(body = api_put_body)
          response = put(
            ::QA::Runtime::API::Request.new(api_client, api_phone_path).url,
            body)

          unless response.code == ::QA::Support::API::HTTP_STATUS_OK
            raise ::QA::Resource::Errors::ResourceFabricationFailedError,
              "Updating #{self.class.name} using the API failed (#{response.code}) with `#{response}`.\n" \
                "#{QA::Support::Loglinking.failure_metadata(response.headers[:x_request_id])}"
          end

          process_api_response(parse_body(response))
        end

        def add_phone(phone)
          put_body = { phone: phone }
          api_put_phone(put_body)
          self.phone = phone
        end

        protected

        # @override :comparable
        def comparable
          [username, password, phone, name, preferred_language]
        end
      end
    end
  end
end
