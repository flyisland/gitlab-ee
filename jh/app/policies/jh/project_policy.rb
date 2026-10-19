# frozen_string_literal: true

module JH
  module ProjectPolicy
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      condition(:performance_analytics_available, scope: :subject) do
        ::Feature.enabled?(:performance_analytics, @subject) &&
          @subject.licensed_feature_available?(:performance_analytics)
      end

      condition(:performance_analytics_reporter_access) { team_access_level >= ::Gitlab::Access::REPORTER }
      condition(:performance_analytics_auditor, scope: :user) { user&.auditor? }

      rule do
        (admin | performance_analytics_reporter_access | performance_analytics_auditor) &
          performance_analytics_available
      end
        .enable :read_performance_analytics_metrics
    end
  end
end
