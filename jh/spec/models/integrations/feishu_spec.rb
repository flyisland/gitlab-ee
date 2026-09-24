# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::Feishu do
  let(:project) { create(:project) }
  let(:organization) { create(:organization) }
  # remove feishu integration due to creation feishu integration need set application_settings value
  # which cause spec/models/factories_spec.rb
  let(:instance_integration) do
    described_class.new(active: true,
      instance: true,
      organization_id: organization.id,
      alert_events: false,
      commit_events: false,
      confidential_issues_events: false,
      confidential_note_events: false,
      issues_events: false,
      job_events: false,
      merge_requests_events: false,
      note_events: false,
      pipeline_events: false,
      push_events: false,
      tag_push_events: false,
      wiki_page_events: false)
  end

  describe '#create' do
    context 'for check feature flag' do
      it 'cannot create when feishu app setting is empty' do
        expect(instance_integration.valid?).to be(false)
        expect(instance_integration.errors[:base][0]).to eq("Please check your settings for Feishu Integration in " \
          "JiHu GitLab, e.g. App ID and App Secret")
      end

      context 'for check feishu group name' do
        before do
          stub_application_setting(
            feishu_integration_enabled: true,
            feishu_app_key: "feishu_app_key",
            feishu_app_secret: "feishu_app_secret"
          )
        end

        it 'save success when correct feishu group name into event_channel_feishu_id' do
          instance_integration.push_events = true
          instance_integration.push_channel = 'feishu-group-1, feishu-group-2'
          client = instance_double(::Gitlab::Feishu::Client)
          allow(::Gitlab::Feishu::Client).to receive(:build).and_return(client)

          allow(client).to receive(:groups_contains_bot).and_return({
            'feishu-group-1' => 'feishu-group-1',
            'feishu-group-2' => 'feishu-group-2'
          })

          expect(instance_integration.save).to be_truthy
          expect(instance_integration.feishu_groups_name_id_hash).to eq({
            'feishu-group-1' => 'feishu-group-1',
            'feishu-group-2' => 'feishu-group-2'
          })
        end

        it 'save failed when wrong feishu group name' do
          instance_integration.push_events = true
          instance_integration.push_channel = 'feishu-group-1, some wrong group name'
          client = instance_double(::Gitlab::Feishu::Client)
          allow(::Gitlab::Feishu::Client).to receive(:build).and_return(client)

          allow(client).to receive(:groups_contains_bot).and_return({ 'feishu-group-1' => 'feishu-group-1' })

          expect(instance_integration.save).to be_falsy
          expect(instance_integration.errors[:base][0]).to eq("JiHu GitLab bot is not found in FeiShu group some " \
            "wrong group name, please add the bot first")
        end

        it 'save failed when fetch groups error' do
          instance_integration.push_events = true
          instance_integration.push_channel = 'feishu-group-1'
          client = instance_double(::Gitlab::Feishu::Client)
          allow(::Gitlab::Feishu::Client).to receive(:build).and_return(client)

          allow(client).to receive(:groups_contains_bot).and_return(nil)

          expect(instance_integration.save).to be_falsy
          expect(instance_integration.errors[:base][0]).to eq("Validate FeiShu Group Error, please follow FeiShu " \
            "Integration document verify the settings.")
        end
      end
    end
  end

  describe '#fields' do
    it 'returns custom fields' do
      event_channels = Integrations::Feishu::JH_SUPPORTED_EVENTS.map { |e| "#{e}_channel" }
      expect(instance_integration.fields.pluck(:name)).to eq([
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
    it do
      expect(instance_integration.supported_events).to eq(%w[push issue confidential_issue merge_request note
        confidential_note tag_push pipeline wiki_page
        deployment vulnerability alert])
    end
  end

  describe '#testable?' do
    it do
      expect(instance_integration.testable?).to be(false)
    end
  end

  describe '#configurable_channels?' do
    it do
      expect(instance_integration.configurable_channels?).to be(true)
    end
  end

  describe 'initialize_properties' do
    it 'assign zh_CN and fixed feishu webhook' do
      expect(instance_integration.language_for_notify).to eq 'zh_CN'
      expect(instance_integration.webhook).to eq Integrations::Feishu::FEISHU_WEBHOOK_URL
      expect(instance_integration.notify_only_when_pipeline_status_changes?).to be(false)
    end
  end

  describe '#execute' do
    before do
      stub_application_setting(
        feishu_integration_enabled: true,
        feishu_app_key: "feishu_app_key",
        feishu_app_secret: "feishu_app_secret"
      )
    end

    let(:group) { create(:group, path: 'feishu_group', name: 'feishu_group') }
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
          "name" => "feishu-notification-test",
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
          "name" => "feishu-notification-test",
          "description" => "",
          "homepage" => "http://gdk.test:3000/aa/bb"
        }
      }.with_indifferent_access
    end

    let(:message) do
      {

        "content" => Gitlab::Json.generate({
          "header" => {
            "title" => { "tag" => "markdown", "content" => "极狐GitLab 通知" },
            "template" => "green"
          },
          "elements" => [
            {
              "tag" => "markdown",
              "content" => "Administrator 已推送分支 [main](http://gdk.test:3000" \
                "/aa/bb/-/commits/main) 到项目 " \
                "[feishu_group / feishu-project]" \
                "(http://gdk.test:3000/aa/bb) " \
                "([比较变更](http://gdk.test:3000/aa/bb/-/" \
                "compare/before...after))"
            },
            {
              "tag" => "markdown",
              "content" => "[7ae057de](http://gdk.test:3000/aa/bb/-/commit/" \
                "7ae057de334bb6121381804179dd6a359845cb2a): " \
                "Update user.py - Administrator"
            }
          ]
        }),
        "msg_type" => "interactive"
      }
    end

    it 'send feishu notification' do
      res = instance_double(HTTParty::Response, success?: true)
      client = instance_double(::Gitlab::Feishu::Client)
      allow(::Gitlab::Feishu::Client).to receive(:build).and_return(client)
      allow(client).to receive(:groups_contains_bot).and_return({
        'feishu-group-1' => 'feishu-group-1',
        'feishu-group-2' => 'feishu-group-2'
      })
      expect(client).to receive(:send_message).once.with(
        Gitlab::Json.generate({ "receive_id" => "feishu-group-1" }.merge(message)),
        type: :group
      ).and_return(res)
      expect(client).to receive(:send_message).once.with(
        Gitlab::Json.generate({ "receive_id" => "feishu-group-2" }.merge(message)),
        type: :group
      ).and_return(res)

      project = create(:project, name: 'feishu-project', group: group)
      integration = described_class.new(project: project, active: true)

      integration.push_events = true
      integration.push_channel = 'feishu-group-1, feishu-group-2'
      integration.branches_to_be_notified = 'all'
      integration.save

      integration.execute(data)
    end
  end
end
