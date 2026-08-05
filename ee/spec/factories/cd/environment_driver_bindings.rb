# frozen_string_literal: true

FactoryBot.define do
  factory :cd_environment_driver_binding, class: 'Cd::EnvironmentDriverBinding' do
    environment { association(:cd_environment) }
    sequence(:version) { |n| n }
    sequence(:driver_ref) { |n| "argo-rollouts-v#{n}" }
    driver_config { {} }
  end
end
