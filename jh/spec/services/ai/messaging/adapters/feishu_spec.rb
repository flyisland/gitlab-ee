# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Messaging::Adapters::Feishu, :clean_gitlab_redis_shared_state, feature_category: :duo_agent_platform do
  let(:api) { 'https://open.feishu.cn/open-apis' }
  let(:callback_context) do
    {
      'adapter' => 'feishu',
      'app_id' => 'cli_app',
      'chat_id' => 'oc_chat',
      'sender_id' => 'feishu-user-1',
      'message_id' => 'om_question'
    }
  end

  subject(:adapter) do
    described_class.new(app_id: 'cli_app', chat_id: 'oc_chat', sender_id: 'feishu-user-1', message_id: 'om_question')
  end

  before do
    allow(::Gitlab::Feishu::BotApp).to receive(:access_token).and_return('tenant-token')
    stub_request(:post, "#{api}/im/v1/images").to_return(ok(image_key: 'img_waiting'))
  end

  def ok(data = {})
    { status: 200, body: Gitlab::Json.generate(code: 0, msg: 'ok', data: data) }
  end

  def refused(code)
    { status: 400, body: Gitlab::Json.generate(code: code, msg: 'refused') }
  end

  def stub_create_card(card_id = 'card_new')
    stub_request(:post, "#{api}/cardkit/v1/cards").to_return(ok(card_id: card_id))
  end

  def stub_reply(message_id = 'om_question')
    stub_request(:post, "#{api}/im/v1/messages/#{message_id}/reply").to_return(ok(message_id: 'om_answer'))
  end

  def stub_update_card(card_id = 'card_open')
    stub_request(:put, "#{api}/cardkit/v1/cards/#{card_id}").to_return(ok)
  end

  def stub_stream(card_id = 'card_open')
    stub_request(:put, "#{api}/cardkit/v1/cards/#{card_id}/elements/duo_content/content").to_return(ok)
  end

  # The card JSON 2.0 a full update sent, parsed back out of its envelope.
  def sent_card(request)
    Gitlab::Json.parse(Gitlab::Json.parse(request.body)['card']['data'])
  end

  def card_text(card)
    card.dig('body', 'elements', 0, 'content')
  end

  # The smaller last line of a card.
  def card_footer(card)
    footer = card.dig('body', 'elements').last
    footer['content'] if footer['text_size'] == 'notation'
  end

  describe 'surface properties' do
    it 'is a private, live chat surface', :aggregate_failures do
      expect(described_class.adapter_key).to eq('feishu')
      expect(described_class.private_to_invoker?).to be(true)
      expect(described_class.supports_live_progress?).to be(true)
    end
  end

  describe '.from_callback_context and #build_callback_context' do
    it 'round-trips the callback context' do
      context = callback_context.merge('thread_id' => 'omt_topic', 'turn_token' => 'token')

      expect(described_class.from_callback_context(context).build_callback_context)
        .to eq(context.except('adapter'))
    end
  end

  describe '#on_request_received' do
    it 'replies to the question with a streaming card and keeps its id', :aggregate_failures do
      create_request = stub_create_card.with do |request|
        card = Gitlab::Json.parse(Gitlab::Json.parse(request.body)['data'])
        card['schema'] == '2.0' && card.dig('config', 'streaming_mode') == true &&
          card.dig('config', 'update_multi') == true
      end
      reply_request = stub_reply.with(
        body: hash_including(
          'msg_type' => 'interactive',
          'content' => Gitlab::Json.generate(type: 'card', data: { card_id: 'card_new' }),
          'uuid' => 'duo-card-card_new'
        )
      )

      adapter.on_request_received

      expect(create_request).to have_been_requested
      expect(reply_request).to have_been_requested
      expect(adapter.card_opened?).to be(true)
      expect(adapter.build_callback_context['status_ts']).to eq('card_new')
    end

    it 'shows the animated ellipsis next to the text while the card waits', :aggregate_failures do
      card = nil
      stub_create_card('card_open').with { |req| card = Gitlab::Json.parse(Gitlab::Json.parse(req.body)['data']) }
      stub_reply

      adapter.on_request_received

      row = card.dig('body', 'elements', 0)
      expect(row['tag']).to eq('column_set')
      expect(row.dig('columns', 0, 'elements', 0))
        .to include('element_id' => 'duo_content', 'content' => 'Duo is working on it')
      expect(row.dig('columns', 1, 'elements', 0)).to include('tag' => 'img', 'img_key' => 'img_waiting')
    end

    it 'says it in words when Feishu refuses the image', :aggregate_failures do
      stub_request(:post, "#{api}/im/v1/images").to_return(refused(234001))
      card = nil
      stub_create_card('card_open').with { |req| card = Gitlab::Json.parse(Gitlab::Json.parse(req.body)['data']) }
      stub_reply

      adapter.on_request_received

      expect(card_text(card)).to eq('Duo is working on it…')
      expect(adapter.card_opened?).to be(true)
    end

    it 'uploads the animation once, and after a refusal waits before trying again',
      :use_clean_rails_memory_store_caching, :aggregate_failures do
      stub_create_card('card_open')
      stub_reply
      refused_upload = stub_request(:post, "#{api}/im/v1/images").to_return(refused(234001))

      2.times { adapter.on_request_received }

      expect(refused_upload).to have_been_requested.once
    end

    it 'carries on without a card when Feishu refuses one', :aggregate_failures do
      stub_request(:post, "#{api}/cardkit/v1/cards").to_return(refused(10002))

      adapter.on_request_received

      expect(adapter.card_opened?).to be(false)
      expect(adapter.build_callback_context).not_to have_key('status_ts')
      expect(a_request(:post, "#{api}/im/v1/messages/om_question/reply")).not_to have_been_made
    end
  end

  describe '#deliver_result' do
    let_it_be(:workflow) { create(:duo_workflows_workflow) }

    let(:session_store) do
      ::Gitlab::Feishu::DuoSessionStore.new(
        app_id: 'cli_app', chat_id: 'oc_chat', sender_id: 'feishu-user-1', user_id: workflow.user_id
      )
    end

    let(:turn_context) { callback_context.merge('turn_token' => session_store.start_turn!('the question')) }

    def deliver(context, message = 'Here is the answer')
      adapter.deliver_result(callback_context: context, message: message, workflow: workflow)
    end

    context 'when the turn opened a card' do
      let(:context) { turn_context.merge('status_ts' => 'card_open') }

      it 'settles the card with the answer and the session link', :aggregate_failures do
        request = stub_update_card

        expect(deliver(context)).to be(true)

        card = nil
        expect(a_request(:put, "#{api}/cardkit/v1/cards/card_open").with { |req| card = sent_card(req) })
          .to have_been_made
        expect(card.dig('config', 'streaming_mode')).to be(false)
        expect(card_text(card)).to eq('Here is the answer')
        expect(card_footer(card)).to include(workflow.web_url)
        expect(request).to have_been_requested
        expect(session_store.transcript.pluck('text')).to eq(['the question', 'Here is the answer'])
      end

      it 'falls back to a rich text reply that a retry cannot post twice', :aggregate_failures do
        stub_request(:put, "#{api}/cardkit/v1/cards/card_open").to_return(refused(200750))
        reply = stub_reply.with(
          body: hash_including('msg_type' => 'post', 'uuid' => "duo-result-#{workflow.id}-#{context['turn_token']}")
        )

        2.times { expect(deliver(context)).to be(true) }

        expect(reply).to have_been_requested.twice
      end

      it 'keeps the session link when the answer is too long for a card' do
        stub_update_card

        deliver(context, '长' * 20_000)

        card = nil
        expect(a_request(:put, "#{api}/cardkit/v1/cards/card_open").with { |req| card = sent_card(req) })
          .to have_been_made
        expect(card_text(card).bytesize).to be <= described_class::TEXT_MAX_BYTES
        expect(card_footer(card)).to include(workflow.web_url)
      end
    end

    context 'without a card' do
      it 'replies with rich text' do
        request = stub_reply.with do |req|
          body = Gitlab::Json.parse(req.body)
          content = Gitlab::Json.parse(body['content'])

          text = content.dig('zh_cn', 'content', 0, 0, 'text')
          body['msg_type'] == 'post' && content.dig('zh_cn', 'content', 0, 0, 'tag') == 'md' &&
            text.include?('Here is the answer') && text.end_with?("(#{workflow.web_url})")
        end

        expect(deliver(turn_context)).to be(true)
        expect(request).to have_been_requested
      end

      it 'reports a failed reply so the delivery is attempted again', :aggregate_failures do
        stub_request(:post, "#{api}/im/v1/messages/om_question/reply").to_return(status: 503, body: '')

        expect(deliver(turn_context)).to be(false)
        expect(session_store.transcript.pluck('text')).to eq(['the question'])
      end
    end
  end

  describe '#on_progress' do
    let_it_be_with_reload(:workflow) { create(:duo_workflows_workflow) }

    let(:messages) do
      [
        { 'message_type' => 'user', 'content' => 'You received a message in a Feishu conversation.' },
        { 'message_type' => 'agent', 'content' => 'Let me check that issue.' },
        { 'message_type' => 'tool', 'content' => 'Read issue #18 in project 1' }
      ]
    end

    let(:delta) do
      ::Ai::DuoWorkflows::ProgressReader::Delta.new(messages: messages, new_messages: messages, cursor: {})
    end

    def progress(context)
      adapter.on_progress(delta: delta, callback_context: context, workflow: workflow)
    end

    it 'opens a card on the first tick, persists it, and streams the agent text only', :aggregate_failures do
      stub_create_card('card_open')
      stub_reply
      replaced = stub_update_card.with { |req| card_text(sent_card(req)) == 'Let me check that issue.' }
      stream = stub_stream.with(body: hash_including('content' => 'Let me check that issue.'))

      progress(callback_context.dup)
      progress(callback_context.merge('status_ts' => 'card_open'))

      expect(replaced).to have_been_requested.once
      expect(stream).to have_been_requested.once
      expect(workflow.reload.messaging_callback_context['status_ts']).to eq('card_open')
    end

    it 'tries the full replacement again on the next frame when Feishu refuses it' do
      stub_create_card('card_open')
      stub_reply
      replace = stub_request(:put, "#{api}/cardkit/v1/cards/card_open")
        .to_return(refused(200750)).then.to_return(ok)

      progress(callback_context.dup)
      progress(callback_context.merge('status_ts' => 'card_open'))

      expect(replace).to have_been_requested.twice
    end

    it 'gives every update of a card a higher sequence than the last' do
      sequences = []
      stub_stream.with { |req| sequences << Gitlab::Json.parse(req.body)['sequence'] }
      context = callback_context.merge('status_ts' => 'card_open')

      3.times { progress(context) }

      expect(sequences).to eq([1, 2, 3])
    end

    it 'leaves the card to a pending approval request' do
      parked = ::Ai::DuoWorkflows::ProgressReader::Delta.new(
        messages: messages + [
          { 'message_type' => 'request', 'content' => 'Create issue', 'tool_info' => { 'a' => 1 } }
        ],
        new_messages: [], cursor: {}
      )

      adapter.on_progress(delta: parked, callback_context: callback_context.merge('status_ts' => 'card_open'),
        workflow: workflow)

      expect(a_request(:put, /cardkit/)).not_to have_been_made
    end

    it 'reopens streaming with a full update once Feishu closed it on its own', :aggregate_failures do
      stub_request(:put, "#{api}/cardkit/v1/cards/card_open/elements/duo_content/content")
        .to_return(refused(200850))
      update = stub_update_card

      progress(callback_context.merge('status_ts' => 'card_open'))

      card = nil
      expect(update.with { |req| card = sent_card(req) }).to have_been_requested
      expect(card.dig('config', 'streaming_mode')).to be(true)
      expect(card_text(card)).to eq('Let me check that issue.')
    end

    # A frame that found streaming closed by the timeout, then lost the race
    # to the final answer between its two steps.
    it 'does not reopen a card settled while the frame was in flight' do
      stub_request(:put, "#{api}/cardkit/v1/cards/card_open/elements/duo_content/content")
        .to_return(refused(200850))
      allow(adapter).to receive(:next_sequence).and_wrap_original do |original, card_id|
        original.call(card_id).tap do
          Gitlab::Redis::SharedState.with { |redis| redis.set("feishu:duo_card:{#{card_id}}:settled", 1) }
        end
      end

      progress(callback_context.merge('status_ts' => 'card_open'))

      expect(a_request(:put, "#{api}/cardkit/v1/cards/card_open")).not_to have_been_made
    end

    it 'never writes over a card already settled with the answer' do
      stub_update_card
      adapter.deliver_error(callback_context: callback_context.merge('status_ts' => 'card_open'), error: :flow_failed)
      WebMock.reset_executed_requests!

      progress(callback_context.merge('status_ts' => 'card_open'))

      expect(a_request(:put, /cardkit/)).not_to have_been_made
    end
  end

  describe '#deliver_error' do
    it 'settles the card with the error' do
      request = stub_update_card.with do |req|
        card = sent_card(req)
        card.dig('config', 'streaming_mode') == false && card_text(card).include?('Something went wrong')
      end

      adapter.deliver_error(callback_context: callback_context.merge('status_ts' => 'card_open'), error: :flow_failed)

      expect(request).to have_been_requested
    end

    it 'replies in words without a card and never raises' do
      stub_request(:post, "#{api}/im/v1/messages/om_question/reply").to_return(status: 500, body: '')

      expect(adapter.deliver_error(callback_context: callback_context, error: :flow_failed)).to be_nil
    end
  end

  describe '#deliver_approval_request' do
    let_it_be(:workflow) { create(:duo_workflows_workflow, :tool_call_approval_required) }

    let(:pending_call) do
      {
        'message_type' => 'request',
        'content' => 'Add comment to issue #18 in project 1',
        'message_id' => 'call-abc',
        'tool_info' => { 'name' => 'create_issue_note', 'args' => { 'body' => 'hi' } }
      }
    end

    before do
      allow(workflow).to receive(:latest_ui_chat_log).and_return([pending_call])
    end

    def ask(context)
      adapter.deliver_approval_request(callback_context: context, workflow: workflow)
    end

    it 'settles the turn card with the request, once per pending call', :aggregate_failures do
      request = stub_update_card.with do |req|
        card = sent_card(req)
        card.dig('config', 'streaming_mode') == false &&
          card_text(card).include?('Add comment to issue #18 in project 1') &&
          card_footer(card).include?(workflow.web_url)
      end
      context = callback_context.merge('status_ts' => 'card_open')

      expect(ask(context)).to be(true)
      expect(ask(context)).to be(false)
      expect(request).to have_been_requested.once
    end

    it 'puts approve and reject buttons for this very call on the card', :aggregate_failures do
      fingerprint = ::Ai::DuoWorkflows::PendingToolApproval.for(workflow).fingerprint
      buttons = []
      stub_update_card.with do |req|
        buttons = sent_card(req).dig('body', 'elements', 1, 'columns').map { |column| column['elements'].first }
      end

      ask(callback_context.merge('status_ts' => 'card_open'))

      expect(buttons.pluck('tag')).to eq(%w[button button])
      expect(buttons.map { |button| button.dig('behaviors', 0, 'value') }).to eq([
        { 'duo_approval' => 'approve', 'workflow_id' => workflow.id, 'card_id' => 'card_open',
          'fingerprint' => fingerprint },
        { 'duo_approval' => 'reject', 'workflow_id' => workflow.id, 'card_id' => 'card_open',
          'fingerprint' => fingerprint }
      ])
    end

    it 'replies with the request when the card cannot take it' do
      stub_request(:put, "#{api}/cardkit/v1/cards/card_open").to_return(refused(200740))
      reply = stub_reply.with(
        body: hash_including('msg_type' => 'post', 'uuid' => a_string_starting_with('duo-approval-'))
      )

      expect(ask(callback_context.merge('status_ts' => 'card_open'))).to be(true)
      expect(reply).to have_been_requested
    end

    it 'replies under a uuid of its own for each pending call, even with the same text' do
      uuids = []
      stub_reply.with { |req| uuids << Gitlab::Json.parse(req.body)['uuid'] }

      ask(callback_context)
      allow(workflow).to receive(:latest_ui_chat_log).and_return([pending_call.merge('message_id' => 'call-def')])
      ask(callback_context)

      expect(uuids.uniq.size).to eq(2)
    end
  end

  describe '#roll_card_for_decision' do
    let_it_be_with_reload(:workflow) do
      create(:duo_workflows_workflow, :tool_call_approval_required,
        messaging_callback_context: {
          'adapter' => 'feishu', 'app_id' => 'cli_app', 'chat_id' => 'oc_chat', 'sender_id' => 'feishu-user-1',
          'message_id' => 'om_earlier', 'status_ts' => 'card_open'
        })
    end

    subject(:adapter) do
      described_class.new(app_id: 'cli_app', chat_id: 'oc_chat', sender_id: 'feishu-user-1', message_id: 'om_decision')
    end

    it 'settles the parked card and opens the next one under the decision', :aggregate_failures do
      settle = stub_update_card
      stub_create_card('card_next')
      reply = stub_reply('om_decision')

      expect(adapter.roll_card_for_decision(workflow: workflow, note: 'Cancelled that action.')).to be(true)

      expect(settle).to have_been_requested
      expect(reply).to have_been_requested
      expect(workflow.reload.messaging_callback_context)
        .to include('status_ts' => 'card_next', 'message_id' => 'om_decision')
    end

    it 'leaves the request and what was decided on the card, with nothing left to act on' do
      allow(workflow).to receive(:latest_ui_chat_log).and_return(
        [{ 'message_type' => 'request', 'message_id' => 'call-1', 'tool_info' => { 'name' => 'create_issue' },
           'content' => 'Create issue' }]
      )
      settle = stub_update_card.with do |req|
        text = card_text(sent_card(req))
        text.include?("> Create issue\n\nApproved. Duo is continuing.") && text.exclude?('Reply "approve"')
      end
      stub_create_card('card_next')
      stub_reply('om_decision')

      adapter.roll_card_for_decision(workflow: workflow, note: 'Approved. Duo is continuing.')

      expect(settle).to have_been_requested
    end

    it 'does nothing when the turn had no card' do
      workflow.update!(messaging_callback_context: workflow.messaging_callback_context.except('status_ts'))

      expect(adapter.roll_card_for_decision(workflow: workflow)).to be(false)
    end

    it 'leaves nothing for a late click to expire', :aggregate_failures do
      stub_update_card
      stub_create_card('card_next')
      stub_reply('om_decision')
      Gitlab::Redis::SharedState.with do |redis|
        redis.set('feishu:duo_card:{card_open}:approval_request', 'the request')
      end

      adapter.roll_card_for_decision(workflow: workflow)

      expect(adapter.expire_approval_card('card_open', workflow)).to be_nil
    end
  end

  describe '#expire_approval_card' do
    let_it_be(:workflow) { create(:duo_workflows_workflow) }

    it 'takes the buttons off a card still asking, keeping its request', :aggregate_failures do
      Gitlab::Redis::SharedState.with do |redis|
        redis.set('feishu:duo_card:{card_open}:approval_request', 'the request')
      end
      settle = stub_update_card.with do |req|
        card = sent_card(req)
        card['body']['elements'].none? { |element| element['tag'] == 'column_set' } &&
          card_text(card).include?('> the request') &&
          card_text(card).include?('no longer waiting for your decision')
      end

      adapter.expire_approval_card('card_open', workflow)
      adapter.expire_approval_card('card_open', workflow)

      expect(settle).to have_been_requested.once
    end
  end

  describe '#on_approval_required' do
    let_it_be(:workflow) { create(:duo_workflows_workflow) }

    it 'hands the notice to the worker' do
      expect(::Ai::Messaging::ApprovalNoticeWorker).to receive(:perform_async).with(workflow.id)

      adapter.on_approval_required(callback_context: callback_context, workflow: workflow)
    end
  end

  describe '#start_workhorse_flow' do
    let_it_be(:user) { create(:user) }
    let_it_be(:project) { create(:project) }

    let(:privileges) { ::Ai::DuoWorkflows::Workflow::AgentPrivileges }
    let(:flow) { ::Ai::Catalog::FoundationalFlow.feishu_assistant_v1 }
    let(:bundle) do
      ::Ai::Messaging::Adapters::Base::TriggerBundle.new(
        current_user: user, project: project, flow_reference: flow.foundational_flow_reference,
        goal: 'Explain this issue', source_type: :feishu
      )
    end

    it 'runs the Feishu flow and leaves the deciding privileges unapproved', :aggregate_failures do
      expect(::Ai::DuoWorkflows::CreateWorkflowService).to receive(:new) do |args|
        params = args[:params]

        expect(params[:workflow_definition]).to eq('feishu_assistant/v1')
        expect(params[:source_type]).to eq(:feishu)
        expect(params[:agent_privileges]).to include(privileges::READ_WRITE_GITLAB, privileges::START_FLOWS)
        expect(params[:pre_approved_agent_privileges]).to eq([privileges::READ_ONLY_GITLAB])
        expect(params[:messaging_callback_context]).to include('adapter' => 'feishu', 'message_id' => 'om_question')

        instance_double(::Ai::DuoWorkflows::CreateWorkflowService, execute: ServiceResponse.success)
      end

      adapter.send(:start_workhorse_flow, bundle, adapter.build_callback_context)
    end
  end
end
