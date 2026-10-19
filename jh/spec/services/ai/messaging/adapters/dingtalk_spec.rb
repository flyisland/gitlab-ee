# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Messaging::Adapters::Dingtalk, feature_category: :duo_agent_platform do
  let(:corp_id) { 'dingtalk_corpid' }
  let(:conversation_id) { 'cidabcdef' }
  let(:conversation_type) { '1' }
  let(:sender_staff_id) { 'staff123' }

  let(:callback_context) do
    {
      'adapter' => 'dingtalk',
      'corp_id' => corp_id,
      'conversation_id' => conversation_id,
      'conversation_type' => conversation_type,
      'sender_staff_id' => sender_staff_id
    }
  end

  subject(:adapter) do
    described_class.new(
      corp_id: corp_id,
      conversation_id: conversation_id,
      conversation_type: conversation_type,
      sender_staff_id: sender_staff_id
    )
  end

  before do
    stub_application_setting(
      dingtalk_integration_enabled: true,
      dingtalk_app_key: 'dingtalk_app_key',
      dingtalk_corpid: 'dingtalk_corpid',
      dingtalk_app_secret: 'dingtalk_app_secret'
    )
    stub_request(:post, ::Gitlab::Dingtalk::Client::ACCESS_TOKEN_ENDPOINT)
      .to_return(status: 200, body: Gitlab::Json.generate({ 'accessToken' => 'token', 'expireIn' => 7200 }))
  end

  def stub_card_create
    stub_request(:post, ::Gitlab::Dingtalk::Client::CARD_CREATE_ENDPOINT)
      .to_return(
        status: 200,
        body: Gitlab::Json.generate({ 'success' => true,
                                      'result' => { 'deliverResults' => [{ 'success' => true }] } })
      )
  end

  def stub_card_stream
    stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)
      .to_return(status: 200, body: Gitlab::Json.generate({ 'success' => true, 'result' => true }))
  end

  describe '.adapter_key' do
    it { expect(described_class.adapter_key).to eq('dingtalk') }
  end

  describe '.supports_live_progress?' do
    it { expect(described_class.supports_live_progress?).to be(true) }
  end

  describe '.private_to_invoker?' do
    it { expect(described_class.private_to_invoker?).to be(true) }
  end

  describe '.from_callback_context and #build_callback_context' do
    it 'round-trips the callback context without losing fields' do
      restored = described_class.from_callback_context(callback_context)

      expect(restored).to be_a(described_class)
      expect(restored.build_callback_context).to eq(
        'corp_id' => corp_id,
        'conversation_id' => conversation_id,
        'conversation_type' => conversation_type,
        'sender_staff_id' => sender_staff_id
      )
    end
  end

  describe '#deliver_result' do
    let_it_be(:workflow) { create(:duo_workflows_workflow) }

    let(:message) { 'Here is the answer' }

    context 'when remembering the answer for the next session', :clean_gitlab_redis_shared_state do
      let(:session_store) do
        ::Gitlab::Dingtalk::DuoSessionStore.new(
          corp_id: corp_id, conversation_id: conversation_id, sender_staff_id: sender_staff_id,
          user_id: workflow.user_id
        )
      end

      let(:turn_context) { callback_context.merge('turn_token' => session_store.start_turn!('the question')) }

      def deliver(context)
        adapter.deliver_result(callback_context: context, message: message, workflow: workflow)
      end

      it 'records the answer without the session link once it is delivered' do
        stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT).to_return(status: 200, body: '')

        deliver(turn_context)

        expect(session_store.transcript).to eq([
          { 'role' => 'user', 'text' => 'the question' },
          { 'role' => 'assistant', 'text' => message }
        ])
      end

      it 'drops a late answer after the conversation was reset' do
        stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT).to_return(status: 200, body: '')
        context = turn_context
        session_store.clear!

        deliver(context)

        expect(session_store.transcript).to be_empty
      end

      it 'drops an answer from a turn the conversation has moved past' do
        stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT).to_return(status: 200, body: '')
        context = turn_context
        session_store.start_turn!('a newer question')

        deliver(context)

        expect(session_store.transcript.pluck('text')).to eq(['the question', 'a newer question'])
      end

      it 'records nothing for a context from before the turn token' do
        stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT).to_return(status: 200, body: '')
        session_store.start_turn!('the question')

        deliver(callback_context)

        expect(session_store.transcript.pluck('text')).to eq(['the question'])
      end

      it 'records nothing when the answer does not reach DingTalk' do
        stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT).to_return(status: 500, body: '')

        deliver(turn_context)

        expect(session_store.transcript.pluck('text')).to eq(['the question'])
      end

      it 'still reports a delivered answer as delivered when recording fails', :aggregate_failures do
        stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT).to_return(status: 200, body: '')
        context = turn_context
        allow_next_instance_of(::Gitlab::Dingtalk::DuoSessionStore) do |store|
          allow(store).to receive(:record_answer!).and_raise(::Redis::CannotConnectError)
        end

        expect(Gitlab::ErrorTracking).to receive(:track_exception)
          .with(an_instance_of(::Redis::CannotConnectError), hash_including(dingtalk_corp_id: corp_id))
        expect(deliver(context)).to be(true)
      end
    end

    context 'for a single chat' do
      it 'posts the answer to the invoker and returns truthy' do
        request = stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT)
          .with do |req|
            body = Gitlab::Json.parse(req.body)
            body['msgKey'] == 'sampleMarkdown' && body['userIds'] == [sender_staff_id]
          end
          .to_return(status: 200, body: '')

        expect(adapter.deliver_result(callback_context: callback_context, message: message,
          workflow: workflow)).to be(true)
        expect(request).to have_been_requested
      end

      it 'includes the session link in the message' do
        request = stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT)
          .with do |req|
            Gitlab::Json.parse(Gitlab::Json.parse(req.body)['msgParam'])['text'].include?(workflow.web_url)
          end
          .to_return(status: 200, body: '')

        expect(adapter.deliver_result(callback_context: callback_context, message: message,
          workflow: workflow)).to be(true)
        expect(request).to have_been_requested
      end

      it 'returns false when the message does not reach DingTalk' do
        stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT)
          .to_return(status: 500, body: '')

        expect(adapter.deliver_result(callback_context: callback_context, message: message,
          workflow: workflow)).to be(false)
      end

      it 'returns false when DingTalk answers 200 but reports the recipient invalid' do
        stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT)
          .to_return(status: 200, body: Gitlab::Json.generate({ 'invalidStaffIdList' => [sender_staff_id] }))

        expect(adapter.deliver_result(callback_context: callback_context, message: message,
          workflow: workflow)).to be(false)
      end

      it 'returns false when the client swallows a network error' do
        stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT).to_raise(Timeout::Error)

        expect(adapter.deliver_result(callback_context: callback_context, message: message,
          workflow: workflow)).to be(false)
      end
    end

    context 'for a group chat' do
      let(:conversation_type) { '2' }

      it 'posts the answer to the conversation and returns truthy' do
        request = stub_request(:post, ::Gitlab::Dingtalk::Client::GROUP_MESSAGE_ENDPOINT)
          .with do |req|
            body = Gitlab::Json.parse(req.body)
            body['msgKey'] == 'sampleMarkdown' && body['openConversationId'] == conversation_id
          end
          .to_return(status: 200, body: '')

        expect(adapter.deliver_result(callback_context: callback_context, message: message,
          workflow: workflow)).to be(true)
        expect(request).to have_been_requested
      end
    end

    context 'when the turn opened a card' do
      before do
        callback_context['status_ts'] = 'duo-abc'
      end

      it 'settles that card instead of posting a second message', :aggregate_failures do
        request = stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)
          .with do |req|
            body = Gitlab::Json.parse(req.body)
            body['outTrackId'] == 'duo-abc' && body['isFinalize'] == true &&
              body['content'].include?(message)
          end
          .to_return(status: 200, body: Gitlab::Json.generate({ 'success' => true }))

        expect(adapter.deliver_result(callback_context: callback_context, message: message,
          workflow: workflow)).to be(true)
        expect(request).to have_been_requested
        expect(a_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT)).not_to have_been_made
      end

      it 'accepts the body the streaming endpoint actually answers with' do
        stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)
          .to_return(status: 200, body: Gitlab::Json.generate({ 'result' => true, 'success' => true }))

        expect(adapter.deliver_result(callback_context: callback_context, message: message,
          workflow: workflow)).to be(true)
      end

      it 'reports the answer undelivered when the card refuses it' do
        stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)
          .to_return(status: 200, body: Gitlab::Json.generate({ 'success' => false }))

        expect(adapter.deliver_result(callback_context: callback_context, message: message,
          workflow: workflow)).to be(false)
      end
    end
  end

  describe '#deliver_error' do
    it 'posts a user-facing error message' do
      request = stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT)
        .with do |req|
          Gitlab::Json.parse(Gitlab::Json.parse(req.body)['msgParam'])['text'].include?("don't have access to Duo")
        end
        .to_return(status: 200, body: '')

      adapter.deliver_error(callback_context: callback_context, error: :forbidden)

      expect(request).to have_been_requested
    end

    it 'maps :message_too_long to a specific hint' do
      request = stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT)
        .with do |req|
          Gitlab::Json.parse(Gitlab::Json.parse(req.body)['msgParam'])['text'].include?('message is too long')
        end
        .to_return(status: 200, body: '')

      adapter.deliver_error(callback_context: callback_context, error: :message_too_long)

      expect(request).to have_been_requested
    end

    it 'tells the user when the answer could not be delivered' do
      request = stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT)
        .with do |req|
          Gitlab::Json.parse(Gitlab::Json.parse(req.body)['msgParam'])['text'].include?("couldn't post the answer")
        end
        .to_return(status: 200, body: '')

      adapter.deliver_error(callback_context: callback_context, error: :delivery_failed)

      expect(request).to have_been_requested
    end

    it 'returns nil when the client swallows a network error' do
      stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT).to_raise(Timeout::Error)

      expect(adapter.deliver_error(callback_context: callback_context, error: :forbidden)).to be_nil
    end

    it 'settles the turn\'s card as a failure rather than as a finished answer' do
      callback_context['status_ts'] = 'duo-abc'
      request = stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)
        .with do |req|
          body = Gitlab::Json.parse(req.body)
          body['outTrackId'] == 'duo-abc' && body['isFinalize'] == true && body['isError'] == true
        end
        .to_return(status: 200, body: Gitlab::Json.generate({ 'result' => true, 'success' => true }))

      adapter.deliver_error(callback_context: callback_context, error: :flow_failed)

      expect(request).to have_been_requested
    end
  end

  describe '#on_request_received' do
    it 'opens the card before the flow runs and carries it in the context', :aggregate_failures do
      request = stub_card_create

      expect(adapter.on_request_received).to be_nil
      expect(request).to have_been_requested
      expect(adapter.card_opened?).to be(true)
      expect(adapter.build_callback_context['status_ts']).to be_present
    end

    it 'carries on without a card when DingTalk refuses it', :aggregate_failures do
      stub_request(:post, ::Gitlab::Dingtalk::Client::CARD_CREATE_ENDPOINT).to_return(status: 500, body: '')

      expect(adapter.on_request_received).to be_nil
      expect(adapter.card_opened?).to be(false)
      expect(adapter.build_callback_context).not_to have_key('status_ts')
    end
  end

  describe '#on_flow_enqueued' do
    let_it_be_with_reload(:workflow) do
      create(:duo_workflows_workflow, messaging_callback_context: { 'adapter' => 'dingtalk' })
    end

    it 'opens the card the first hook could not, and records it', :aggregate_failures do
      stub_card_create

      adapter.on_flow_enqueued(callback_context: callback_context, workflow: workflow)

      expect(workflow.reload.messaging_callback_context['status_ts']).to be_present
      expect(adapter.card_opened?).to be(true)
    end

    it 'leaves the turn without a card when DingTalk refuses this attempt too', :aggregate_failures do
      stub_request(:post, ::Gitlab::Dingtalk::Client::CARD_CREATE_ENDPOINT)
        .to_return(status: 500, body: '')

      adapter.on_flow_enqueued(callback_context: callback_context, workflow: workflow)

      expect(workflow.reload.messaging_callback_context['status_ts']).to be_nil
      expect(adapter.card_opened?).to be(false)
    end

    it 'does not open a second card when the first hook already opened one' do
      workflow.merge_messaging_callback_context!('status_ts' => 'duo-existing')

      adapter.on_flow_enqueued(callback_context: callback_context, workflow: workflow)

      expect(a_request(:post, ::Gitlab::Dingtalk::Client::CARD_CREATE_ENDPOINT)).not_to have_been_made
    end
  end

  describe '#roll_card_for_decision', :clean_gitlab_redis_shared_state do
    let_it_be_with_reload(:workflow) do
      create(:duo_workflows_workflow, :tool_call_approval_required,
        messaging_callback_context: { 'adapter' => 'dingtalk', 'status_ts' => 'duo-parked' })
    end

    before do
      allow(workflow).to receive(:latest_ui_chat_log).and_return(
        [{ 'message_type' => 'request', 'message_id' => 'call-1',
           'tool_info' => { 'name' => 'create_issue_note' },
           'content' => 'Add comment to issue #18 in project 1' }]
      )
    end

    it 'settles the parked card and points the session at a fresh one', :aggregate_failures do
      settle = stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)
        .with do |req|
          body = Gitlab::Json.parse(req.body)
          body['outTrackId'] == 'duo-parked' && body['isFinalize'] == true &&
            body['content'].include?("> Add comment to issue #18 in project 1\n\nCancelled that action.") &&
            body['content'].exclude?('Reply "approve"')
        end
        .to_return(status: 200, body: Gitlab::Json.generate({ 'result' => true, 'success' => true }))
      stub_request(:post, ::Gitlab::Dingtalk::Client::CARD_CREATE_ENDPOINT)
        .to_return(
          status: 200,
          body: Gitlab::Json.generate({ 'success' => true,
                                        'result' => { 'deliverResults' => [{ 'success' => true }] } })
        )

      expect(adapter.roll_card_for_decision(workflow: workflow, note: 'Cancelled that action.')).to be(true)
      expect(settle).to have_been_requested

      rolled = workflow.reload.messaging_callback_context['status_ts']
      expect(rolled).to be_present
      expect(rolled).not_to eq('duo-parked')
    end

    it 'reports no card when the session never had one' do
      workflow.merge_messaging_callback_context!('status_ts' => nil)

      expect(adapter.roll_card_for_decision(workflow: workflow)).to be(false)
    end

    it 'takes the buttons off a card that showed them' do
      Gitlab::Redis::SharedState.with do |redis|
        redis.set('dingtalk:duo:approval_request:duo-parked', 'Duo needs your approval', ex: 60)
      end
      stub_card_stream
      stub_card_create
      hide = stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_UPDATE_ENDPOINT)
        .with(body: hash_including('cardData' => { 'cardParamMap' => { 'approval_token' => '' } }))
        .to_return(status: 200, body: Gitlab::Json.generate({ 'result' => true, 'success' => true }))

      adapter.roll_card_for_decision(workflow: workflow)

      expect(hide).to have_been_requested
    end
  end

  describe '#on_approval_required' do
    let_it_be(:workflow) { create(:duo_workflows_workflow, :tool_call_approval_required) }

    it 'hands the notice to the worker rather than sending it inline' do
      expect(::Ai::Messaging::ApprovalNoticeWorker).to receive(:perform_async).with(workflow.id)

      adapter.on_approval_required(callback_context: callback_context, workflow: workflow)
    end
  end

  describe '#deliver_approval_request', :clean_gitlab_redis_shared_state do
    let_it_be(:workflow) { create(:duo_workflows_workflow, :tool_call_approval_required) }

    let(:pending_call) do
      {
        'message_type' => 'request',
        'content' => 'Add comment to issue #18 in project 1',
        'message_id' => 'call-abc',
        'tool_info' => { 'name' => 'create_issue_note', 'args' => { 'body' => 'hi' } }
      }
    end

    let(:ui_chat_log) do
      [
        { 'message_type' => 'agent', 'content' => 'Let me check that issue.', 'tool_info' => nil },
        pending_call
      ]
    end

    before do
      allow(workflow).to receive(:latest_ui_chat_log).and_return(ui_chat_log)
    end

    def stub_notice_request
      stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT).to_return(status: 200, body: '')
    end

    it 'writes the request into the turn\'s card rather than below it' do
      callback_context['status_ts'] = 'duo-open'
      request = stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)
        .with do |req|
          body = Gitlab::Json.parse(req.body)
          body['outTrackId'] == 'duo-open' && body['isFinalize'] == false &&
            body['content'].include?('Add comment to issue #18 in project 1')
        end
        .to_return(status: 200, body: Gitlab::Json.generate({ 'result' => true, 'success' => true }))

      expect(adapter.deliver_approval_request(callback_context: callback_context, workflow: workflow)).to be(true)
      expect(request).to have_been_requested
      expect(a_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT)).not_to have_been_made
    end

    it 'asks the invoker to decide, quoting the pending action' do
      request = stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT)
        .with do |req|
          text = Gitlab::Json.parse(Gitlab::Json.parse(req.body)['msgParam'])['text']

          text.include?('Add comment to issue #18 in project 1') &&
            text.include?('needs your approval') &&
            text.include?(workflow.web_url)
        end
        .to_return(status: 200, body: '')

      expect(adapter.deliver_approval_request(callback_context: callback_context, workflow: workflow)).to be(true)

      expect(request).to have_been_requested
    end

    it 'asks only once for the same pending call' do
      request = stub_notice_request

      2.times { adapter.deliver_approval_request(callback_context: callback_context, workflow: workflow) }

      expect(request).to have_been_requested.once
    end

    it 'asks again for a later call in the same session' do
      request = stub_notice_request
      adapter.deliver_approval_request(callback_context: callback_context, workflow: workflow)

      allow(workflow).to receive(:latest_ui_chat_log)
        .and_return([pending_call.merge('message_id' => 'call-def')])
      adapter.deliver_approval_request(callback_context: callback_context, workflow: workflow)

      expect(request).to have_been_requested.twice
    end

    it 'releases the claim when the send fails, so a later attempt can ask again' do
      stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT).to_return(status: 500, body: '')
      expect(adapter.deliver_approval_request(callback_context: callback_context, workflow: workflow)).to be(false)

      stub_notice_request

      expect(adapter.deliver_approval_request(callback_context: callback_context, workflow: workflow)).to be(true)
      expect(a_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT)).to have_been_made.twice
    end

    context 'when no tool call is waiting' do
      let(:ui_chat_log) do
        [{ 'message_type' => 'request', 'content' => 'Waiting for your next message.', 'tool_info' => nil }]
      end

      it 'sends nothing and reports that it has not asked yet', :aggregate_failures do
        expect(adapter.deliver_approval_request(callback_context: callback_context, workflow: workflow)).to be(false)

        expect(a_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT)).not_to have_been_made
      end
    end

    context 'when the corp has a card callback secret' do
      let(:fingerprint) { ::Ai::DuoWorkflows::PendingToolApproval.for(workflow).fingerprint }

      before do
        stub_licensed_features(dingtalk_integration: true)
        create(:dingtalk_integration, :instance, corpid: corp_id, card_callback_secret: 'card-secret')
        callback_context['status_ts'] = 'duo-open'
      end

      it 'finishes the card on the request, then turns its buttons on for this call', :aggregate_failures do
        finish = stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)
          .with do |req|
            body = Gitlab::Json.parse(req.body)
            body['outTrackId'] == 'duo-open' && body['isFinalize'] == true &&
              body['content'].include?('Use the buttons below') &&
              body['content'].exclude?(workflow.web_url)
          end
          .to_return(status: 200, body: Gitlab::Json.generate({ 'result' => true, 'success' => true }))
        token = nil
        buttons = stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_UPDATE_ENDPOINT)
          .with do |req|
            body = Gitlab::Json.parse(req.body)
            token = body.dig('cardData', 'cardParamMap', 'approval_token')
            body['outTrackId'] == 'duo-open' && body.dig('cardUpdateOptions', 'updateCardDataByKey') &&
              body.dig('cardData', 'cardParamMap', 'session_link') ==
                "[View your session in JiHu GitLab](#{workflow.web_url})"
          end
          .to_return(status: 200, body: Gitlab::Json.generate({ 'result' => true, 'success' => true }))

        expect(adapter.deliver_approval_request(callback_context: callback_context, workflow: workflow)).to be(true)
        expect(finish).to have_been_requested
        expect(buttons).to have_been_requested
        expect(described_class.approval_token_values(token)).to eq([workflow.id, fingerprint, 'duo-open'])
      end

      it 'reports the request undelivered when the buttons cannot be turned on' do
        stub_card_stream
        stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_UPDATE_ENDPOINT).to_return(status: 500, body: '')

        expect(adapter.deliver_approval_request(callback_context: callback_context, workflow: workflow)).to be(false)
      end
    end
  end

  describe '.approval_token' do
    it 'gives back what it was made from' do
      token = described_class.approval_token(1, 'fp', 'duo-card')

      expect(described_class.approval_token_values(token)).to eq([1, 'fp', 'duo-card'])
    end

    it 'reads nothing from a token it did not make #security' do
      token = described_class.approval_token(1, 'fp', 'duo-card')
      data, digest = token.split('--')
      forged = "#{data}--#{digest.reverse}"

      expect(described_class.approval_token_values(forged)).to be_nil
      expect(described_class.approval_token_values(nil)).to be_nil
    end
  end

  describe '#decision_note' do
    it 'notes a rejection only' do
      expect(adapter.decision_note(false)).to eq('Cancelled that action.')
      expect(adapter.decision_note(true)).to eq('Approved. Duo is continuing.')
    end
  end

  describe '#expire_approval_card', :clean_gitlab_redis_shared_state do
    let_it_be(:workflow) { create(:duo_workflows_workflow, :tool_call_approval_required) }

    before do
      Gitlab::Redis::SharedState.with do |redis|
        redis.set('dingtalk:duo:approval_request:duo-open', 'Create issue', ex: 60)
      end
    end

    it 'takes the buttons off and keeps what the card asked, with why', :aggregate_failures do
      hide = stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_UPDATE_ENDPOINT)
        .with(body: hash_including('outTrackId' => 'duo-open',
          'cardData' => { 'cardParamMap' => { 'approval_token' => '' } }))
        .to_return(status: 200, body: Gitlab::Json.generate({ 'result' => true, 'success' => true }))
      settle = stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)
        .with do |req|
          body = Gitlab::Json.parse(req.body)
          body['isFinalize'] == true &&
            body['content'].start_with?("Duo needs your approval before it can do this:\n\n> Create issue\n\nGone.")
        end
        .to_return(status: 200, body: Gitlab::Json.generate({ 'result' => true, 'success' => true }))

      adapter.expire_approval_card('duo-open', workflow, note: 'Gone.')

      expect(hide).to have_been_requested
      expect(settle).to have_been_requested
    end

    it 'only takes the buttons off a card a decision already settled', :aggregate_failures do
      Gitlab::Redis::SharedState.with { |redis| redis.del('dingtalk:duo:approval_request:duo-open') }
      hide = stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_UPDATE_ENDPOINT)
        .with(body: hash_including('cardData' => { 'cardParamMap' => { 'approval_token' => '' } }))
        .to_return(status: 200, body: Gitlab::Json.generate({ 'result' => true, 'success' => true }))

      adapter.expire_approval_card('duo-open', workflow)

      expect(hide).to have_been_requested
      expect(a_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)).not_to have_been_made
    end
  end

  describe '#on_progress' do
    let_it_be_with_reload(:workflow) { create(:duo_workflows_workflow) }

    let(:messages) do
      [
        { 'message_type' => 'user', 'content' => 'You received a message in a DingTalk conversation.' },
        { 'message_type' => 'agent', 'content' => 'Let me check that issue.' },
        { 'message_type' => 'tool', 'tool_info' => { 'name' => 'get_issue', 'args' => { 'issue_iid' => 18 } },
          'content' => 'Read issue #18 in project 1' }
      ]
    end

    let(:delta) do
      ::Ai::DuoWorkflows::ProgressReader::Delta.new(messages: messages, new_messages: messages, cursor: {})
    end

    let(:delta_with_flow_start) do
      flow_start = {
        'message_type' => 'tool',
        'tool_info' => nil,
        'content' => "Starting Flow: You received a message in a DingTalk conversation.\n\n<formatting>"
      }

      ::Ai::DuoWorkflows::ProgressReader::Delta.new(
        messages: [flow_start] + messages, new_messages: messages, cursor: {}
      )
    end

    it 'opens a card for the turn from the streaming template and remembers it', :aggregate_failures do
      create_request = stub_request(:post, ::Gitlab::Dingtalk::Client::CARD_CREATE_ENDPOINT)
        .with do |req|
          body = Gitlab::Json.parse(req.body)
          body['cardTemplateId'] == described_class::DEFAULT_CARD_TEMPLATE_ID &&
            body['callbackType'] == 'STREAM' &&
            body['openSpaceId'] == "dtv1.card//im_robot.#{sender_staff_id}" &&
            body['imRobotOpenDeliverModel']['spaceType'] == 'IM_ROBOT' &&
            body['outTrackId'].present? &&
            body.dig('cardData', 'cardParamMap') == { 'content' => '' }
        end
        .to_return(
          status: 200,
          body: Gitlab::Json.generate({ 'success' => true,
                                        'result' => { 'deliverResults' => [{ 'success' => true }] } })
        )
      stub_card_stream

      adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

      expect(create_request).to have_been_requested
      expect(callback_context['status_ts']).to be_present
      expect(workflow.reload.messaging_callback_context['status_ts']).to eq(callback_context['status_ts'])
    end

    it 'has DingTalk post button clicks to GitLab once the corp has a callback secret' do
      stub_licensed_features(dingtalk_integration: true)
      create(:dingtalk_integration, :instance, corpid: corp_id, card_callback_secret: 'card-secret')
      create_request = stub_request(:post, ::Gitlab::Dingtalk::Client::CARD_CREATE_ENDPOINT)
        .with(body: hash_including('callbackType' => 'HTTP', 'callbackRouteKey' => 'gitlab-duo-approval'))
        .to_return(
          status: 200,
          body: Gitlab::Json.generate({ 'success' => true,
                                        'result' => { 'deliverResults' => [{ 'success' => true }] } })
        )
      stub_card_stream

      adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

      expect(create_request).to have_been_requested
    end

    it 'gives the card a preview for the conversation list in each supported language' do
      request = stub_request(:post, ::Gitlab::Dingtalk::Client::CARD_CREATE_ENDPOINT)
        .with do |req|
          preview = Gitlab::Json.parse(req.body).dig('imRobotOpenSpaceModel', 'lastMessageI18n')
          preview.keys == %w[ZH_CN EN_US] && preview['EN_US'] == 'Message from Duo'
        end
        .to_return(
          status: 200,
          body: Gitlab::Json.generate({ 'success' => true,
                                        'result' => { 'deliverResults' => [{ 'success' => true }] } })
        )
      stub_card_stream

      adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

      expect(request).to have_been_requested
    end

    it "streams only the agent's latest words, rewriting the whole card and leaving it open" do
      stub_card_create
      request = stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)
        .with do |req|
          body = Gitlab::Json.parse(req.body)
          body['isFull'] == true && body['isFinalize'] == false && body['key'] == 'content' &&
            body['content'] == 'Let me check that issue.'
        end
        .to_return(status: 200, body: Gitlab::Json.generate({ 'success' => true }))

      adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

      expect(request).to have_been_requested
    end

    it 'keeps the processing state while the agent has said nothing yet', :aggregate_failures do
      tools_only = messages.reject { |entry| entry['message_type'] == 'agent' }
      create = stub_card_create

      adapter.on_progress(
        delta: ::Ai::DuoWorkflows::ProgressReader::Delta.new(
          messages: tools_only, new_messages: tools_only, cursor: {}
        ),
        callback_context: callback_context,
        workflow: workflow
      )

      expect(create).to have_been_requested
      expect(a_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)).not_to have_been_made
    end

    it 'leaves the flow-start entry out, goal preamble and all' do
      stub_card_create
      stream = stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)
        .with { |req| Gitlab::Json.parse(req.body)['content'].exclude?('Starting Flow') }
        .to_return(status: 200, body: Gitlab::Json.generate({ 'result' => true, 'success' => true }))

      adapter.on_progress(delta: delta_with_flow_start, callback_context: callback_context, workflow: workflow)

      expect(stream).to have_been_requested
    end

    it 'leaves the card to the request when the flow is parked on an approval' do
      pending_approval = [{ 'message_type' => 'request', 'tool_info' => { 'name' => 'create_issue_note' },
                            'content' => 'Add comment to issue #18 in project 1' }]
      parked = ::Ai::DuoWorkflows::ProgressReader::Delta.new(
        messages: messages + pending_approval, new_messages: pending_approval, cursor: {}
      )

      adapter.on_progress(delta: parked, callback_context: callback_context, workflow: workflow)

      expect(a_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)).not_to have_been_made
    end

    it 'renders this turn only, not the answers of the ones before it' do
      session = [
        { 'message_type' => 'agent', 'content' => 'An answer from two turns ago.' },
        { 'message_type' => 'user', 'content' => 'You received a message in a DingTalk conversation.' },
        { 'message_type' => 'agent', 'content' => 'The answer being written now.' }
      ]
      stub_card_create
      request = stub_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)
        .with { |req| Gitlab::Json.parse(req.body)['content'] == 'The answer being written now.' }
        .to_return(status: 200, body: Gitlab::Json.generate({ 'result' => true, 'success' => true }))

      adapter.on_progress(
        delta: ::Ai::DuoWorkflows::ProgressReader::Delta.new(
          messages: session, new_messages: session.last(1), cursor: {}
        ),
        callback_context: callback_context,
        workflow: workflow
      )

      expect(request).to have_been_requested
    end

    it 'reuses the card once the turn has one', :aggregate_failures do
      callback_context['status_ts'] = 'duo-existing'
      stream = stub_card_stream

      adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

      expect(a_request(:post, ::Gitlab::Dingtalk::Client::CARD_CREATE_ENDPOINT)).not_to have_been_made
      expect(stream).to have_been_requested
    end

    it 'does not claim a card when delivery was refused', :aggregate_failures do
      stub_request(:post, ::Gitlab::Dingtalk::Client::CARD_CREATE_ENDPOINT)
        .to_return(
          status: 200,
          body: Gitlab::Json.generate({ 'success' => true,
                                        'result' => { 'deliverResults' => [{ 'success' => false }] } })
        )

      adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

      expect(callback_context['status_ts']).to be_nil
      expect(a_request(:put, ::Gitlab::Dingtalk::Client::CARD_STREAMING_ENDPOINT)).not_to have_been_made
    end

    context 'for a group chat' do
      let(:conversation_type) { '2' }

      it 'delivers the card to the conversation, with the same preview' do
        request = stub_request(:post, ::Gitlab::Dingtalk::Client::CARD_CREATE_ENDPOINT)
          .with do |req|
            body = Gitlab::Json.parse(req.body)
            body['openSpaceId'] == "dtv1.card//im_group.#{conversation_id}" &&
              body['imGroupOpenDeliverModel'].present? &&
              body.dig('imGroupOpenSpaceModel', 'lastMessageI18n', 'EN_US') == 'Message from Duo'
          end
          .to_return(
            status: 200,
            body: Gitlab::Json.generate({ 'success' => true,
                                          'result' => { 'deliverResults' => [{ 'success' => true }] } })
          )
        stub_card_stream

        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

        expect(request).to have_been_requested
      end
    end
  end

  describe '#start_workhorse_flow' do
    let_it_be(:user) { create(:user) }
    let_it_be(:project) { create(:project) }

    let(:privileges) { ::Ai::DuoWorkflows::Workflow::AgentPrivileges }
    let(:flow) { ::Ai::Catalog::FoundationalFlow.dingtalk_assistant_v1 }
    let(:bundle) do
      ::Ai::Messaging::Adapters::Base::TriggerBundle.new(
        current_user: user, project: project, flow_reference: flow.foundational_flow_reference,
        goal: 'Explain this issue', source_type: :dingtalk
      )
    end

    it 'runs the DingTalk flow and leaves the deciding privileges unapproved', :aggregate_failures do
      expect(::Ai::DuoWorkflows::CreateWorkflowService).to receive(:new) do |args|
        params = args[:params]

        expect(args[:container]).to eq(project)
        expect(params[:workflow_definition]).to eq('dingtalk_assistant/v1')
        expect(params[:environment]).to eq(flow.environment)
        expect(params[:agent_privileges])
          .to include(privileges::READ_WRITE_GITLAB, privileges::START_FLOWS)
        expect(params[:pre_approved_agent_privileges]).to eq([privileges::READ_ONLY_GITLAB])

        instance_double(::Ai::DuoWorkflows::CreateWorkflowService, execute: ServiceResponse.success)
      end

      adapter.send(:start_workhorse_flow, bundle, adapter.build_callback_context)
    end
  end
end
