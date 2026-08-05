# frozen_string_literal: true

FactoryBot.define do
  factory :gitlab_license, class: "Gitlab::License" do
    skip_create

    trait :trial do
      block_changes_at { nil }
      starts_at { Date.current }
      expires_at { starts_at.advance(days: 30) }
      restrictions do
        seats_attrs = seats ? { active_user_count: seats } : {}
        {
          add_ons: { 'GitLab_FileLocks' => 1, 'GitLab_Auditor_User' => 1 },
          plan: plan,
          subscription_id: '0000',
          trial: true
        }.merge(seats_attrs)
      end
    end

    trait :expired do
      expires_at { 3.weeks.ago.to_date }
    end

    trait :recently_expired do
      expires_at { 3.days.ago.to_date }
    end

    trait :legacy do
      cloud_licensing_enabled { false }
    end

    trait :cloud do
      cloud_licensing_enabled { true }
    end

    trait :offline do
      cloud_licensing_enabled { true }
      offline_cloud_licensing_enabled { true }
    end

    trait :online do
      cloud_licensing_enabled { true }
      offline_cloud_licensing_enabled { false }
    end

    transient do
      plan { License::PREMIUM_PLAN }
      seats { nil }
      # Defaults to nil for backward compatibility with the many specs already relying on
      # it being absent. This does not reflect reality: every license CustomersDot issues
      # always sets subscription_name alongside subscription_id (see
      # Encrypted::License#build_restrictions in customers-gitlab-com). Ideally this would
      # default to a real value (e.g. 'A-S000123') set together with subscription_id, but
      # that requires checking it doesn't break existing specs relying on the current
      # default -- left as a follow-up rather than bundled into this change.
      subscription_name { nil }
    end

    starts_at { Date.new(1970, 1, 1) }
    expires_at { Date.current + 11.months }
    block_changes_at { expires_at ? expires_at + 2.weeks : nil }
    notify_users_at  { expires_at }
    notify_admins_at { expires_at }

    licensee do
      {
        "Name" => generate(:name),
        "Email" => generate(:email),
        "Company" => "Company name"
      }
    end

    restrictions do
      seats_attrs = seats ? { active_user_count: seats } : {}
      subscription_name_attrs = subscription_name ? { subscription_name: subscription_name } : {}

      {
        add_ons: {
          'GitLab_FileLocks' => 1,
          'GitLab_Auditor_User' => 1
        },
        plan: plan,
        subscription_id: '0000'
      }.merge(seats_attrs).merge(subscription_name_attrs)
    end
  end
end
