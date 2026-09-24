# frozen_string_literal: true

require "spec_helper"

RSpec.describe 'API::Integrations' do
  include ApiHelpers

  let_it_be(:user, freeze: false) { create(:user, :with_namespace) }
  let_it_be(:path) { '/integrations/feishu/robot' }
  let_it_be(:team_id) { ::Gitlab::Chatops::FeishuBotHandler::BIND_TEAM_ID }
  let_it_be(:user_id) { "user_id" }
  let_it_be(:feishu_app_key) { "feishu_app_key" }
  let_it_be(:feishu_app_secret) { "feishu_app_secret" }
  let_it_be(:tenant_access_token) { "tenant_access_token" }

  let(:message) { // }
  let!(:send_message_request) do
    stub_request(:post, "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=chat_id")
      .with(
        body: message,
        headers: {
          'Authorization' => "Bearer #{tenant_access_token}",
          'Content-Type' => 'application/json; charset=utf-8'
        })
      .to_return(status: 200, body: Gitlab::Json.generate({ code: 0 }))
  end

  let(:api_params_url_verification) do
    {
      type: "url_verification",
      challenge: "challenge"
    }
  end

  let(:event_id) { "e5280b2635b1cde825960e1942a0f55e" }
  let(:api_params_message) do
    {
      schema: "2.0",
      header: {
        event_id: event_id,
        token: "TOKEN",
        create_time: "1662542796511",
        event_type: "im.message.receive_v1",
        tenant_key: "13dd585acccf9740",
        app_id: feishu_app_key
      },
      event: {
        message: {
          chat_id: "oc_6533b4da079d3189dbecad777b59b612",
          chat_type: "p2p",
          content: "{\"text\":\"help\"}",
          create_time: "1662542796245",
          message_id: "om_36747c28042826938814844dc8816961",
          message_type: "text"
        },
        sender: {
          sender_id: {
            open_id: "ou_39f0137469957650c08984a4baa3963e",
            union_id: "on_133536e1fd37863e49eb80a77d9a373f",
            user_id: user_id
          },
          sender_type: "user",
          tenant_key: "13dd585acccf9740"
        }
      }
    }
  end

  before do
    stub_application_setting(
      feishu_integration_enabled: true,
      feishu_app_key: feishu_app_key,
      feishu_app_secret: feishu_app_secret
    )
    stub_licensed_features(feishu_bot_integration: true)
    allow_any_instance_of(::Gitlab::Feishu::Client).to receive(:access_token).and_return(tenant_access_token)
    create(:feishu_bot_integration, :instance)
    create(:chat_name, user: user, team_id: team_id, chat_id: user_id)
  end

  describe "Unified logic" do
    context "when no access_token" do
      let!(:access_token_request) do
        stub_request(:post, "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal")
          .with(
            body: Gitlab::Json.generate({ app_id: feishu_app_key, app_secret: feishu_app_secret }),
            headers: {
              'Content-Type' => 'application/json; charset=utf-8'
            })
          .to_return(status: 200, body: Gitlab::Json.generate({ code: 0,
                                                                tenant_access_token: tenant_access_token.to_s }))
      end

      before do
        allow_any_instance_of(::Gitlab::Feishu::Client).to receive(:access_token).and_call_original
      end

      it "send right message" do
        post api(path)
        expect(access_token_request).to have_been_requested
      end
    end

    context "when not suppport license" do
      before do
        stub_licensed_features(feishu_bot_integration: false)
      end

      let(:message) { /Feishu bot is deactivated. Please upgrade your JiHu GitLab to Premium Plan/ }

      it "send right message" do
        post api(path)
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
      end
    end

    context "when SaaS", :saas do
      before do
        allow(::Gitlab).to receive(:com?).and_return(true)
      end

      let(:message) { /Feishu Integration for Saas is coming soon/ }

      it "send right message" do
        post api(path)
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
      end
    end
  end

  describe "handler logic" do
    context "when url verification" do
      it "response right body" do
        post api(path), params: api_params_url_verification
        expect(response).to have_gitlab_http_status(200)
        expect(Gitlab::Json.parse(response.body)).to eq({ "challenge" => "challenge" })
        expect(send_message_request).not_to have_been_requested
      end
    end

    context "when repeat_event" do
      before do
        cache_key = "#{::Gitlab::Chatops::FeishuBotHandler::EVENT_CACHE_KEY_PREFIX}/#{event_id}"
        allow(Rails.cache).to receive(:exist?).with(cache_key).and_return(true)
      end

      it "send right message" do
        post api(path), params: api_params_message
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).not_to have_been_requested
      end
    end

    context "when invalid message" do
      let(:message) { /Message verification failed. Please check your settings of/ }

      it "send right message" do
        api_params_message[:header][:app_id] = "invalid"
        post api(path), params: api_params_message
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
      end
    end

    context "when setting not enabled" do
      before do
        stub_application_setting(feishu_integration_enabled: false)
      end

      let(:message) { /Please contact your administrator to enable .+ Admin - Settings - General/ }

      it "send right message" do
        post api(path), params: api_params_message
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
      end
    end

    context "when no integration" do
      let(:message) { /Please contact your administrator to enable .+ Admin - Settings - Integration/ }

      before do
        allow(::Integrations::FeishuBot).to receive(:for_instance).and_return([])
      end

      it "send right message" do
        post api(path), params: api_params_message
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
      end
    end

    context "when no bind a chat" do
      let(:message) do
        connect_message = /Please connect your JiHu GitLab account/
        remind_message = /You need to connect your JiHu GitLab account before performing bot commands/

        /#{connect_message}|#{remind_message}/
      end

      before do
        allow_any_instance_of(::ChatNames::FindUserService).to receive(:execute).and_return(nil)
      end

      it "send right message" do
        post api(path), params: api_params_message
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested.times(2)
      end
    end

    context "when command `help`" do
      let(:message) { /Bot commands help/ }

      it "send right message when command help" do
        api_params_message[:event][:message][:content] = Gitlab::Json.generate({ text: "help" })
        post api(path), params: api_params_message
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
      end

      it "send right message when command empty" do
        api_params_message[:event][:message][:content] = Gitlab::Json.generate({ text: "" })
        post api(path), params: api_params_message
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
      end

      it "send right message when command invalid json" do
        api_params_message[:event][:message][:content] = "invalid_json"
        post api(path), params: api_params_message
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
      end
    end

    context "when user deactivate" do
      let(:message) { /Your JiHu GitLab user account is locked/ }

      before do
        user.deactivate
      end

      it "send right message" do
        api_params_message[:event][:message][:content] = Gitlab::Json.generate({ text: "project issue show" })
        post api(path), params: api_params_message
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
      end
    end

    context "when project not found" do
      let(:message) { /I cannot find the project/ }

      it "send right message" do
        api_params_message[:event][:message][:content] =
          Gitlab::Json.generate({ text: "not_found_project issue show" })
        post api(path), params: api_params_message
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
      end
    end

    describe "respond mention text" do
      let(:markdown_command) { "@user1 help" }
      let(:text_command) { "@user1 not_found_project" }

      context "when private chat" do
        let(:message) { exclude("</at>") }

        context "when format markdown type" do
          let(:api_params) do
            api_params_message[:event][:message][:chat_type] = "p2p"
            api_params_message[:event][:message][:content] = Gitlab::Json.generate({ text: markdown_command })
            api_params_message
          end

          it "respond no mention text" do
            post api(path), params: api_params
            expect(response).to have_gitlab_http_status(200)
            expect(send_message_request).to have_been_requested
          end
        end

        context "when format text type" do
          let(:api_params) do
            api_params_message[:event][:message][:chat_type] = "p2p"
            api_params_message[:event][:message][:content] = Gitlab::Json.generate({ text: text_command })
            api_params_message
          end

          it "respond no mention text" do
            post api(path), params: api_params
            expect(response).to have_gitlab_http_status(200)
            expect(send_message_request).to have_been_requested
          end
        end
      end

      context "when group chat" do
        context "when format markdown type" do
          let(:message) { include("</at>") }
          let(:api_params) do
            api_params_message[:event][:message][:chat_type] = "group"
            api_params_message[:event][:message][:content] = Gitlab::Json.generate({ text: markdown_command })
            api_params_message
          end

          it "respond a mention text" do
            post api(path), params: api_params
            expect(response).to have_gitlab_http_status(200)
            expect(send_message_request).to have_been_requested
          end
        end

        context "when format text type" do
          let(:message) { include("</at>") }
          let(:api_params) do
            api_params_message[:event][:message][:chat_type] = "group"
            api_params_message[:event][:message][:content] = Gitlab::Json.generate({ text: text_command })
            api_params_message
          end

          it "respond a mention text" do
            post api(path), params: api_params
            expect(response).to have_gitlab_http_status(200)
            expect(send_message_request).to have_been_requested
          end
        end
      end
    end

    context "when command `issue new`" do
      let(:project) { create(:project, creator_id: user.id, namespace: user.namespace) }
      let(:issue_title) { "issue_title" }

      it "send right message when use project full_path" do
        api_params_message[:event][:message][:content] = Gitlab::Json.generate(
          { text: "#{project.path_with_namespace} issue new #{issue_title}" }
        )
        post api(path), params: api_params_message
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
        expect(project.issues.last.title).to eq(issue_title)
      end

      it "send right message when use project id" do
        api_params_message[:event][:message][:content] = Gitlab::Json.generate(
          { text: "#{project.id} issue new #{issue_title}" }
        )
        post api(path), params: api_params_message
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
        expect(project.issues.last.title).to eq(issue_title)
      end
    end
  end
end
