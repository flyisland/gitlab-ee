# frozen_string_literal: true

FactoryBot.define do
  factory :cd_artifact_source, class: 'Cd::ArtifactSource' do
    association :service, factory: :cd_service
    project { association(:project, organization: service.organization) }

    trait :external_registry do
      source_type { :external_registry }
      project { nil }
    end

    trait :desired_state do
      source_type { :desired_state }
      project { nil }
    end
  end
end
