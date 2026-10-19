# frozen_string_literal: true

require "spec_helper"

RSpec.describe 'API::Integrations', :clean_gitlab_redis_shared_state do
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

  let(:verification_token) { "verification_token" }
  let(:encrypt_key) { "encrypt_key" }
  let(:api_params_url_verification) do
    {
      type: "url_verification",
      challenge: "challenge",
      token: verification_token
    }
  end

  let(:event_id) { "e5280b2635b1cde825960e1942a0f55e" }
  let(:api_params_message) do
    {
      schema: "2.0",
      header: {
        event_id: event_id,
        token: verification_token,
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
    # The ChatOps examples below predate Duo; its routing is covered on its own.
    stub_feature_flags(jh_feishu_duo_chat: false)
    allow_any_instance_of(::Gitlab::Feishu::Client).to receive(:access_token).and_return(tenant_access_token)
    create(:feishu_bot_integration, :instance, verification_token: verification_token, encrypt_key: encrypt_key)
    create(:chat_name, user: user, team_id: team_id, chat_id: user_id)
  end

  def encrypt_payload(payload, key: encrypt_key)
    cipher = OpenSSL::Cipher.new('aes-256-cbc').encrypt
    cipher.key = OpenSSL::Digest::SHA256.digest(key)
    iv = cipher.random_iv

    Base64.strict_encode64(iv + cipher.update(Gitlab::Json.generate(payload)) + cipher.final)
  end

  def post_callback(payload, body: nil, timestamp: Time.current.to_i.to_s, nonce: "nonce", signature: nil)
    body ||= Gitlab::Json.generate({ encrypt: encrypt_payload(payload) })
    signature ||= OpenSSL::Digest::SHA256.hexdigest("#{timestamp}#{nonce}#{encrypt_key}#{body}")

    post api(path), params: body, headers: {
      'Content-Type' => 'application/json',
      'X-Lark-Request-Timestamp' => timestamp,
      'X-Lark-Request-Nonce' => nonce,
      'X-Lark-Signature' => signature
    }
  end

  shared_examples 'rejected callback' do
    it 'responds with 401 without replying or claiming the event' do
      post_callback(api_params_message, **callback_options)

      expect(response).to have_gitlab_http_status(:unauthorized)
      expect(send_message_request).not_to have_been_requested

      post_callback(api_params_message)

      expect(response).to have_gitlab_http_status(:ok)
      expect(send_message_request).to have_been_requested
    end
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
        post_callback(api_params_message)
        expect(access_token_request).to have_been_requested
      end
    end

    context "when not suppport license" do
      before do
        stub_licensed_features(feishu_bot_integration: false)
      end

      let(:message) { /Feishu bot is deactivated. Please upgrade your JiHu GitLab to Premium Plan/ }

      it "send right message" do
        post_callback(api_params_message)
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
        post_callback(api_params_message)
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
      end
    end
  end

  describe "authentication" do
    let(:message) { /Bot commands help/ }

    context "when the signature does not match" do
      let(:callback_options) { { signature: "0" * 64 } }

      it_behaves_like 'rejected callback'
    end

    context "when the timestamp is stale" do
      let(:callback_options) { { timestamp: 6.minutes.ago.to_i.to_s } }

      it_behaves_like 'rejected callback'
    end

    context "when the timestamp is within the allowed skew" do
      it "accepts the callback" do
        post_callback(api_params_message, timestamp: 4.minutes.ago.to_i.to_s)

        expect(response).to have_gitlab_http_status(:ok)
        expect(send_message_request).to have_been_requested
      end
    end

    # Captured from a real card callback: the header is Go's Time#String, not Unix seconds.
    def go_time(time)
      "#{time.in_time_zone('Asia/Shanghai').strftime('%Y-%m-%d %H:%M:%S.%N %z')} CST m=+12.345678901"
    end

    context "when the timestamp is in the format card callbacks are signed with" do
      it "accepts the callback" do
        post_callback(api_params_message, timestamp: go_time(Time.current))

        expect(response).to have_gitlab_http_status(:ok)
        expect(send_message_request).to have_been_requested
      end
    end

    context "when a timestamp in that format is stale" do
      let(:callback_options) { { timestamp: go_time(6.minutes.ago) } }

      it_behaves_like 'rejected callback'
    end

    context "when the timestamp is malformed" do
      let(:callback_options) { { timestamp: "now" } }

      it_behaves_like 'rejected callback'
    end

    context "when the callback is not encrypted" do
      let(:callback_options) { { body: Gitlab::Json.generate(api_params_message) } }

      it_behaves_like 'rejected callback'
    end

    context "when the ciphertext is malformed" do
      let(:callback_options) { { body: Gitlab::Json.generate({ encrypt: "not base64!" }) } }

      it_behaves_like 'rejected callback'
    end

    context "when encrypted with another key" do
      let(:callback_options) do
        { body: Gitlab::Json.generate({ encrypt: encrypt_payload(api_params_message, key: "other_key") }) }
      end

      it_behaves_like 'rejected callback'
    end

    context "when the Verification Token does not match" do
      it "responds with 401 without replying" do
        api_params_message[:header][:token] = "forged"
        post_callback(api_params_message)

        expect(response).to have_gitlab_http_status(:unauthorized)
        expect(send_message_request).not_to have_been_requested
      end
    end

    context "when the app ID does not match" do
      it "responds with 401 without replying" do
        api_params_message[:header][:app_id] = "forged"
        post_callback(api_params_message)

        expect(response).to have_gitlab_http_status(:unauthorized)
        expect(send_message_request).not_to have_been_requested
      end
    end

    context "when the event ID is missing" do
      it "responds with 401 without replying" do
        api_params_message[:header].delete(:event_id)
        post_callback(api_params_message)

        expect(response).to have_gitlab_http_status(:unauthorized)
        expect(send_message_request).not_to have_been_requested
      end
    end

    context "when the credentials are not configured" do
      before do
        ::Integrations::FeishuBot.for_instance.first.update_column(:encrypted_properties, nil)
      end

      it "responds with 401 without replying" do
        post_callback(api_params_message)

        expect(response).to have_gitlab_http_status(:unauthorized)
        expect(send_message_request).not_to have_been_requested
      end

      it "logs the rejection reason" do
        expect(::Gitlab::AppLogger).to receive(:warn).with(
          Labkit::Fields::LOG_MESSAGE => 'Rejected Feishu bot callback',
          Labkit::Fields::ERROR_MESSAGE => 'App ID, Verification Token or Encrypt Key is not configured'
        )

        post_callback(api_params_message)
      end
    end
  end

  describe "handler logic" do
    context "when url verification" do
      it "response right body" do
        post_callback(api_params_url_verification)
        expect(response).to have_gitlab_http_status(200)
        expect(Gitlab::Json.parse(response.body)).to eq({ "challenge" => "challenge" })
        expect(send_message_request).not_to have_been_requested
      end

      it "is not signed by Feishu, so does not need a signature" do
        post_callback(api_params_url_verification, signature: "")
        expect(response).to have_gitlab_http_status(200)
        expect(Gitlab::Json.parse(response.body)).to eq({ "challenge" => "challenge" })
      end

      it "rejects a wrong Verification Token" do
        api_params_url_verification[:token] = "forged"
        post_callback(api_params_url_verification)
        expect(response).to have_gitlab_http_status(:unauthorized)
      end

      it "rejects an unencrypted challenge" do
        post_callback(nil, body: Gitlab::Json.generate(api_params_url_verification))
        expect(response).to have_gitlab_http_status(:unauthorized)
      end
    end

    context "when repeat_event" do
      let(:message) { /Bot commands help/ }

      it "handles the event only once" do
        2.times { post_callback(api_params_message) }

        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested.once
      end

      it "drops a re-push of an event whose processing failed" do
        allow(::Gitlab::ChatopsCommands::Presenters::Helper).to receive(:help).and_raise(StandardError)
        post_callback(api_params_message)
        expect(response).to have_gitlab_http_status(:internal_server_error)

        allow(::Gitlab::ChatopsCommands::Presenters::Helper).to receive(:help).and_call_original
        post_callback(api_params_message)
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).not_to have_been_requested
      end

      it "claims the event per app" do
        ::Gitlab::Redis::SharedState.with do |redis|
          redis.set("feishu-bot/event-id/other_app/#{event_id}", 1)
        end

        post_callback(api_params_message)
        expect(send_message_request).to have_been_requested.once
      end

      it "expires the claim after the re-push window" do
        post_callback(api_params_message)

        ttl = ::Gitlab::Redis::SharedState.with { |redis| redis.ttl("feishu-bot/event-id/#{feishu_app_key}/#{event_id}") }
        expect(ttl).to be_within(5).of(8.hours.to_i)
      end
    end

    context "when setting not enabled" do
      before do
        stub_application_setting(feishu_integration_enabled: false)
      end

      it "cannot load the credentials to verify the callback" do
        post_callback(api_params_message)
        expect(response).to have_gitlab_http_status(:unauthorized)
        expect(send_message_request).not_to have_been_requested
      end
    end

    context "when no integration" do
      before do
        allow(::Integrations::FeishuBot).to receive(:for_instance).and_return([])
      end

      it "cannot verify the callback" do
        post_callback(api_params_message)
        expect(response).to have_gitlab_http_status(:unauthorized)
        expect(send_message_request).not_to have_been_requested
      end
    end

    context "when integration inactive" do
      let(:message) { /Please contact your administrator to enable .+ Admin - Settings - Integration/ }

      before do
        ::Integrations::FeishuBot.for_instance.first.update_column(:active, false)
      end

      it "send right message" do
        post_callback(api_params_message)
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
        post_callback(api_params_message)
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested.times(2)
      end
    end

    context "when command `help`" do
      let(:message) { /Bot commands help/ }

      it "send right message when command help" do
        api_params_message[:event][:message][:content] = Gitlab::Json.generate({ text: "help" })
        post_callback(api_params_message)
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
      end

      it "send right message when command empty" do
        api_params_message[:event][:message][:content] = Gitlab::Json.generate({ text: "" })
        post_callback(api_params_message)
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
      end

      it "send right message when command invalid json" do
        api_params_message[:event][:message][:content] = "invalid_json"
        post_callback(api_params_message)
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
        post_callback(api_params_message)
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
      end
    end

    context "when project not found" do
      let(:message) { /I cannot find the project/ }

      it "send right message" do
        api_params_message[:event][:message][:content] =
          Gitlab::Json.generate({ text: "not_found_project issue show" })
        post_callback(api_params_message)
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
            post_callback(api_params)
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
            post_callback(api_params)
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
            post_callback(api_params)
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
            post_callback(api_params)
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
        post_callback(api_params_message)
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
        expect(project.issues.last.title).to eq(issue_title)
      end

      it "send right message when use project id" do
        api_params_message[:event][:message][:content] = Gitlab::Json.generate(
          { text: "#{project.id} issue new #{issue_title}" }
        )
        post_callback(api_params_message)
        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
        expect(project.issues.last.title).to eq(issue_title)
      end
    end
  end

  describe "card button callbacks" do
    let(:value) { { duo_approval: 'approve', workflow_id: 1, card_id: 'card_open', fingerprint: 'fp' } }
    let(:card_action) do
      {
        schema: "2.0",
        header: {
          event_id: "f7984f25108f8137722bb63cee927e66",
          token: verification_token,
          create_time: "1603977298000000",
          event_type: "card.action.trigger",
          tenant_key: "13dd585acccf9740",
          app_id: feishu_app_key
        },
        event: {
          operator: { user_id: user_id, open_id: "ou_operator" },
          action: { tag: "button", value: value },
          context: { open_message_id: "om_card", open_chat_id: "oc_chat" }
        }
      }
    end

    it 'answers with the toast the click produced and sends no ChatOps reply', :aggregate_failures do
      received = nil
      allow(::Ai::Messaging::FeishuApprovalActionService).to receive(:new) do |**args|
        received = args
        instance_double(::Ai::Messaging::FeishuApprovalActionService,
          execute: { toast: { type: 'success', content: 'Approved.' } })
      end

      post_callback(card_action)

      expect(received[:operator_user_id]).to eq(user_id)
      expect(received[:value].to_h).to include('duo_approval' => 'approve', 'fingerprint' => 'fp')

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response).to eq('toast' => { 'type' => 'success', 'content' => 'Approved.' })
      expect(send_message_request).not_to have_been_requested
    end

    it 'is verified like any other callback' do
      expect(::Ai::Messaging::FeishuApprovalActionService).not_to receive(:new)

      post_callback(card_action, signature: "0" * 64)

      expect(response).to have_gitlab_http_status(:unauthorized)
    end
  end

  describe "Duo Agent Platform routing", :clean_gitlab_redis_shared_state do
    let(:bot_open_id) { "ou_bot" }
    let(:text) { "how do I create a project?" }
    let(:chat_type) { "p2p" }
    let(:mentions) { nil }

    let(:api_params) do
      api_params_message[:event][:message][:chat_type] = chat_type
      api_params_message[:event][:message][:content] = Gitlab::Json.generate({ text: text })
      api_params_message[:event][:message][:mentions] = mentions if mentions
      api_params_message
    end

    before do
      stub_feature_flags(jh_feishu_duo_chat: true)
      allow(::Gitlab::Feishu::BotApp).to receive(:access_token).and_return(tenant_access_token)
      stub_request(:get, "https://open.feishu.cn/open-apis/bot/v3/info")
        .to_return(status: 200, body: Gitlab::Json.generate({ code: 0, bot: { open_id: bot_open_id } }))
    end

    shared_examples 'a message for Duo' do |expected_text|
      it 'acknowledges at once and leaves the turn to the worker', :aggregate_failures do
        expect(::Feishu::DuoMessageWorker).to receive(:perform_async).with(
          user.id,
          {
            'app_id' => feishu_app_key,
            'chat_id' => 'oc_6533b4da079d3189dbecad777b59b612',
            'sender_id' => user_id,
            'message_id' => 'om_36747c28042826938814844dc8816961',
            'text' => expected_text
          }
        )

        post_callback(api_params)

        expect(response).to have_gitlab_http_status(200)
        expect(a_request(:post, %r{open-apis/im/v1/messages})).not_to have_been_made
      end
    end

    shared_examples 'a message for ChatOps' do
      it 'keeps the ChatOps answer and starts no Duo turn', :aggregate_failures do
        expect(::Feishu::DuoMessageWorker).not_to receive(:perform_async)

        post_callback(api_params)

        expect(response).to have_gitlab_http_status(200)
        expect(send_message_request).to have_been_requested
      end
    end

    context 'with a direct message' do
      it_behaves_like 'a message for Duo', 'how do I create a project?'
    end

    context 'with a group message that @mentions the robot' do
      let(:chat_type) { "group" }
      let(:text) { "@_user_1 ask @_user_2 about the release" }
      let(:mentions) do
        [
          { key: "@_user_1", id: { open_id: bot_open_id }, name: "GitLab" },
          { key: "@_user_2", id: { open_id: "ou_someone" }, name: "Li Lei" }
        ]
      end

      it_behaves_like 'a message for Duo', 'ask @Li Lei about the release'
    end

    context 'with ten or more mentions' do
      let(:chat_type) { "group" }
      let(:text) { "@_user_1 tell @_user_10 hi" }
      let(:mentions) do
        [
          { key: "@_user_1", id: { open_id: bot_open_id }, name: "GitLab" },
          { key: "@_user_10", id: { open_id: "ou_someone" }, name: "Li Lei" }
        ]
      end

      it_behaves_like 'a message for Duo', 'tell @Li Lei hi'
    end

    # Nothing to ask; as a decision it would reject a pending action.
    context 'with a group message that only @mentions the robot' do
      let(:chat_type) { "group" }
      let(:message) { // }
      let(:text) { "@_user_1" }
      let(:mentions) { [{ key: "@_user_1", id: { open_id: bot_open_id }, name: "GitLab" }] }

      it_behaves_like 'a message for ChatOps'
    end

    context 'with a group message that @mentions someone else' do
      let(:chat_type) { "group" }
      let(:message) { // }
      let(:text) { "@_user_1 can you look at this" }
      let(:mentions) { [{ key: "@_user_1", id: { open_id: "ou_someone" }, name: "Li Lei" }] }

      it_behaves_like 'a message for ChatOps'
    end

    context 'when Feishu cannot say which robot it is' do
      let(:chat_type) { "group" }
      let(:message) { // }
      let(:text) { "@_user_1 hello" }
      let(:mentions) { [{ key: "@_user_1", id: { open_id: bot_open_id }, name: "GitLab" }] }

      before do
        stub_request(:get, "https://open.feishu.cn/open-apis/bot/v3/info").to_return(status: 503, body: '')
      end

      it_behaves_like 'a message for ChatOps'
    end

    context 'with a ChatOps command' do
      let(:project) { create(:project, creator_id: user.id, namespace: user.namespace) }
      let(:text) { "#{project.path_with_namespace} issue new from chatops" }

      it_behaves_like 'a message for ChatOps'
    end

    context 'with help' do
      let(:message) { /Bot commands help/ }
      let(:text) { "help" }

      it_behaves_like 'a message for ChatOps'
    end

    context 'when the flag is off for the user' do
      let(:message) { /I cannot find the project/ }

      before do
        stub_feature_flags(jh_feishu_duo_chat: false)
      end

      it_behaves_like 'a message for ChatOps'
    end

    context 'when the sender has not connected an account' do
      before do
        ChatName.delete_all
      end

      it 'asks them to connect instead of starting a turn' do
        expect(::Feishu::DuoMessageWorker).not_to receive(:perform_async)

        post_callback(api_params)

        expect(send_message_request).to have_been_requested.times(2)
      end
    end

    context 'when the turn cannot be enqueued' do
      it 'fails the callback and releases the event id, so the push that follows is handled', :aggregate_failures do
        allow(::Feishu::DuoMessageWorker).to receive(:perform_async).and_raise(Redis::CannotConnectError)

        post_callback(api_params)

        expect(response).to have_gitlab_http_status(:internal_server_error)

        allow(::Feishu::DuoMessageWorker).to receive(:perform_async).and_call_original
        expect(::Feishu::DuoMessageWorker).to receive(:perform_async)

        post_callback(api_params)

        expect(response).to have_gitlab_http_status(:ok)
      end
    end
  end
end
