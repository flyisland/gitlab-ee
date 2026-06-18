# frozen_string_literal: true

FactoryBot.define do
  factory :cd_application, class: 'Cd::Application' do
    group
    organization { group&.organization || association(:organization) }
    sequence(:name) { |n| "application-#{n}" }

    trait :for_organization do
      group { nil }
    end

    trait :with_group do
      group
    end
  end
end
