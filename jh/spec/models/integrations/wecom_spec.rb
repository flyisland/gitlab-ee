# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::Wecom, feature_category: :api do
  let_it_be(:group) { create(:group, path: 'wecom_group', name: 'wecom_group') }
  let_it_be(:project) { create(:project, name: 'wecom-project', group: group) }
  let(:wecom_integration) { build(:wecom_integration, project: project) }

  describe '#create' do
    context 'when activated' do
      it 'is valid' do
        expect(wecom_integration).to be_valid
      end

      it 'is valid with actived and correct channel key' do
        wecom_integration.push_events = true
        wecom_integration.push_channel = '1ed13b8c-6bdf-45d0-a666-19de1c1e90b3'

        expect(wecom_integration).to be_valid
      end

      context 'when channel name invalid' do
        let(:channel_key) { 'invalid-channel-123' }

        it 'fails to create' do
          wecom_integration.push_events = true
          wecom_integration.push_channel = channel_key

          expect(wecom_integration.save).to be_falsy
          expect(wecom_integration.errors[:base][0]).to eq("Please input valid Wecom group robot webhook key")
        end
      end
    end
  end

  describe '#fields' do
    it 'returns custom fields' do
      event_channels = Integrations::Wecom::JH_SUPPORTED_EVENTS.map { |e| "#{e}_channel" }

      expect(wecom_integration.fields.pluck(:name)).to eq([
        "language_for_notify",
        "notify_only_broken_pipelines",
        "notify_only_when_pipeline_status_changes",
        "branches_to_be_notified",
        "labels_to_be_notified",
        "labels_to_be_notified_behavior",
        *event_channels
      ])
    end
  end

  describe '#supported_events' do
    it 'returns needed events' do
      expect(wecom_integration.supported_events).to eq(%w[push issue confidential_issue merge_request note
        confidential_note tag_push pipeline wiki_page
        deployment vulnerability alert])
    end
  end

  describe '#testable?' do
    it 'is not testable' do
      expect(wecom_integration.testable?).to be(false)
    end
  end

  describe '#configurable_channels?' do
    it 'can be configured with channels' do
      expect(wecom_integration.configurable_channels?).to be(true)
    end
  end

  describe 'initialize_properties' do
    it 'assign default zh_CN language' do
      expect(wecom_integration.language_for_notify).to eq 'zh_CN'
      expect(wecom_integration.webhook).to eq Integrations::Wecom::WECOM_WEBHOOK_URL
      expect(wecom_integration.notify_only_when_pipeline_status_changes?).to be(false)
    end
  end

  describe '#execute => #notify' do
    let(:data) do
      {
        "object_kind" => "push",
        "event_name" => "push",
        "before" => "before",
        "after" => "after",
        "ref" => "refs/heads/main",
        "checkout_sha" => "sha",
        "message" => nil,
        "user_id" => 1,
        "user_name" => "Administrator",
        "user_username" => "root",
        "user_email" => "",
        "user_avatar" => "avatar",
        "project_id" => 5,
        "project" => {
          "id" => 5,
          "name" => "wecom-notification-test",
          "description" => "",
          "web_url" => "http://gdk.test:3000/aa/bb",
          "namespace" => "aa",
          "homepage" => "http://gdk.test:3000/aa/bb"
        },
        "commits" => [
          {
            "id" => "7ae057de334bb6121381804179dd6a359845cb2a",
            "message" => "Update user.py",
            "title" => "Update user.py",
            "url" => "http://gdk.test:3000/aa/bb/-/commit/7ae057de334bb6121381804179dd6a359845cb2a",
            "author" => {
              "name" => "Administrator",
              "email" => "admin@example.com"
            },
            "added" => [],
            "modified" => ["user.py"],
            "removed" => []
          }
        ],
        "total_commits_count" => 1,
        "push_options" => {},
        "repository" => {
          "name" => "wecom-notification-test",
          "description" => "",
          "homepage" => "http://gdk.test:3000/aa/bb"
        }
      }.with_indifferent_access
    end

    let(:channel_key_1) { '1ed13b8c-6bdf-45d0-a666-19de1c1e90b3' }
    let(:channel_key_2) { '0ef24289-7a4a-4984-ad3e-b0e1903d0847' }
    let(:client) { instance_double(::Gitlab::Wecom::Client) }
    let(:response) { instance_double(HTTParty::Response, success?: true) }

    let(:message) do
      "# <font color=\"info\">极狐GitLab 通知</font>\nAdministrator 已推送分支 " \
        "[main](http://gdk.test:3000/aa/bb/-/commits/main) 到项目 " \
        "[wecom_group / wecom-project](http://gdk.test:3000/aa/bb) " \
        "([比较变更](http://gdk.test:3000/aa/bb/-/compare/before...after))\n" \
        "> [7ae057de](http://gdk.test:3000/aa/bb/-/commit/7ae057de334bb6121381804179dd6a359845cb2a): " \
        "Update user.py - Administrator"
    end

    let(:message_body) do
      Gitlab::Json.generate({ msgtype: 'markdown', markdown: { content: message } })
    end

    before do
      [channel_key_1, channel_key_2].each do |channel|
        stub_request(:post, "#{::Gitlab::Wecom::Client::MESSAGE_ENDPOINT}?key=#{channel}")
          .with({
            headers: { 'Content-Type' => 'application/json' },
            body: message_body
          })
          .to_return(
            status: 200,
            body: Gitlab::Json.generate({ errcode: 0, errmsg: 'ok' }),
            headers: {})
      end

      allow(::Gitlab::Wecom::Client).to receive(:new).and_return(client)

      wecom_integration.push_events = true
      wecom_integration.push_channel = "#{channel_key_1},#{channel_key_2}"
      wecom_integration.branches_to_be_notified = 'all'
      wecom_integration.save
    end

    it 'sends wecom notification', :unlimited_max_formatted_output_length do
      [channel_key_1, channel_key_2].each do |channel|
        expect(client).to receive(:send_message).once
          .with(message_body, channel).and_return(response)
      end

      wecom_integration.execute(data)
    end
  end
end
