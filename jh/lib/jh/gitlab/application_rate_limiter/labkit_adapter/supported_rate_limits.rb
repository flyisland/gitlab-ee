# frozen_string_literal: true

module JH
  module Gitlab
    module ApplicationRateLimiter
      module LabkitAdapter
        # JH-only entries for the labkit rate-limit adapter, merged into the
        # CE/EE registry via prepend.
        module SupportedRateLimits
          extend ActiveSupport::Concern

          class_methods do
            extend ::Gitlab::Utils::Override

            override :rule_definitions
            def rule_definitions
              super.merge(
                email_exists: ::Labkit::RateLimit::Rule.new(
                  name: 'limit_email_existence_checks_by_ip',
                  characteristics: %i[ip],
                  limit: 20,
                  period: 1.minute,
                  action: :limit
                ),
                invitation_email: ::Labkit::RateLimit::Rule.new(
                  name: 'limit_invitation_emails_by_user',
                  characteristics: %i[user],
                  limit: 50,
                  period: 1.day,
                  action: :limit
                )
              )
            end
          end
        end
      end
    end
  end
end
