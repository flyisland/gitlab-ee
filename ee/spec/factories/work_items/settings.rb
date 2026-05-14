# frozen_string_literal: true

FactoryBot.define do
  factory :work_item_settings, class: 'WorkItems::Settings' do
    association :namespace
    organization { nil }
    customizable_type_visibility { false }
  end
end
