# frozen_string_literal: true

FactoryBot.define do
  factory :cd_application_flow_definition, class: 'Cd::ApplicationFlowDefinition' do
    application { association(:cd_application) }
    definition { "trigger:\n  type: pipeline\nstages: []\n" }
  end
end
