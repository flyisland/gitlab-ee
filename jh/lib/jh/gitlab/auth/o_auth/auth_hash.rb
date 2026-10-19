# frozen_string_literal: true

module JH
  module Gitlab
    module Auth
      module OAuth
        module AuthHash
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          # Avoid containing invalid characters, and conflict
          override :generate_temporarily_email
          def generate_temporarily_email(_username)
            hostname = ::Gitlab::CurrentSettings.current_application_settings.commit_email_hostname
            "#{temporarily_email_prefix}-#{SecureRandom.uuid}@#{hostname}"
          end

          def temporarily_email_prefix
            'temp-email-for-oauth'
          end

          # Some OAuth obtained emails are actually usernames or other content, not in a valid email format.
          # It is necessary to filter out such email.
          override :info
          def info
            raw_info = auth_hash['info']
            raw_info['email'] = nil unless Devise.email_regexp.match?(raw_info['email'])
            raw_info
          end
        end
      end
    end
  end
end
