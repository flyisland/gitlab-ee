# frozen_string_literal: true

FactoryBot.define do
  factory :cd_artifact_source, class: 'Cd::ArtifactSource' do
    association :service, factory: :cd_service
    sequence(:source_ref) { |n| "registry.example.com/image-#{n}" }
    source_config { {} }
  end
end
