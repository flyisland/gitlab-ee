# frozen_string_literal: true

module JH
  module GitlabSubscriptions
    module Features
      # Since we're dealing with constants here, use "re-open" class.
      module ::GitlabSubscriptions
        class Features
          EE_STARTER_FEATURES = STARTER_FEATURES + STARTER_FEATURES_WITH_USAGE_PING
          EE_PREMIUM_FEATURES = PREMIUM_FEATURES + PREMIUM_FEATURES_WITH_USAGE_PING
          EE_ULTIMATE_FEATURES = ULTIMATE_FEATURES + ULTIMATE_FEATURES_WITH_USAGE_PING

          # Starter Tier
          JH_STARTER_FEATURES = %i[
            dingtalk_integration
            disable_download_button
            feishu_bot_integration
            wecom_app_integration
            real_lines_of_code
            performance_analytics
            password_expiration
            ai_chat
            ai_catalog
            ai_workflows
            code_suggestions
            agentic_chat
            self_hosted_models
          ].freeze
          remove_const :ALL_STARTER_FEATURES
          ALL_STARTER_FEATURES = Rails.env.test? ? EE_STARTER_FEATURES : JH_STARTER_FEATURES

          # Premium Tier
          JH_PREMIUM_ADDITION = %i[
            ones_issues_integration
            ligaai_issues_integration
            monorepo
          ].freeze

          JH_PREMIUMN_REMOVALS = [].freeze
          remove_const :ALL_PREMIUM_FEATURES
          ALL_PREMIUM_FEATURES = (
            JH_STARTER_FEATURES + EE_STARTER_FEATURES + \
            EE_PREMIUM_FEATURES + JH_PREMIUM_ADDITION - \
            JH_PREMIUMN_REMOVALS
          ).uniq

          # Ultimate Tier
          ULTIMATE_FEATURES = ((remove_const :ULTIMATE_FEATURES) - JH_PREMIUM_ADDITION).freeze
          JH_ULTIMATE_ADDITION = [].freeze
          remove_const :ALL_ULTIMATE_FEATURES
          ALL_ULTIMATE_FEATURES = (
            ALL_PREMIUM_FEATURES + \
            EE_ULTIMATE_FEATURES + JH_ULTIMATE_ADDITION
          ).uniq

          remove_const :ALL_FEATURES
          ALL_FEATURES = ALL_ULTIMATE_FEATURES

          remove_const :FEATURES_BY_PLAN
          FEATURES_BY_PLAN = {
            ::License::TEAM_PLAN => ALL_STARTER_FEATURES,
            ::License::STARTER_PLAN => ALL_STARTER_FEATURES,
            ::License::PREMIUM_PLAN => ALL_PREMIUM_FEATURES,
            ::License::ULTIMATE_PLAN => ALL_ULTIMATE_FEATURES
          }.freeze

          remove_const :PLANS_BY_FEATURE
          PLANS_BY_FEATURE = FEATURES_BY_PLAN.each_with_object({}) do |(plan, features), hash|
            features.each do |feature|
              hash[feature] ||= []
              hash[feature] << plan
            end
          end.freeze

          temp_license_plans_to_saas_plans = LICENSE_PLANS_TO_SAAS_PLANS.dup
          remove_const :LICENSE_PLANS_TO_SAAS_PLANS
          LICENSE_PLANS_TO_SAAS_PLANS = temp_license_plans_to_saas_plans.merge(
            ::License::TEAM_PLAN => [::Plan::TEAM]
          ).freeze

          class << self
            # to support msgid scanning
            def plan_names
              {
                ::License::TEAM_PLAN => s_("JH|License|Team"),
                ::License::STARTER_PLAN => s_("JH|License|Starter"),
                ::License::PREMIUM_PLAN => s_("JH|License|Premium"),
                ::License::ULTIMATE_PLAN => s_("JH|License|Ultimate")
              }
            end
          end
        end
      end
    end
  end
end
