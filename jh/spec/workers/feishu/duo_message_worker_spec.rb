# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Feishu::DuoMessageWorker, :clean_gitlab_redis_shared_state, feature_category: :duo_agent_platform do
  let_it_be_with_reload(:user) { create(:user) }

  let(:reply_url) { 'https://open.feishu.cn/open-apis/im/v1/messages/om_question/reply' }
  let(:params) do
    {
      'app_id' => 'cli_app',
      'chat_id' => 'oc_chat',
      'sender_id' => 'feishu-user-1',
      'message_id' => 'om_question',
      'text' => 'how do I create a project?'
    }
  end

  subject(:perform) { described_class.new.perform(user.id, params) }

  before do
    create(:chat_name, user: user, team_id: ::Gitlab::Chatops::FeishuBotHandler::BIND_TEAM_ID,
      chat_id: 'feishu-user-1')
    allow(::Gitlab::Feishu::BotApp).to receive(:access_token).and_return('tenant-token')
  end

  def stub_turn(reply = 'Duo is working on it…')
    allow_next_instance_of(::Ai::Messaging::FeishuTriggerService) do |service|
      allow(service).to receive(:execute).and_return(reply)
    end
  end

  def stub_reply(status: 200, code: 0)
    stub_request(:post, reply_url).to_return(status: status, body: Gitlab::Json.generate(code: code, data: {}))
  end

  it 'runs the turn for the bound user and replies to the message', :aggregate_failures do
    expect(::Ai::Messaging::FeishuTriggerService).to receive(:new).with(
      user: user, app_id: 'cli_app', chat_id: 'oc_chat', thread_id: nil, sender_id: 'feishu-user-1',
      message_id: 'om_question', message: 'how do I create a project?'
    ).and_return(instance_double(::Ai::Messaging::FeishuTriggerService, execute: 'Duo is working on it…'))
    reply = stub_reply.with(body: hash_including('msg_type' => 'post', 'uuid' => 'duo-reply-om_question'))

    perform

    expect(reply).to have_been_requested.once
  end

  it 'sends nothing when the turn answers in its own card' do
    stub_turn(nil)

    perform

    expect(a_request(:post, reply_url)).not_to have_been_made
  end

  it 'answers in words when the turn raises, rather than leave the user waiting' do
    allow_next_instance_of(::Ai::Messaging::FeishuTriggerService) do |service|
      allow(service).to receive(:execute).and_raise(ActiveRecord::StatementInvalid)
    end
    reply = stub_reply.with { |req| req.body.include?('Failed to start the Duo session') }

    perform

    expect(reply).to have_been_requested
  end

  describe 'repeated deliveries' do
    it 'retries a failed reply without running the turn again', :aggregate_failures do
      stub_turn
      stub_reply(status: 503)

      expect { perform }.to raise_error(::Gitlab::Feishu::AppResponse::TransientError)

      stub_reply
      expect(::Ai::Messaging::FeishuTriggerService).not_to receive(:new)

      described_class.new.perform(user.id, params)

      expect(a_request(:post, reply_url).with(body: hash_including('uuid' => 'duo-reply-om_question')))
        .to have_been_made.twice
    end

    it 'drops a message Feishu pushes again after it was answered' do
      stub_turn
      reply = stub_reply
      perform

      expect(::Ai::Messaging::FeishuTriggerService).not_to receive(:new)

      described_class.new.perform(user.id, params)

      expect(reply).to have_been_requested.once
    end

    # A job that died after starting the turn but before recording its reply
    # may have started the flow; running it again could repeat a write.
    it 'does not start a turn another job has claimed' do
      ::Gitlab::Redis::SharedState.with do |redis|
        redis.set('feishu:duo_message:{cli_app:om_question}:turn', 1)
      end

      expect(::Ai::Messaging::FeishuTriggerService).not_to receive(:new)

      perform

      expect(a_request(:post, reply_url)).not_to have_been_made
    end

    it 'gives up on a reply Feishu refuses for good' do
      stub_turn
      stub_reply(status: 400, code: 230011)

      expect { perform }.not_to raise_error
    end
  end

  describe 'eligibility at run time' do
    shared_examples 'a message that is dropped' do
      it 'runs no turn and sends nothing', :aggregate_failures do
        expect(::Ai::Messaging::FeishuTriggerService).not_to receive(:new)

        perform

        expect(a_request(:post, reply_url)).not_to have_been_made
      end
    end

    context 'when the user was blocked after the callback' do
      before do
        user.block!
      end

      it_behaves_like 'a message that is dropped'
    end

    context 'when the feature flag is off' do
      before do
        stub_feature_flags(jh_feishu_duo_chat: false)
      end

      it_behaves_like 'a message that is dropped'
    end

    context 'when the Feishu account is now bound to someone else' do
      before do
        ChatName.find_by(chat_id: 'feishu-user-1').update!(user: create(:user))
      end

      it_behaves_like 'a message that is dropped'
    end

    context 'when the user is gone' do
      subject(:perform) { described_class.new.perform(non_existing_record_id, params) }

      it_behaves_like 'a message that is dropped'
    end
  end
end
