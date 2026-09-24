# frozen_string_literal: true

RSpec.configure do |config|
  # Run upstream feature-tier assertions with upstream plan assignments.
  # JH specs retain Team assignments outside this temporary test context.
  config.before(
    rerun_file_path: %r{/ee/spec/(?:lib/(?:ee/)?sidebars/|models/gitlab_subscriptions/features_spec\.rb\z)}
  ) do |example|
    next if example.metadata[:rerun_file_path].end_with?('/features_spec.rb') &&
      !example.full_description.start_with?('GitlabSubscriptions::Features.minimum_plan_for ')

    plans_by_feature = GitlabSubscriptions::Features::PLANS_BY_FEATURE.transform_values do |plans|
      plans - [License::TEAM_PLAN]
    end

    stub_const('GitlabSubscriptions::Features::PLANS_BY_FEATURE', plans_by_feature)
  end
end
