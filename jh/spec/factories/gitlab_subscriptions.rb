# frozen_string_literal: true

FactoryBot.modify do
  factory :gitlab_subscription do
    trait :team do
      association :hosted_plan, factory: :team_plan
    end
  end
end
