# frozen_string_literal: true

FactoryBot.define do
  factory :dingtalk_integration, class: 'Integrations::Dingtalk' do
    project
    active { true }
    type { 'Integrations::Dingtalk' }

    transient do
      create_data { true }
      corpid { 'dummy_dingtalk_corp_id' }
    end

    after(:build) do |integration, evaluator|
      if evaluator.create_data
        integration.dingtalk_tracker_data = build(:dingtalk_tracker_data,
          integration: integration,
          corpid: evaluator.corpid)
      end
    end
  end

  factory :dingtalk_tracker_data, class: 'Integrations::DingtalkTrackerData' do
    integration
    corpid { 'dummy_dingtalk_corp_id' }
  end

  factory :ones_integration, class: 'Integrations::Ones' do
    project
    active { true }
    type { 'Integrations::Ones' }
    url { 'https://example.com' }
    api_url { nil }
    namespace { SecureRandom.hex(4) } # team uuid
    project_key { SecureRandom.hex(8) } # project uuid
    user_key { SecureRandom.hex(4) } # user uuid
    api_token { SecureRandom.uuid }
  end

  factory :shimo_integration, class: 'Integrations::Shimo' do
    project
    active { true }
    external_wiki_url { 'https://shimo.example.com/desktop' }
  end

  factory :ligaai_integration, class: 'Integrations::Ligaai' do
    project
    active { true }
    type { 'Integrations::Ligaai' }
    url { 'https://ligaai.cn' }
    api_url { nil }
    project_key { "81272373" } # project uuid
    user_key { SecureRandom.hex(4) } # user uuid
    api_token { SecureRandom.uuid }
  end

  factory :wecom_integration, class: 'Integrations::Wecom' do
    project
    active { true }
    type { 'Integrations::Wecom' }
    alert_events { false }
    commit_events { false }
    confidential_issues_events { false }
    confidential_note_events { false }
    issues_events { false }
    job_events { false }
    merge_requests_events { false }
    note_events { false }
    pipeline_events { false }
    push_events { false }
    tag_push_events { false }
    wiki_page_events { false }
  end

  factory :feishu_bot_integration, class: 'Integrations::FeishuBot' do
    project
    active { true }
  end
end
