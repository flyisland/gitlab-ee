# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Messaging::Adapters::Slack, feature_category: :duo_agent_platform do
  include ExclusiveLeaseHelpers

  let_it_be(:slack_installation) { create(:slack_integration) }

  let(:team_id) { slack_installation.team_id }
  let(:channel_id) { 'C0123ABC' }
  let(:thread_ts) { '1234567890.123456' }
  let(:message_ts) { '1234567890.123456' }
  let(:user_id) { 'U0123ABC' }

  let(:callback_context) do
    {
      'adapter' => 'slack',
      'team_id' => team_id,
      'channel_id' => channel_id,
      'thread_ts' => thread_ts,
      'message_ts' => message_ts,
      'user_id' => user_id
    }
  end

  let(:reactions_add_url) { "#{Slack::API::BASE_URL}/reactions.add" }
  let(:reactions_remove_url) { "#{Slack::API::BASE_URL}/reactions.remove" }
  let(:post_message_url) { "#{Slack::API::BASE_URL}/chat.postMessage" }
  let(:update_message_url) { "#{Slack::API::BASE_URL}/chat.update" }
  let(:set_status_url) { "#{Slack::API::BASE_URL}/assistant.threads.setStatus" }
  let(:post_ephemeral_url) { "#{Slack::API::BASE_URL}/chat.postEphemeral" }

  subject(:adapter) do
    described_class.new(
      team_id: team_id,
      channel_id: channel_id,
      thread_ts: thread_ts,
      message_ts: message_ts,
      user_id: user_id
    )
  end

  before do
    stub_request(:post, reactions_add_url).to_return(
      status: 200, body: { ok: true }.to_json, headers: { 'Content-Type' => 'application/json' }
    )
    stub_request(:post, reactions_remove_url).to_return(
      status: 200, body: { ok: true }.to_json, headers: { 'Content-Type' => 'application/json' }
    )
    stub_request(:post, post_message_url).to_return(
      status: 200, body: { ok: true, ts: '111.222' }.to_json, headers: { 'Content-Type' => 'application/json' }
    )
    stub_request(:post, update_message_url).to_return(
      status: 200, body: { ok: true }.to_json, headers: { 'Content-Type' => 'application/json' }
    )
    stub_request(:post, set_status_url).to_return(
      status: 200, body: { ok: true }.to_json, headers: { 'Content-Type' => 'application/json' }
    )
    stub_request(:post, post_ephemeral_url).to_return(
      status: 200, body: { ok: true }.to_json, headers: { 'Content-Type' => 'application/json' }
    )
  end

  describe '.adapter_key' do
    it { expect(described_class.adapter_key).to eq('slack') }
  end

  describe '.supports_live_progress?' do
    it { expect(described_class.supports_live_progress?).to be(true) }
  end

  describe '.from_callback_context' do
    it 'reconstructs an adapter from callback context' do
      restored = described_class.from_callback_context(callback_context)

      expect(restored).to be_a(described_class)
      expect(restored.build_callback_context).to eq(
        'team_id' => team_id,
        'channel_id' => channel_id,
        'thread_ts' => thread_ts,
        'message_ts' => message_ts,
        'user_id' => user_id
      )
    end
  end

  describe '#build_callback_context' do
    it 'returns Slack delivery coordinates' do
      expect(adapter.build_callback_context).to eq(
        'team_id' => team_id,
        'channel_id' => channel_id,
        'thread_ts' => thread_ts,
        'message_ts' => message_ts,
        'user_id' => user_id
      )
    end
  end

  describe '#per_turn_reset' do
    it 'keeps status_ts, so a resumed run edits the same message' do
      expect(adapter.per_turn_reset).to eq('delivered_at' => nil)
    end
  end

  describe '#on_request_received' do
    it 'adds eyes reaction to the mention message' do
      adapter.on_request_received

      expect(WebMock).to have_requested(:post, reactions_add_url).with(
        body: hash_including(
          'name' => 'eyes',
          'channel' => channel_id,
          'timestamp' => message_ts
        )
      )
    end

    it 'sets a rotating thinking status via assistant.threads.setStatus' do
      adapter.on_request_received

      expect(WebMock).to have_requested(:post, set_status_url).with { |req|
        body = ::Gitlab::Json.safe_parse(req.body)
        body['channel_id'] == channel_id &&
          body['thread_ts'] == thread_ts &&
          body['loading_messages'].is_a?(Array) &&
          body['loading_messages'].length > 1
      }
    end

    it 'does not post a message (the status indicator is sufficient)' do
      adapter.on_request_received

      expect(WebMock).not_to have_requested(:post, post_message_url)
    end

    it 'does not stash a status_ts (no message was posted)' do
      adapter.on_request_received

      expect(adapter.build_callback_context).not_to include('status_ts')
    end
  end

  describe '#on_flow_started' do
    let(:workflow) { create(:duo_workflows_workflow) }

    it 'records the session url and persists it without posting a message', :aggregate_failures do
      allow(workflow).to receive(:web_url).and_return('https://gl.test/s/1')

      adapter.on_flow_started(callback_context: callback_context, workflow: workflow)

      expect(WebMock).not_to have_requested(:post, post_message_url)
      expect(workflow.reload.messaging_callback_context).to include('session_url' => 'https://gl.test/s/1')
    end

    it 'persists the workflow id for the feedback buttons' do
      adapter.on_flow_started(callback_context: callback_context, workflow: workflow)

      expect(workflow.reload.messaging_callback_context).to include('workflow_id' => workflow.id)
    end

    it 'omits session_url when the workflow has no session page to link' do
      allow(workflow).to receive(:web_url).and_return(nil)

      adapter.on_flow_started(callback_context: callback_context, workflow: workflow)

      expect(workflow.reload.messaging_callback_context).not_to include('session_url')
    end
  end

  describe '#on_approval_required' do
    let(:workflow) { create(:duo_workflows_workflow, :tool_call_approval_required) }

    let(:request_entry) do
      {
        'message_type' => 'request',
        'message_id' => 'toolu_01issue',
        'content' => 'Tool create_issue requires approval',
        'tool_info' => { 'name' => 'create_issue', 'args' => { 'title' => 'Bug report', 'body' => 'secret text' } }
      }
    end

    let(:fingerprint) { Ai::DuoWorkflows::PendingToolApproval.new(request_entry).fingerprint }

    let(:delta) do
      Ai::DuoWorkflows::ProgressReader::Delta.new(messages: [request_entry], new_messages: [request_entry], cursor: {})
    end

    before do
      allow(workflow).to receive(:latest_ui_chat_log).and_return([request_entry])
      allow_next_instance_of(Ai::DuoWorkflows::ProgressReader) do |reader|
        allow(reader).to receive(:delta_since).and_return(delta)
      end
    end

    subject(:on_approval_required) do
      adapter.on_approval_required(callback_context: callback_context, workflow: workflow)
    end

    def card_in(body)
      body['blocks'].detect { |b| b['type'] == 'container' }
    end

    def plan_in(body)
      body['blocks'].detect { |b| b['type'] == 'plan' }
    end

    context 'when no progress message exists yet' do
      it 'opens the progress message with the card as its only block, built for the requester',
        :aggregate_failures do
        card = instance_double(described_class::ToolApprovalCard, blocks: [{ type: 'container', block_id: 'x' }])
        expect(described_class::ToolApprovalCard).to receive(:new)
          .with(kind_of(Ai::DuoWorkflows::PendingToolApproval), workflow_id: workflow.id, requester_id: user_id)
          .and_return(card)

        on_approval_required

        expect(WebMock).to have_requested(:post, post_message_url).with { |req|
          body = ::Gitlab::Json::SafeParser.parse(req.body)

          body['channel'] == channel_id &&
            body['thread_ts'] == thread_ts &&
            body['text'] == 'GitLab Duo needs your approval to run: `create_issue`' &&
            body['blocks'] == [{ 'type' => 'container', 'block_id' => 'x' }]
        }
        expect(WebMock).not_to have_requested(:post, update_message_url)
      end

      it 'renders the card inline with the tool arguments and both decision buttons' do
        on_approval_required

        expect(WebMock).to have_requested(:post, post_message_url).with { |req|
          card = card_in(::Gitlab::Json::SafeParser.parse(req.body))
          buttons = card['child_blocks'].last['elements']

          card['block_id'] == "duo_approval_#{fingerprint}" &&
            card['subtitle']['text'] == "Waiting for <@#{user_id}>" &&
            req.body.include?('Bug report') &&
            buttons.map { |b| b['action_id'] } == %w[duo_approval_approve duo_approval_deny] &&
            buttons.map { |b| b['value'] }.uniq == ["#{workflow.id}:#{fingerprint}"]
        }
      end

      it 'does not post an ephemeral' do
        on_approval_required

        expect(WebMock).not_to have_requested(:post, post_ephemeral_url)
      end

      it 'records the new message as the progress message, claims the fingerprint and reports success',
        :aggregate_failures do
        expect(on_approval_required).to be(true)

        expect(workflow.reload.messaging_callback_context).to include(
          'status_ts' => '111.222',
          'pending_approval' => fingerprint
        )
      end

      context 'when the agent said something in this turn' do
        let(:agent_entry) do
          { 'message_type' => 'agent', 'message_id' => 'agent_01', 'content' => 'I will open the issue for you.' }
        end

        let(:delta) do
          Ai::DuoWorkflows::ProgressReader::Delta.new(
            messages: [agent_entry, request_entry], new_messages: [agent_entry, request_entry], cursor: {}
          )
        end

        it 'puts the agent text in a plan titled with the pause, above the card', :aggregate_failures do
          on_approval_required

          expect(WebMock).to have_requested(:post, post_message_url).with { |req|
            body = ::Gitlab::Json::SafeParser.parse(req.body)

            body['blocks'].map { |b| b['type'] } == %w[plan container] &&
              plan_in(body)['title'] == 'Waiting for approval' &&
              plan_in(body).dig('tasks', 0, 'title') == 'I will open the issue for you.' &&
              card_in(body)['block_id'] == "duo_approval_#{fingerprint}"
          }
        end
      end

      context 'when the agent text belongs to an earlier turn' do
        let(:agent_entry) do
          { 'message_type' => 'agent', 'message_id' => 'agent_01', 'content' => 'Old turn' }
        end

        let(:delta) do
          Ai::DuoWorkflows::ProgressReader::Delta.new(
            messages: [agent_entry, request_entry], new_messages: [request_entry], cursor: {}
          )
        end

        it 'posts only the card' do
          on_approval_required

          expect(WebMock).to have_requested(:post, post_message_url).with { |req|
            ::Gitlab::Json::SafeParser.parse(req.body)['blocks'].map { |b| b['type'] } == %w[container]
          }
        end
      end

      context 'when another job is already opening the progress message' do
        before do
          stub_exclusive_lease_taken("duo_slack_progress_message:#{workflow.id}")
        end

        it 'posts nothing, leaves the fingerprint unclaimed and reports failure so the worker retries',
          :aggregate_failures do
          expect(on_approval_required).to be(false)

          expect(WebMock).not_to have_requested(:post, post_message_url)
          expect(workflow.reload.messaging_callback_context).to be_blank
        end
      end
    end

    context 'when a progress message already exists' do
      before do
        callback_context['status_ts'] = '999.000'
      end

      it 'edits it to carry the card instead of posting a reply', :aggregate_failures do
        on_approval_required

        expect(WebMock).not_to have_requested(:post, post_message_url)
        expect(WebMock).to have_requested(:post, update_message_url).with { |req|
          body = ::Gitlab::Json::SafeParser.parse(req.body)

          body['ts'] == '999.000' &&
            body['text'] == 'GitLab Duo needs your approval to run: `create_issue`' &&
            body['blocks'].map { |b| b['type'] } == %w[container]
        }
      end

      it 'claims the fingerprint without writing back its copy of status_ts', :aggregate_failures do
        expect(on_approval_required).to be(true)

        expect(workflow.reload.messaging_callback_context).to include('pending_approval' => fingerprint)
        expect(workflow.reload.messaging_callback_context).not_to include('status_ts')
      end

      context 'when the run has a todo list' do
        let(:todo_entry) do
          {
            'message_type' => 'tool',
            'tool_info' => {
              'name' => 'todo_write',
              'args' => { 'todos' => [{ 'status' => 'in_progress', 'description' => 'Open the issue' }] }
            }
          }
        end

        before do
          allow(workflow).to receive(:latest_ui_chat_log).and_return([todo_entry, request_entry])
        end

        it 'keeps the plan, switches its title to the pause and appends the card', :aggregate_failures do
          on_approval_required

          expect(WebMock).to have_requested(:post, update_message_url).with { |req|
            body = ::Gitlab::Json::SafeParser.parse(req.body)

            body['blocks'].map { |b| b['type'] } == %w[plan container] &&
              plan_in(body)['title'] == 'Waiting for approval (0/1 done)' &&
              card_in(body)['block_id'] == "duo_approval_#{fingerprint}"
          }
        end
      end

      context 'when the edit fails' do
        before do
          stub_request(:post, update_message_url).to_return(
            status: 200, body: { ok: false, error: 'ratelimited' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
        end

        it 'does not claim the fingerprint and reports failure so the worker retries the edit',
          :aggregate_failures do
          expect(on_approval_required).to be(false)

          expect(WebMock).not_to have_requested(:post, post_message_url)
          expect(workflow.reload.messaging_callback_context).to be_blank
        end
      end

      context 'when the progress message was deleted' do
        before do
          workflow.merge_messaging_callback_context!('status_ts' => '999.000')
          stub_request(:post, update_message_url).to_return(
            status: 200, body: { ok: false, error: 'message_not_found' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
        end

        it 'posts the card as a fresh threaded reply and adopts it as the progress message', :aggregate_failures do
          on_approval_required

          expect(WebMock).to have_requested(:post, post_message_url).with { |req|
            body = ::Gitlab::Json::SafeParser.parse(req.body)

            body['thread_ts'] == thread_ts &&
              body['blocks'].map { |b| b['type'] } == %w[container] &&
              card_in(body)['block_id'] == "duo_approval_#{fingerprint}"
          }
          expect(workflow.reload.messaging_callback_context).to include(
            'status_ts' => '111.222',
            'pending_approval' => fingerprint
          )
        end

        context 'when another job already replaced the progress message' do
          before do
            workflow.merge_messaging_callback_context!('status_ts' => '555.000')
          end

          it 'posts nothing and reports failure so the retry edits the new message', :aggregate_failures do
            expect(on_approval_required).to be(false)

            expect(WebMock).not_to have_requested(:post, post_message_url)
            expect(workflow.reload.messaging_callback_context).not_to include('pending_approval')
          end
        end
      end
    end

    it 'does not render again when the fingerprint is already recorded, and reports success', :aggregate_failures do
      callback_context['pending_approval'] = fingerprint

      expect(on_approval_required).to be(true)

      expect(WebMock).not_to have_requested(:post, post_message_url)
      expect(WebMock).not_to have_requested(:post, update_message_url)
    end

    it 'renders again for a new pending request after an earlier one was answered' do
      callback_context['pending_approval'] = 'aaaabbbbccccdddd'

      on_approval_required

      expect(WebMock).to have_requested(:post, post_message_url)
    end

    context 'when several tool calls are pending at once' do
      let(:mr_request_entry) do
        {
          'message_type' => 'request',
          'message_id' => 'toolu_01mr',
          'content' => 'Tool create_merge_request requires approval',
          'tool_info' => { 'name' => 'create_merge_request', 'args' => { 'title' => 'Fix' } }
        }
      end

      let(:fingerprint) { Ai::DuoWorkflows::PendingToolApproval.new([request_entry, mr_request_entry]).fingerprint }

      before do
        allow(workflow).to receive(:latest_ui_chat_log).and_return([request_entry, mr_request_entry])
      end

      it 'renders one card whose decision covers the whole batch', :aggregate_failures do
        on_approval_required

        expect(WebMock).to have_requested(:post, post_message_url).with { |req|
          body = ::Gitlab::Json::SafeParser.parse(req.body)
          card = card_in(body)

          body['text'] == 'GitLab Duo needs your approval to run: `create_issue`, `create_merge_request`' &&
            card['child_blocks'].last['elements'].map { |b| b['value'] }.uniq == ["#{workflow.id}:#{fingerprint}"]
        }
        expect(workflow.reload.messaging_callback_context).to include('pending_approval' => fingerprint)
      end
    end

    context 'when the slack_duo_api_flow flag is disabled' do
      before do
        stub_feature_flags(slack_duo_api_flow: false)
      end

      it 'posts nothing, persists nothing and reports success so the worker does not retry', :aggregate_failures do
        expect(on_approval_required).to be(true)

        expect(WebMock).not_to have_requested(:post, post_message_url)
        expect(workflow.reload.messaging_callback_context).to be_blank
      end
    end

    context 'when the session has no resource parent' do
      before do
        allow(workflow).to receive(:resource_parent).and_return(nil)
      end

      it 'evaluates the flag without an actor and still posts' do
        on_approval_required

        expect(WebMock).to have_requested(:post, post_message_url)
      end
    end

    context 'when the session is no longer waiting for a tool approval (stale redelivery)' do
      let(:workflow) { create(:duo_workflows_workflow, :running) }

      it 'posts nothing even though the request entry is still in the log, and reports success',
        :aggregate_failures do
        expect(on_approval_required).to be(true)

        expect(WebMock).not_to have_requested(:post, post_message_url)
      end
    end

    context 'when there is no pending approval request in the log' do
      before do
        allow(workflow).to receive(:latest_ui_chat_log).and_return([])
      end

      it 'posts nothing, persists nothing and reports success', :aggregate_failures do
        expect(on_approval_required).to be(true)

        expect(WebMock).not_to have_requested(:post, post_message_url)
        expect(workflow.reload.messaging_callback_context).to be_blank
      end
    end

    context 'when the message post fails' do
      before do
        stub_request(:post, post_message_url).to_return(
          status: 200, body: { ok: false, error: 'channel_not_found' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      end

      it 'does not claim the fingerprint and reports failure so the worker retries', :aggregate_failures do
        expect(on_approval_required).to be(false)

        expect(workflow.reload.messaging_callback_context).to be_blank
      end
    end

    context 'when the plan has a todo status the renderer does not know' do
      let(:todo_entry) do
        {
          'message_type' => 'tool',
          'tool_info' => {
            'name' => 'todo_write',
            'args' => { 'todos' => [{ 'status' => 'bogus', 'description' => 'Open the issue' }] }
          }
        }
      end

      let(:delta) do
        Ai::DuoWorkflows::ProgressReader::Delta.new(
          messages: [todo_entry, request_entry], new_messages: [todo_entry, request_entry], cursor: {}
        )
      end

      it 'tracks the KeyError and reports failure without raising or claiming the fingerprint',
        :aggregate_failures do
        expect(Gitlab::ErrorTracking).to receive(:track_exception).with(kind_of(KeyError), anything)

        expect(on_approval_required).to be(false)
        expect(WebMock).not_to have_requested(:post, post_message_url)
        expect(workflow.reload.messaging_callback_context).to be_blank
      end
    end
  end

  describe 'rendering a tool approval from session state' do
    let(:workflow) do
      create(:duo_workflows_workflow, :tool_call_approval_required, messaging_callback_context: callback_context)
    end

    let(:request_entry) do
      {
        'message_type' => 'request',
        'message_id' => 'toolu_01issue',
        'content' => 'Tool create_issue requires approval',
        'tool_info' => { 'name' => 'create_issue', 'args' => { 'title' => 'Bug report' } }
      }
    end

    let(:todo_entry) do
      {
        'message_type' => 'tool',
        'tool_info' => {
          'name' => 'todo_write',
          'args' => { 'todos' => [{ 'status' => 'in_progress', 'description' => 'Open the issue' }] }
        }
      }
    end

    let(:log) { [todo_entry, request_entry] }
    let(:fingerprint) { Ai::DuoWorkflows::PendingToolApproval.new(request_entry).fingerprint }

    let(:tick) do
      Ai::DuoWorkflows::ProgressReader::Delta.new(messages: [todo_entry], new_messages: [todo_entry], cursor: {})
    end

    def sent_body
      body = nil
      expect(WebMock).to have_requested(:post, update_message_url).with { |req|
        body = ::Gitlab::Json::SafeParser.parse(req.body)
      }
      body
    end

    def answer(decision)
      workflow.merge_messaging_callback_context!('answered_approval' => fingerprint, 'answered_decision' => decision)
    end

    def store_status(status)
      Ai::DuoWorkflows::Workflow.where(id: workflow.id)
        .update_all(status: Ai::DuoWorkflows::Workflow.state_machines[:status].states[status].value)
    end

    before do
      callback_context['status_ts'] = '999.000'
      allow(workflow).to receive(:latest_ui_chat_log).and_return(log)
    end

    describe '#on_approval_resolved' do
      subject(:on_approval_resolved) do
        adapter.on_approval_resolved(callback_context: callback_context, workflow: workflow)
      end

      before do
        answer('approved')
      end

      it 'shows the plan back at work and the decided card, naming the requester', :aggregate_failures do
        expect(on_approval_resolved).to be(true)

        body = sent_body
        plan, card = body['blocks']

        expect(body).to include('ts' => '999.000', 'text' => 'Approved. GitLab Duo is continuing.')
        expect(plan).to include('type' => 'plan', 'title' => 'Working on your request… (0/1 done)')
        expect(card).to include('type' => 'container', 'default_collapsed' => true)
        expect(card.dig('subtitle', 'text')).to eq('Approved')
        expect(card['child_blocks'].pluck('type')).not_to include('actions')
        expect(card['child_blocks'].last['elements'].sole['text'])
          .to eq("Approved by <@#{user_id}>. GitLab Duo is continuing.")
      end

      context 'when the request was denied' do
        before do
          answer('denied')
        end

        it 'shows the denial' do
          on_approval_resolved

          expect(sent_body['text']).to start_with('Denied.')
        end
      end

      context 'when the runtime already picked the resumed run up' do
        before do
          store_status(:running)
        end

        it 'still shows the decided card, since the log still ends in the request' do
          on_approval_resolved

          expect(sent_body['blocks'].pluck('type')).to eq(%w[plan container])
        end
      end

      context 'when the answer has already been delivered' do
        before do
          workflow.merge_messaging_callback_context!('delivered_at' => Time.current.utc.iso8601)
        end

        it 'leaves the answer alone' do
          on_approval_resolved

          expect(WebMock).not_to have_requested(:post, update_message_url)
        end
      end

      context 'when there is no progress message to edit' do
        before do
          callback_context.delete('status_ts')
        end

        it 'does nothing', :aggregate_failures do
          expect(on_approval_resolved).to be(false)
          expect(WebMock).not_to have_requested(:post, update_message_url)
        end
      end
    end

    context 'when a progress tick renders after the click' do
      before do
        answer('approved')
      end

      it 'renders the decided card, not the buttons' do
        adapter.on_progress(delta: tick, callback_context: callback_context, workflow: workflow)

        card = sent_body['blocks'].find { |b| b['type'] == 'container' }
        expect(card.dig('subtitle', 'text')).to eq('Approved')
      end
    end

    context 'when the resumed run has added to the log' do
      let(:tick) do
        messages = [todo_entry, request_entry, { 'message_type' => 'agent', 'content' => 'Issue created.' }]
        Ai::DuoWorkflows::ProgressReader::Delta.new(messages: messages, new_messages: messages.last(1), cursor: {})
      end

      let(:workflow) do
        create(:duo_workflows_workflow, :running, messaging_callback_context: callback_context)
      end

      before do
        answer('approved')
      end

      it 'drops the card' do
        adapter.on_progress(delta: tick, callback_context: callback_context, workflow: workflow)

        expect(sent_body['blocks'].pluck('type')).to eq(%w[plan])
      end
    end

    context 'when a progress tick loaded the session just before it paused' do
      let(:workflow) do
        create(:duo_workflows_workflow, :running, messaging_callback_context: callback_context)
      end

      before do
        store_status(:tool_call_approval_required)
      end

      it 'stands down, so it cannot replace the card the pause put there' do
        adapter.on_progress(delta: tick, callback_context: callback_context, workflow: workflow)

        expect(WebMock).not_to have_requested(:post, update_message_url)
      end
    end
  end

  describe '#on_flow_completed' do
    it 'removes eyes and adds checkmark reaction', :aggregate_failures do
      adapter.on_flow_completed(callback_context: callback_context, workflow: double)

      expect(WebMock).to have_requested(:post, reactions_remove_url).with(
        body: hash_including('name' => 'eyes')
      )
      expect(WebMock).to have_requested(:post, reactions_add_url).with(
        body: hash_including('name' => 'white_check_mark')
      )
    end
  end

  describe '#on_flow_failed' do
    shared_examples 'clears the working reaction and marks failure' do
      it 'removes the eyes reaction and adds the x reaction', :aggregate_failures do
        action

        expect(WebMock).to have_requested(:post, reactions_remove_url).with(
          body: hash_including('name' => 'eyes')
        )
        expect(WebMock).to have_requested(:post, reactions_add_url).with(
          body: hash_including('name' => 'x')
        )
      end
    end

    context 'when workflow is present but no message was posted (failure before start)' do
      let(:workflow) { instance_double(Ai::DuoWorkflows::Workflow, web_url: 'https://gl.test/s/1') }

      subject(:action) do
        adapter.on_flow_failed(
          callback_context: callback_context,
          error: :flow_failed,
          workflow: workflow
        )
      end

      include_examples 'clears the working reaction and marks failure'

      it 'posts a threaded reply with the error, without the session link', :aggregate_failures do
        action

        expect(WebMock).to have_requested(:post, post_message_url)
          .with { |req| req.body.include?('went wrong') && req.body.exclude?('https://gl.test/s/1') }
      end

      it 'sends the session link as an ephemeral only the invoker sees' do
        action

        expect(WebMock).to have_requested(:post, post_ephemeral_url).with(
          body: hash_including('user' => user_id, 'text' => a_string_including('https://gl.test/s/1'))
        )
      end
    end

    context 'when workflow is nil (sync failure)' do
      subject(:action) do
        adapter.on_flow_failed(
          callback_context: callback_context,
          error: :service_account_error,
          workflow: nil
        )
      end

      include_examples 'clears the working reaction and marks failure'

      it 'delivers an ephemeral error message' do
        action

        expect(WebMock).to have_requested(:post, post_ephemeral_url).with(
          body: hash_including('text' => a_string_including('service account'))
        )
      end
    end

    context 'when a status message exists' do
      let(:callback_context) { super().merge('status_ts' => '111.222') }

      subject(:action) do
        adapter.on_flow_failed(callback_context: callback_context, error: :flow_failed, workflow: double)
      end

      include_examples 'clears the working reaction and marks failure'

      it 'edits the message with the error text', :aggregate_failures do
        action

        expect(WebMock).to have_requested(:post, update_message_url).with(
          body: hash_including('ts' => '111.222', 'text' => a_string_including('went wrong'))
        )
        # status was cleared by posting the message; do not clear it again
        expect(WebMock).not_to have_requested(:post, set_status_url)
      end

      context 'with a session_url' do
        let(:callback_context) { super().merge('session_url' => 'https://gl.test/s/1') }

        it 'keeps the session link out of the shared error message', :aggregate_failures do
          action

          expect(WebMock).to have_requested(:post, update_message_url)
            .with { |req| req.body.exclude?('https://gl.test/s/1') }
        end

        it 'sends the session link as an ephemeral only the invoker sees' do
          action

          expect(WebMock).to have_requested(:post, post_ephemeral_url).with(
            body: hash_including('user' => user_id, 'text' => a_string_including('https://gl.test/s/1'))
          )
        end
      end
    end
  end

  describe '#on_progress' do
    let(:workflow) { create(:duo_workflows_workflow, messaging_callback_context: callback_context) }
    let(:delta_messages) { [] }
    let(:delta) do
      instance_double(Ai::DuoWorkflows::ProgressReader::Delta, messages: delta_messages, new_messages: delta_messages)
    end

    let(:run_command_message) { { 'message_type' => 'tool', 'tool_info' => { 'name' => 'run_command' } } }

    def todo_message(todos)
      { 'message_type' => 'tool', 'tool_info' => { 'name' => 'todo_write', 'args' => { 'todos' => todos } } }
    end

    def agent_message(content)
      { 'message_type' => 'agent', 'content' => content }
    end

    def blocks_in(req)
      ::Gitlab::Json.safe_parse(req.body)['blocks']
    end

    def plan_in(req)
      blocks_in(req).find { |b| b['type'] == 'plan' }
    end

    def details_text(task)
      task.dig('details', 'elements', 0, 'elements', 0, 'text')
    end

    context 'when the delta contains a todo_write tool call and a status_ts is present' do
      let(:callback_context) { super().merge('status_ts' => '111.222') }
      let(:todos) do
        [
          { 'status' => 'completed', 'description' => 'Read the codebase' },
          { 'status' => 'in_progress', 'description' => 'Write the tests' },
          { 'status' => 'pending', 'description' => 'Open a merge request' }
        ]
      end

      let(:delta_messages) { [todo_message(todos)] }

      it 'edits the ack message with a single plan block listing every todo', :aggregate_failures do
        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

        expect(WebMock).to have_requested(:post, update_message_url).with { |req|
          body = ::Gitlab::Json.safe_parse(req.body)
          plan = body['blocks'].find { |b| b['type'] == 'plan' }
          body['ts'] == '111.222' &&
            plan.present? &&
            plan['tasks'].map { |t| t['status'] } == %w[complete in_progress pending]
        }
      end

      it 'includes pending todos as tasks (the whole plan is shown up front)' do
        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

        expect(WebMock).to have_requested(:post, update_message_url).with { |req|
          plan_in(req)['tasks'].map { |t| t['title'] } ==
            ['Read the codebase', 'Write the tests', 'Open a merge request']
        }
      end

      it 'does not render any task_card blocks (uses a single plan block)' do
        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

        expect(WebMock).to have_requested(:post, update_message_url).with { |req|
          blocks_in(req).none? { |b| b['type'] == 'task_card' }
        }
      end

      context 'when a todo has cancelled status' do
        let(:todos) { [{ 'status' => 'cancelled', 'description' => 'Cancelled task' }] }

        it 'maps cancelled to complete (Slack has no cancelled state)' do
          adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

          expect(WebMock).to have_requested(:post, update_message_url).with { |req|
            plan_in(req)['tasks'].first['status'] == 'complete'
          }
        end
      end

      context 'when a todo has an unrecognised status' do
        let(:todos) { [{ 'status' => 'complete', 'description' => 'Rogue task' }] }

        it 'tracks the KeyError and does not update the message' do
          expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
            instance_of(KeyError),
            hash_including(slack_team_id: team_id)
          )

          adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

          expect(WebMock).not_to have_requested(:post, update_message_url)
        end
      end

      it 'assigns positional task_ids to each task' do
        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

        expect(WebMock).to have_requested(:post, update_message_url).with { |req|
          plan_in(req)['tasks'].map { |t| t['task_id'] } == %w[task_0 task_1 task_2]
        }
      end

      it 'gives the plan a fresh block_id' do
        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

        expect(WebMock).to have_requested(:post, update_message_url).with { |req|
          plan_in(req)['block_id'].present?
        }
      end

      it 'shows a progress counter in the plan title' do
        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

        expect(WebMock).to have_requested(:post, update_message_url).with { |req|
          plan_in(req)['title'] == 'Working on your request… (1/3 done)'
        }
      end

      it 'uses the plan title and the active task as the plain-text fallback' do
        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

        expect(WebMock).to have_requested(:post, update_message_url).with { |req|
          ::Gitlab::Json.safe_parse(req.body)['text'] == "Working on your request… (1/3 done)\nWrite the tests"
        }
      end

      context 'when the session is waiting for a tool approval' do
        let(:workflow) do
          create(:duo_workflows_workflow, :tool_call_approval_required, messaging_callback_context: callback_context)
        end

        it 'says so in the plan title' do
          adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

          expect(WebMock).to have_requested(:post, update_message_url).with { |req|
            plan_in(req)['title'] == 'Waiting for approval (1/3 done)'
          }
        end

        context 'when the pending request is in the session log' do
          let(:request_entry) do
            {
              'message_type' => 'request',
              'message_id' => 'toolu_01issue',
              'content' => 'Tool create_issue requires approval',
              'tool_info' => { 'name' => 'create_issue', 'args' => { 'title' => 'Bug report' } }
            }
          end

          before do
            allow(workflow).to receive(:latest_ui_chat_log).and_return([request_entry])
          end

          it 'keeps the card below the plan so a redelivered tick does not drop it', :aggregate_failures do
            adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

            expect(WebMock).to have_requested(:post, update_message_url).with { |req|
              body = ::Gitlab::Json.safe_parse(req.body)
              card = blocks_in(req).find { |b| b['type'] == 'container' }

              blocks_in(req).map { |b| b['type'] } == %w[plan container] &&
                body['text'] == 'GitLab Duo needs your approval to run: `create_issue`' &&
                card['child_blocks'].last['elements'].map { |b| b['action_id'] } ==
                  %w[duo_approval_approve duo_approval_deny]
            }
          end
        end
      end

      context 'with an agent monologue' do
        let(:delta_messages) { [todo_message(todos), agent_message('Writing the spec file now')] }

        it 'renders it as details of the active task, never as a top-level block', :aggregate_failures do
          adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

          expect(WebMock).to have_requested(:post, update_message_url).with { |req|
            tasks = plan_in(req)['tasks']

            blocks_in(req).map { |b| b['type'] } == ['plan'] &&
              details_text(tasks[1]) == 'Writing the spec file now' &&
              [tasks[0], tasks[2]].none? { |t| t.key?('details') }
          }
        end

        it 'keeps the monologue out of the plain-text fallback' do
          adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

          expect(WebMock).to have_requested(:post, update_message_url).with { |req|
            ::Gitlab::Json.safe_parse(req.body)['text'].exclude?('Writing the spec file now')
          }
        end

        context 'when no todo is in progress' do
          let(:todos) do
            [
              { 'status' => 'completed', 'description' => 'Read the codebase' },
              { 'status' => 'pending', 'description' => 'Write the tests' },
              { 'status' => 'pending', 'description' => 'Open a merge request' }
            ]
          end

          it 'attaches it to the first pending todo' do
            adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

            expect(WebMock).to have_requested(:post, update_message_url).with { |req|
              plan_in(req)['tasks'].map { |t| details_text(t) } == [nil, 'Writing the spec file now', nil]
            }
          end
        end

        context 'when every todo is done' do
          let(:todos) do
            [
              { 'status' => 'completed', 'description' => 'Read the codebase' },
              { 'status' => 'cancelled', 'description' => 'Write the tests' }
            ]
          end

          it 'attaches it to the last todo' do
            adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

            expect(WebMock).to have_requested(:post, update_message_url).with { |req|
              plan_in(req)['tasks'].map { |t| details_text(t) } == [nil, 'Writing the spec file now']
            }
          end
        end

        context 'when the monologue is very long' do
          let(:delta_messages) { [todo_message(todos), agent_message("#{'word ' * 400}end")] }

          it 'truncates it to MONOLOGUE_DETAILS_MAX_LENGTH without wrapping lines' do
            adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

            expect(WebMock).to have_requested(:post, update_message_url).with { |req|
              text = details_text(plan_in(req)['tasks'][1])

              text.length <= described_class::MONOLOGUE_DETAILS_MAX_LENGTH && text.end_with?('…') &&
                text.exclude?("\n")
            }
          end
        end
      end

      context 'when only a tool call is new since the last tick' do
        let(:delta) do
          instance_double(Ai::DuoWorkflows::ProgressReader::Delta,
            messages: delta_messages + [run_command_message], new_messages: [run_command_message])
        end

        it 'skips the edit, since nothing visible changed' do
          adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

          expect(WebMock).not_to have_requested(:post, update_message_url)
        end
      end

      context 'when the monologue is markdown' do
        let(:delta_messages) { [todo_message(todos), agent_message("Found **47 issues**:\n\n- one\n- two")] }

        it 'strips the markdown syntax, since task details render plain text only' do
          adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

          expect(WebMock).to have_requested(:post, update_message_url).with { |req|
            details_text(plan_in(req)['tasks'][1]) == "Found 47 issues:\n  - one\n  - two"
          }
        end
      end

      context 'with a session_url' do
        let(:callback_context) { super().merge('session_url' => 'https://gl.test/s/1') }

        it 'keeps the session link out of the shared progress message' do
          adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

          expect(WebMock).to have_requested(:post, update_message_url)
            .with { |req| req.body.exclude?('https://gl.test/s/1') }
        end
      end

      context 'when multiple todo_write messages are present' do
        let(:older_todos) { [{ 'status' => 'pending', 'description' => 'Old task' }] }
        let(:newer_todos) { [{ 'status' => 'in_progress', 'description' => 'New task' }] }
        let(:delta_messages) { [todo_message(older_todos), todo_message(newer_todos)] }

        it 'renders only the latest todo_write entry' do
          adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

          expect(WebMock).to have_requested(:post, update_message_url).with { |req|
            body = req.body
            body.include?('New task') && body.exclude?('Old task')
          }
        end
      end
    end

    context 'when no status_ts is present yet (first real content)' do
      let(:todos) { [{ 'status' => 'pending', 'description' => 'Do something' }] }
      let(:delta_messages) { [todo_message(todos)] }

      let(:lease_key) { "duo_slack_progress_message:#{workflow.id}" }

      subject(:on_progress) do
        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)
      end

      it 'posts a new message (the status indicator clears automatically)' do
        on_progress

        expect(WebMock).to have_requested(:post, post_message_url).with { |req|
          body = ::Gitlab::Json.safe_parse(req.body)
          body['thread_ts'] == thread_ts && body['blocks'].any? { |b| b['type'] == 'plan' }
        }
      end

      it 'persists the posted message ts, so the next tick edits it' do
        on_progress

        expect(workflow.reload.messaging_callback_context['status_ts']).to eq('111.222')
      end

      context 'when another job is posting the message right now' do
        before do
          stub_exclusive_lease_taken(lease_key)
        end

        it 'skips instead of posting a second message' do
          on_progress

          expect(WebMock).not_to have_requested(:post, post_message_url)
        end
      end

      context 'when another job already opened it after this job read the context' do
        before do
          Ai::DuoWorkflows::Workflow.find(workflow.id).merge_messaging_callback_context!('status_ts' => '999.000')
        end

        it 'does not post a second message' do
          on_progress

          expect(WebMock).not_to have_requested(:post, post_message_url)
        end
      end

      describe 'releasing the lease', :clean_gitlab_redis_shared_state do
        subject(:lease_held?) do
          on_progress
          Gitlab::ExclusiveLease.new(lease_key, timeout: 1).exists?
        end

        it 'releases it after posting' do
          expect(lease_held?).to be(false)
        end

        context 'when Slack rejects the post' do
          before do
            stub_request(:post, post_message_url).to_return(
              status: 200, body: { ok: false, error: 'channel_not_found' }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
          end

          it 'releases it so the next tick can try again' do
            expect(lease_held?).to be(false)
          end
        end

        context 'when the post raises' do
          before do
            stub_request(:post, post_message_url).to_raise(StandardError.new('network error'))
          end

          it 'releases it so the next tick can try again' do
            expect(lease_held?).to be(false)
          end
        end

        context 'when the Slack installation is gone' do
          let(:team_id) { 'NONEXISTENT' }

          it 'releases it so the next tick can try again' do
            expect(lease_held?).to be(false)
          end
        end
      end
    end

    context 'when the answer was delivered after the tick started' do
      let(:delta_messages) { [agent_message('Still working')] }

      before do
        Ai::DuoWorkflows::Workflow.find(workflow.id)
          .merge_messaging_callback_context!('delivered_at' => Time.current.utc.iso8601)
      end

      it 'does not edit the answer', :aggregate_failures do
        adapter.on_progress(delta: delta, callback_context: callback_context.merge('status_ts' => '111.222'),
          workflow: workflow)

        expect(WebMock).not_to have_requested(:post, update_message_url)
      end

      it 'does not post a trailing message below it' do
        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

        expect(WebMock).not_to have_requested(:post, post_message_url)
      end
    end

    context 'when the only agent message is markdown with no text' do
      let(:callback_context) { super().merge('status_ts' => '111.222') }
      let(:delta_messages) { [agent_message("---\n\n<!-- note -->")] }

      it 'does not update the message' do
        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

        expect(WebMock).not_to have_requested(:post, update_message_url)
      end
    end

    context 'when the delta has no todo_write but the agent is reasoning (short task)' do
      let(:callback_context) { super().merge('status_ts' => '111.222') }
      let(:delta_messages) { [agent_message('Looking into it')] }

      it 'shows the reasoning as the title of a single in-progress task, with no top-level prose' do
        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

        expect(WebMock).to have_requested(:post, update_message_url).with { |req|
          plan = plan_in(req)

          blocks_in(req).map { |b| b['type'] } == ['plan'] &&
            plan['title'] == 'Working on your request…' &&
            plan['tasks'] == [{ 'task_id' => 'task_0', 'title' => 'Looking into it', 'status' => 'in_progress' }]
        }
      end

      context 'when the reasoning is long markdown' do
        let(:delta_messages) { [agent_message("**Found** the issue.\n\n#{'word ' * 40}end")] }

        it 'flattens it to one plain line cut at MONOLOGUE_TITLE_MAX_LENGTH', :aggregate_failures do
          adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

          expect(WebMock).to have_requested(:post, update_message_url).with { |req|
            title = plan_in(req)['tasks'].sole['title']

            title.start_with?('Found the issue. word') &&
              title.end_with?('…') &&
              title.length <= described_class::MONOLOGUE_TITLE_MAX_LENGTH
          }
        end
      end

      it 'uses the plan title as the plain-text fallback' do
        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

        expect(WebMock).to have_requested(:post, update_message_url).with { |req|
          ::Gitlab::Json.safe_parse(req.body)['text'] == 'Working on your request…'
        }
      end
    end

    context 'when the todo_write entry has an empty todos array and no reasoning' do
      let(:callback_context) { super().merge('status_ts' => '111.222') }
      let(:empty_todo_tool_info) { { 'name' => 'todo_write', 'args' => { 'todos' => [] } } }
      let(:delta_messages) { [{ 'message_type' => 'tool', 'tool_info' => empty_todo_tool_info }] }

      it 'does not update the acknowledgement message' do
        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

        expect(WebMock).not_to have_requested(:post, update_message_url)
      end
    end

    context 'when the delta has only an unrelated tool call' do
      let(:callback_context) { super().merge('status_ts' => '111.222') }
      let(:delta_messages) { [{ 'message_type' => 'tool', 'tool_info' => { 'name' => 'run_command' } }] }

      it 'does not update the acknowledgement message' do
        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

        expect(WebMock).not_to have_requested(:post, update_message_url)
      end
    end

    context 'when the delta is empty' do
      let(:delta_messages) { [] }

      it 'makes no Slack API calls', :aggregate_failures do
        adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow)

        expect(WebMock).not_to have_requested(:post, update_message_url)
        expect(WebMock).not_to have_requested(:post, set_status_url)
      end
    end

    context 'when a Slack API error occurs' do
      let(:callback_context) { super().merge('status_ts' => '111.222') }
      let(:todos) { [{ 'status' => 'pending', 'description' => 'Do something' }] }
      let(:delta_messages) { [todo_message(todos)] }

      before do
        stub_request(:post, update_message_url).to_raise(StandardError.new('network error'))
      end

      it 'tracks the exception and does not raise' do
        expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
          instance_of(StandardError),
          hash_including(slack_team_id: team_id)
        )

        expect { adapter.on_progress(delta: delta, callback_context: callback_context, workflow: workflow) }
          .not_to raise_error
      end
    end
  end

  describe '#deliver_result' do
    # By default the run had no todo list: the latest checkpoint has an empty
    # ui_chat_log, so final_todos is empty and no plan block is rendered.
    let(:workflow) { build_stubbed(:duo_workflows_workflow) }

    before do
      allow(workflow).to receive(:latest_ui_chat_log).and_return([])
    end

    shared_examples 'the final result content' do
      it 'renders the answer in a markdown block' do
        adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow)

        expect(WebMock).to have_requested(:post, delivery_url).with { |req|
          ::Gitlab::Json.safe_parse(req.body)['blocks']
            .any? { |b| b['type'] == 'markdown' && b['text'] == 'Done!' }
        }
      end

      context 'when the answer is longer than a markdown block can hold' do
        let(:paragraph) { "#{'word ' * 199}end." }
        let(:last_paragraph) { 'The last paragraph.' }
        let(:message) { "#{([paragraph] * 12).join("\n\n")}\n\n#{last_paragraph}" }

        def delivered_markdown
          body = nil
          expect(WebMock).to have_requested(:post, delivery_url).with { |req| body = req.body }

          ::Gitlab::Json.safe_parse(body)['blocks'].find { |b| b['type'] == 'markdown' }['text']
        end

        it 'cuts it at a paragraph break and says so', :aggregate_failures do
          adapter.deliver_result(callback_context: callback_context, message: message, workflow: workflow)

          text = delivered_markdown
          expect(text.length).to be < 12_000
          expect(text).to start_with(paragraph)
          expect(text).not_to include(last_paragraph)
          expect(text).to include("end.\n\n_Answer shortened to fit in Slack.")
        end
      end

      context 'with a session_url' do
        let(:callback_context) { super().merge('session_url' => 'https://gl.test/s/1') }

        it 'keeps the session link out of the shared reply', :aggregate_failures do
          adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow)

          expect(WebMock).to have_requested(:post, delivery_url)
            .with { |req| req.body.exclude?('https://gl.test/s/1') }
        end

        it 'sends the session link as an ephemeral only the invoker sees', :aggregate_failures do
          adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow)

          expect(WebMock).to have_requested(:post, post_ephemeral_url).with(
            body: hash_including(
              'user' => user_id,
              'thread_ts' => thread_ts,
              'text' => a_string_including('https://gl.test/s/1')
            )
          )
        end

        context 'when the delivery fails' do
          before do
            stub_request(:post, delivery_url).to_return(
              status: 200, body: { ok: false, error: 'channel_not_found' }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
          end

          it 'does not send the ephemeral link so the retry cannot duplicate it' do
            adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow)

            expect(WebMock).not_to have_requested(:post, post_ephemeral_url)
          end
        end

        context 'when the ephemeral post fails' do
          before do
            stub_request(:post, post_ephemeral_url).to_raise(StandardError.new('network error'))
          end

          it 'still reports the delivery as successful' do
            expect(Gitlab::ErrorTracking).to receive(:track_exception)

            expect(adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow))
              .to be(true)
          end
        end
      end

      context 'when the run had a todo list' do
        let(:todos) { [{ 'status' => 'completed', 'description' => 'Do the thing' }] }

        before do
          allow(workflow).to receive(:latest_ui_chat_log).and_return(
            [{ 'tool_info' => { 'name' => 'todo_write', 'args' => { 'todos' => todos } } }]
          )
        end

        it 'prepends the plan block before the final answer so users can inspect the task list' do
          adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow)

          expect(WebMock).to have_requested(:post, delivery_url).with { |req|
            blocks = ::Gitlab::Json.safe_parse(req.body)['blocks']
            plan_idx = blocks.index { |b| b['type'] == 'plan' }
            md_idx = blocks.index { |b| b['type'] == 'markdown' }
            plan_idx && md_idx && plan_idx < md_idx
          }
        end

        it 'renders the plan from the terminal checkpoint so completed tasks are not shown as in_progress' do
          # Regression: the final todo_write (all complete) lands in the terminal
          # checkpoint after live progress stops. Reading it here keeps the plan
          # in sync with the final answer instead of freezing a stale render.
          adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow)

          expect(WebMock).to have_requested(:post, delivery_url).with { |req|
            plan = ::Gitlab::Json.safe_parse(req.body)['blocks'].find { |b| b['type'] == 'plan' }
            plan['tasks'].map { |t| t['status'] } == ['complete']
          }
        end

        context 'when every todo is completed or cancelled' do
          let(:todos) do
            [
              { 'status' => 'completed', 'description' => 'Read the codebase' },
              { 'status' => 'cancelled', 'description' => 'Write the tests' }
            ]
          end

          it 'keeps the real statuses and titles the plan "Plan complete"' do
            adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow)

            expect(WebMock).to have_requested(:post, delivery_url).with { |req|
              plan = ::Gitlab::Json.safe_parse(req.body)['blocks'].find { |b| b['type'] == 'plan' }

              plan['title'] == 'Plan complete' &&
                plan['tasks'].map { |t| t['status'] } == %w[complete complete]
            }
          end
        end

        context 'when a todo is still in progress' do
          let(:todos) do
            [
              { 'status' => 'completed', 'description' => 'Read the codebase' },
              { 'status' => 'in_progress', 'description' => 'Write the tests' }
            ]
          end

          it 'renders the unfinished task as pending under a "Plan (1/2 done)" title' do
            adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow)

            expect(WebMock).to have_requested(:post, delivery_url).with { |req|
              plan = ::Gitlab::Json.safe_parse(req.body)['blocks'].find { |b| b['type'] == 'plan' }

              plan['title'] == 'Plan (1/2 done)' &&
                plan['tasks'].map { |t| t['status'] } == %w[complete pending] &&
                plan['tasks'].none? { |t| t['status'] == 'in_progress' } &&
                plan['tasks'].none? { |t| t.key?('details') }
            }
          end
        end

        context 'when a todo is still pending' do
          let(:todos) do
            [
              { 'status' => 'completed', 'description' => 'Read the codebase' },
              { 'status' => 'pending', 'description' => 'Write the tests' }
            ]
          end

          it 'keeps the unfinished task pending under a "Plan (1/2 done)" title' do
            adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow)

            expect(WebMock).to have_requested(:post, delivery_url).with { |req|
              plan = ::Gitlab::Json.safe_parse(req.body)['blocks'].find { |b| b['type'] == 'plan' }

              plan['title'] == 'Plan (1/2 done)' &&
                plan['tasks'].map { |t| t['status'] } == %w[complete pending]
            }
          end
        end
      end

      context 'with a workflow_id' do
        let(:callback_context) { super().merge('workflow_id' => 42) }

        it 'appends a feedback_buttons block with the workflow id packed into the values' do
          adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow)

          expect(WebMock).to have_requested(:post, delivery_url).with { |req|
            blocks = ::Gitlab::Json.safe_parse(req.body)['blocks']
            feedback = blocks.find { |b| b['type'] == 'context_actions' }&.dig('elements', 0)

            feedback && feedback['type'] == 'feedback_buttons' &&
              feedback['action_id'] == 'duo_feedback' &&
              feedback['positive_button']['value'] == 'up:42' &&
              feedback['negative_button']['value'] == 'down:42'
          }
        end
      end

      it 'omits the feedback block when there is no workflow_id' do
        adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow)

        expect(WebMock).to have_requested(:post, delivery_url)
          .with { |req| req.body.exclude?('feedback_buttons') }
      end
    end

    context 'when on_progress never posted a message' do
      let(:delivery_url) { post_message_url }

      it_behaves_like 'the final result content'

      it 'posts the answer as a new threaded reply', :aggregate_failures do
        adapter.deliver_result(callback_context: callback_context, message: 'Hello from Duo!', workflow: workflow)

        expect(WebMock).to have_requested(:post, post_message_url).with(
          body: hash_including('channel' => channel_id, 'thread_ts' => thread_ts, 'text' => 'Hello from Duo!')
        )
        expect(WebMock).not_to have_requested(:post, update_message_url)
      end

      it 'returns true once Slack accepted the reply' do
        expect(adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow))
          .to be(true)
      end

      context 'when Slack rejects the post' do
        before do
          stub_request(:post, post_message_url).to_return(
            status: 200, body: { ok: false, error: 'channel_not_found' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
        end

        it 'returns false so the caller can retry the delivery' do
          expect(adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow))
            .to be(false)
        end
      end

      context 'when the answer is longer than the text limit' do
        let(:message) { "#{'word — ' * 1000}end" }
        let(:post_bodies) { [] }

        before do
          stub_request(:post, post_message_url).to_return do |request|
            post_bodies << ::Gitlab::Json::SafeParser.parse(request.body)
            { status: 200, body: { ok: true }.to_json, headers: { 'Content-Type' => 'application/json' } }
          end
        end

        it 'cuts the text to the byte limit and keeps the full answer in the markdown block', :aggregate_failures do
          adapter.deliver_result(callback_context: callback_context, message: message, workflow: workflow)

          expect(post_bodies.size).to eq(1)
          expect(post_bodies.first['text'].bytesize).to be <= described_class::TEXT_MAX_BYTES
          expect(post_bodies.first['text']).to end_with('…')
          expect(post_bodies.first['blocks'].find { |b| b['type'] == 'markdown' }['text']).to eq(message)
        end
      end

      context 'when the block render is rejected' do
        let(:message) { "#{'word ' * 1000}end" }
        let(:post_bodies) { [] }

        before do
          stub_request(:post, post_message_url).to_return do |request|
            post_bodies << ::Gitlab::Json::SafeParser.parse(request.body)
            result = post_bodies.one? ? { ok: false, error: 'invalid_blocks' } : { ok: true }
            { status: 200, body: result.to_json, headers: { 'Content-Type' => 'application/json' } }
          end
        end

        it 'posts the full answer as plain text without blocks', :aggregate_failures do
          expect(adapter.deliver_result(callback_context: callback_context, message: message, workflow: workflow))
            .to be(true)

          expect(post_bodies.size).to eq(2)
          expect(post_bodies.last['text']).to eq(message)
          expect(post_bodies.last).not_to have_key('blocks')
        end
      end
    end

    context 'when on_progress already posted a progress message' do
      let(:callback_context) { super().merge('status_ts' => '111.222') }
      let(:delivery_url) { update_message_url }

      it_behaves_like 'the final result content'

      it 'edits that message in place instead of posting a new one', :aggregate_failures do
        adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow)

        expect(WebMock).to have_requested(:post, update_message_url).with(
          body: hash_including('ts' => '111.222')
        )
        expect(WebMock).not_to have_requested(:post, post_message_url)
      end

      context 'when the block render is rejected' do
        before do
          # First call (with blocks) is rejected; second call (blocks: []) succeeds.
          stub_request(:post, update_message_url).to_return(
            { status: 200, body: { ok: false, error: 'invalid_blocks' }.to_json,
              headers: { 'Content-Type' => 'application/json' } },
            { status: 200, body: { ok: true }.to_json, headers: { 'Content-Type' => 'application/json' } }
          )
        end

        it 'retries with a plain-text edit clearing blocks so the answer is not lost', :aggregate_failures do
          adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow)

          expect(WebMock).to have_requested(:post, update_message_url).twice
          expect(WebMock).to have_requested(:post, update_message_url)
            .with { |req| req.body.include?('"blocks":[]') }
        end

        it 'returns true because the plain-text retry landed' do
          expect(adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow))
            .to be(true)
        end
      end

      it 'returns true once Slack accepted the edit' do
        expect(adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow))
          .to be(true)
      end

      context 'when the answer is longer than the chat.update text limit' do
        let(:message) { "#{'word ' * 1000}end" }
        let(:update_bodies) { [] }

        before do
          stub_request(:post, update_message_url).to_return do |request|
            update_bodies << ::Gitlab::Json::SafeParser.parse(request.body)
            result = update_bodies.one? ? { ok: false, error: 'invalid_blocks' } : { ok: true }
            { status: 200, body: result.to_json, headers: { 'Content-Type' => 'application/json' } }
          end
        end

        it 'cuts the text of both edits to the limit and keeps the full answer in the markdown block',
          :aggregate_failures do
          adapter.deliver_result(callback_context: callback_context, message: message, workflow: workflow)

          texts = update_bodies.pluck('text')
          expect(texts.size).to eq(2)
          expect(texts).to all(satisfy { |text| text.bytesize <= described_class::TEXT_MAX_BYTES })
          expect(texts).to all(end_with('…'))
          expect(update_bodies.first['blocks'].find { |b| b['type'] == 'markdown' }['text']).to eq(message)
        end

        context 'when the answer has multibyte characters and characters Slack escapes' do
          # Slack counts & as &amp; and < > as &lt; &gt;, in bytes, against its limit.
          let(:message) { "#{'a & b — <@U1> ' * 1000}end" }

          it 'keeps the escaped byte size of the text within the limit' do
            adapter.deliver_result(callback_context: callback_context, message: message, workflow: workflow)

            text = update_bodies.first['text']
            escaped_bytesize = text.bytesize + (text.count('&') * 4) + (text.count('<>') * 3)
            expect(escaped_bytesize).to be <= described_class::TEXT_MAX_BYTES
          end
        end

        context 'when the answer is made almost entirely of characters Slack escapes' do
          let(:message) { '&<' * 3000 }

          it 'still delivers, with the escaped byte size of the text within the limit', :aggregate_failures do
            expect(adapter.deliver_result(callback_context: callback_context, message: message, workflow: workflow))
              .to be(true)

            text = update_bodies.first['text']
            escaped_bytesize = text.bytesize + (text.count('&') * 4) + (text.count('<>') * 3)
            expect(escaped_bytesize).to be <= described_class::TEXT_MAX_BYTES
          end
        end
      end

      context 'when Slack rejects both the block edit and the plain-text retry' do
        before do
          stub_request(:post, update_message_url).to_return(
            status: 200, body: { ok: false, error: 'message_not_found' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
        end

        it 'returns false so the caller can retry the delivery' do
          expect(adapter.deliver_result(callback_context: callback_context, message: 'Done!', workflow: workflow))
            .to be(false)
        end
      end
    end
  end

  describe '#deliver_error' do
    it 'posts an ephemeral error message to the user' do
      adapter.deliver_error(callback_context: callback_context, error: :namespace_not_configured)

      expect(WebMock).to have_requested(:post, post_ephemeral_url).with(
        body: hash_including(
          'channel' => channel_id,
          'user' => user_id,
          'text' => a_string_including('default Duo namespace')
        )
      )
    end

    it 'handles unknown errors with a generic message' do
      adapter.deliver_error(callback_context: callback_context, error: :something_unexpected)

      expect(WebMock).to have_requested(:post, post_ephemeral_url).with(
        body: hash_including('text' => a_string_including('Something went wrong. Try again.'))
      )
    end

    context 'when the mention was inside an existing thread (thread_ts != message_ts)' do
      let(:thread_ts) { '1111111111.000001' }
      let(:message_ts) { '9999999999.000001' }

      it 'posts the ephemeral into the thread' do
        adapter.deliver_error(callback_context: callback_context, error: :flow_failed)

        expect(WebMock).to have_requested(:post, post_ephemeral_url).with(
          body: hash_including('thread_ts' => thread_ts)
        )
      end
    end

    context 'when the mention was a top-level channel message (thread_ts == message_ts)' do
      let(:thread_ts) { '1234567890.123456' }
      let(:message_ts) { '1234567890.123456' }

      it 'posts the ephemeral at channel root (no thread_ts)' do
        adapter.deliver_error(callback_context: callback_context, error: :flow_failed)

        expect(WebMock).to have_requested(:post, post_ephemeral_url)
          .with { |req| req.body.exclude?('thread_ts') }
      end
    end

    context 'when thread_ts is absent from the callback context' do
      let(:callback_context) { super().except('thread_ts') }

      it 'posts the ephemeral at channel root (no thread_ts)' do
        adapter.deliver_error(callback_context: callback_context, error: :flow_failed)

        expect(WebMock).to have_requested(:post, post_ephemeral_url)
          .with { |req| req.body.exclude?('thread_ts') }
      end
    end
  end

  describe 'error text mapping' do
    using RSpec::Parameterized::TableSyntax

    where(:error_sym, :expected_text) do
      :namespace_not_configured | 'default Duo namespace'
      :service_account_error    | 'Could not set up the service account for the flow'
      :workspace_project_error  | 'workspace project'
      :execute_workflow_failed  | 'Failed to start the GitLab Duo session'
      :flow_failed              | 'went wrong while running'
      :flow_stopped             | 'session was stopped'
      :no_response              | "didn't produce a response"
      :message_too_long         | 'Your message is too long'
      :delivery_failed          | "couldn't post the answer here"
    end

    with_them do
      it 'delivers the correct error text via ephemeral message' do
        adapter.on_flow_failed(callback_context: callback_context, error: error_sym)

        expect(WebMock).to have_requested(:post, post_ephemeral_url).with(
          body: hash_including('text' => a_string_including(expected_text))
        )
      end
    end

    context 'when the flow is not enabled' do
      where(:flow_name, :expected_text) do
        'Developer'            | 'The Developer flow is not turned on for your namespace'
        'GitLab Duo for Slack' | 'The GitLab Duo for Slack flow is not turned on for your namespace'
      end

      with_them do
        it 'names the flow in the error text' do
          adapter.deliver_error(
            callback_context: callback_context.merge('flow_name' => flow_name),
            error: :flow_not_enabled
          )

          expect(WebMock).to have_requested(:post, post_ephemeral_url).with(
            body: hash_including('text' => a_string_including(expected_text))
          )
        end
      end
    end
  end

  context 'when Slack installation is not found' do
    let(:nonexistent_adapter) do
      described_class.new(
        team_id: 'NONEXISTENT',
        channel_id: channel_id,
        thread_ts: thread_ts,
        message_ts: message_ts,
        user_id: user_id
      )
    end

    let(:nonexistent_context) { nonexistent_adapter.build_callback_context }

    it 'tracks exception on deliver_result instead of raising' do
      expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
        instance_of(described_class::InstallationNotFoundError),
        hash_including(slack_team_id: 'NONEXISTENT')
      )

      expect do
        nonexistent_adapter.deliver_result(
          callback_context: nonexistent_context, message: 'test', workflow: build_stubbed(:duo_workflows_workflow)
        )
      end.not_to raise_error
    end

    it 'returns false from deliver_result so the caller can retry the delivery' do
      allow(Gitlab::ErrorTracking).to receive(:track_exception)

      expect(
        nonexistent_adapter.deliver_result(
          callback_context: nonexistent_context, message: 'test', workflow: build_stubbed(:duo_workflows_workflow)
        )
      ).to be(false)
    end

    it 'tracks exception on deliver_error instead of raising' do
      expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
        instance_of(described_class::InstallationNotFoundError),
        hash_including(slack_team_id: 'NONEXISTENT')
      )

      expect { nonexistent_adapter.deliver_error(callback_context: nonexistent_context, error: :flow_failed) }
        .not_to raise_error
    end

    it 'tracks exception on on_request_received instead of raising' do
      expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
        instance_of(described_class::InstallationNotFoundError),
        hash_including(slack_team_id: 'NONEXISTENT')
      )

      nonexistent_adapter.on_request_received
    end
  end

  describe 'Slack API caching' do
    let(:workflow) { build_stubbed(:duo_workflows_workflow) }

    it 'reuses the Slack API client for the same team' do
      expect(SlackIntegration).to receive(:with_bot).once.and_call_original

      adapter.deliver_result(callback_context: callback_context, message: 'first', workflow: workflow)
      adapter.deliver_result(callback_context: callback_context, message: 'second', workflow: workflow)
    end
  end

  describe 'Slack API error handling' do
    using RSpec::Parameterized::TableSyntax

    where(:api_method, :slack_error, :log_message) do
      'reactions.add'      | 'already_reacted'   | 'Slack API error when adding reaction'
      'reactions.remove'   | 'no_reaction'       | 'Slack API error when removing reaction'
      'chat.postMessage'   | 'channel_not_found' | 'Slack API error when posting message'
      'chat.postEphemeral' | 'user_not_found'    | 'Slack API error when posting ephemeral message'
    end

    with_them do
      before do
        stub_request(:post, "#{Slack::API::BASE_URL}/#{api_method}").to_return(
          status: 200, body: { ok: false, error: slack_error }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      end

      it 'logs the error and does not raise' do
        # at_least: a rejected answer post is retried once without blocks.
        expect(Gitlab::IntegrationsLogger).to receive(:error).with(
          hash_including(message: log_message)
        ).at_least(:once)

        # Trigger the code path that exercises the stubbed API method
        case api_method
        when 'reactions.add'
          expect { adapter.on_request_received }.not_to raise_error
        when 'reactions.remove'
          expect { adapter.on_flow_completed(callback_context: callback_context, workflow: double) }
            .not_to raise_error
        when 'chat.postMessage'
          expect do
            adapter.deliver_result(
              callback_context: callback_context, message: 'test', workflow: build_stubbed(:duo_workflows_workflow)
            )
          end.not_to raise_error
        when 'chat.postEphemeral'
          expect { adapter.deliver_error(callback_context: callback_context, error: :flow_failed) }
            .not_to raise_error
        end
      end
    end
  end
end
