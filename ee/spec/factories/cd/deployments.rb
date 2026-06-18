# frozen_string_literal: true

FactoryBot.define do
  factory :cd_deployment, class: 'Cd::Deployment' do
    rollout { association(:cd_rollout) }
    version_set_entry { association(:cd_version_set_entry, version_set: rollout.version_set) }
    state { :pending }
  end
end
