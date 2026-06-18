# frozen_string_literal: true

FactoryBot.define do
  factory :cd_environment, class: 'Cd::Environment' do
    group
    organization { group&.organization || association(:organization) }
    cluster_agent { association(:cluster_agent, project: association(:project, group: group)) }
    sequence(:name) { |n| "environment-#{n}" }

    trait :with_description do
      description { 'A deployment environment' }
    end

    trait :for_organization do
      group { nil }
      organization
      cluster_agent do
        association(
          :cluster_agent,
          project: association(:project, group: association(:group, organization: organization))
        )
      end
    end
  end
end
