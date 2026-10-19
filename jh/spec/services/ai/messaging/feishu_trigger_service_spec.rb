# frozen_string_literal: true

require 'spec_helper'

# The turn handling itself is shared with DingTalk and covered in
# dingtalk_trigger_service_spec.rb; this covers what Feishu supplies.
RSpec.describe Ai::Messaging::FeishuTriggerService, :clean_gitlab_redis_shared_state,
  :clean_gitlab_redis_rate_limiting, feature_category: :duo_agent_platform do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:service_account) { create(:user, :service_account) }

  let(:chat_id) { 'oc_group' }
  let(:sender_id) { 'feishu-user-1' }
  let(:thread_id) { nil }
  let(:message) { 'how do I create a project?' }

  let(:service) { build_service }

  let(:session_store) do
    ::Gitlab::Feishu::DuoSessionStore.new(
      app_id: 'cli_app', chat_id: chat_id, thread_id: thread_id, sender_id: sender_id, user_id: user.id
    )
  end

  def build_service(for_user: user, from: sender_id, text: message, in_thread: thread_id)
    described_class.new(
      user: for_user,
      app_id: 'cli_app',
      chat_id: chat_id,
      thread_id: in_thread,
      sender_id: from,
      message_id: 'om_current',
      message: text
    )
  end

  def stub_resolution(result)
    allow_next_instance_of(::Ai::Messaging::DefaultProjectFlowResolver) do |resolver|
      allow(resolver).to receive(:execute).and_return(result)
    end
  end

  def stub_authorization(result)
    allow_next_instance_of(::Ai::DuoWorkflows::FlowExecutionAuthorizer) do |authorizer|
      allow(authorizer).to receive(:execute).and_return(result)
    end
  end

  def resolution_success
    ServiceResponse.success(payload: {
      project: project,
      service_account: service_account,
      flow_config_id: 'feishu_assistant',
      flow_config_schema_version: 'v1',
      flow_version: '1.0.0'
    })
  end

  describe '#execute' do
    context 'with a new message' do
      before do
        stub_resolution(resolution_success)
        stub_authorization(ServiceResponse.success)
      end

      it 'runs the Feishu flow from the Feishu source and remembers the session', :aggregate_failures do
        workflow = create(:duo_workflows_workflow, user: user, project: project)

        expect_next_instance_of(::Ai::Messaging::Adapters::Feishu) do |adapter|
          expect(adapter).to receive(:trigger) do |bundle|
            expect(bundle.flow_reference).to eq('feishu_assistant/v1')
            expect(bundle.source_type).to eq(:feishu)
            expect(bundle.goal).to start_with('You received a message in a Feishu conversation.')

            ServiceResponse.success(payload: { workflow: workflow })
          end
        end

        expect(service.execute).to eq(s_('JH|DuoFeishu|Duo is working on it…'))
        expect(session_store.current_workflow_id).to eq(workflow.id)
        expect(session_store.transcript).to eq([{ 'role' => 'user', 'text' => message }])
      end

      it 'replies to the message and carries the turn token into the callback context' do
        context = nil
        allow_next_instance_of(::Ai::Messaging::Adapters::Feishu) do |adapter|
          allow(adapter).to receive(:trigger) do
            context = adapter.build_callback_context
            ServiceResponse.success(payload: { workflow: nil })
          end
        end

        service.execute

        expect(context).to include(
          'app_id' => 'cli_app', 'chat_id' => chat_id, 'sender_id' => sender_id, 'message_id' => 'om_current',
          'turn_token' => a_string_matching(/\A\h{16}\z/)
        )
      end
    end

    describe 'conversation isolation' do
      let_it_be(:workflow, freeze: false) do
        create(:duo_workflows_workflow, :finished, user: user, project: project)
      end

      def goal_for(other_service)
        captured = nil
        allow_next_instance_of(::Ai::Messaging::Adapters::Feishu) do |adapter|
          allow(adapter).to receive(:trigger) do |bundle|
            captured = bundle
            ServiceResponse.success(payload: { workflow: nil })
          end
        end

        other_service.execute
        captured.goal
      end

      before do
        session_store.store!(workflow.id)
        session_store.record_answer!(session_store.start_turn!('where is the README?'), 'In the project root.')
        stub_resolution(resolution_success)
        stub_authorization(ServiceResponse.success)
      end

      it 'carries the history of the same participant' do
        expect(goal_for(build_service)).to include('where is the README?', 'In the project root.')
      end

      it 'keeps another sender in the same group out of the history' do
        expect(goal_for(build_service(from: 'feishu-user-2'))).not_to include('where is the README?')
      end

      it 'keeps a topic in the same group out of the history' do
        expect(goal_for(build_service(in_thread: 'omt_topic'))).not_to include('where is the README?')
      end

      it 'keeps another GitLab user bound to the same sender out of the history' do
        expect(goal_for(build_service(for_user: create(:user)))).not_to include('where is the README?')
      end
    end

    context 'with a session waiting on a tool call' do
      let_it_be(:workflow, freeze: false) do
        create(:duo_workflows_workflow, :tool_call_approval_required,
          user: user,
          project: project,
          workflow_definition: 'feishu_assistant/v1',
          messaging_callback_context: { 'adapter' => 'feishu', 'message_id' => 'om_earlier' })
      end

      let(:message) { '同意' }
      let(:decision_result) { ServiceResponse.success(payload: { card_rolled: false }) }
      let(:pending) { instance_double(::Ai::DuoWorkflows::PendingToolApproval, fingerprint: 'fp-pending') }

      before do
        session_store.store!(workflow.id)
        allow(::Ai::DuoWorkflows::PendingToolApproval).to receive(:for).with(workflow).and_return(pending)
        allow(::Ai::Messaging::ApprovalDecisionService).to receive(:new)
          .and_return(instance_double(::Ai::Messaging::ApprovalDecisionService, execute: decision_result))
      end

      it 'decides the pending call instead of starting a turn', :aggregate_failures do
        expect(::Ai::Messaging::ApprovalDecisionService).to receive(:new).with(
          workflow: workflow,
          current_user: user,
          adapter: an_instance_of(::Ai::Messaging::Adapters::Feishu),
          approved: true,
          fingerprint: 'fp-pending',
          message: nil,
          note: 'Approved. Duo is continuing.'
        )
        allow_next_instance_of(::Ai::Messaging::Adapters::Feishu) do |adapter|
          expect(adapter).not_to receive(:trigger)
        end

        expect(service.execute).to eq(s_('JH|DuoFeishu|Duo is working on it…'))
      end

      it 'says what a rejection did' do
        expect(build_service(text: '拒绝').execute).to eq(s_('JH|DuoFeishu|Cancelled that action.'))
      end

      context 'when the decision is refused' do
        let(:decision_result) { ServiceResponse.error(message: 'forbidden', reason: :forbidden) }

        it 'answers with why' do
          expect(service.execute).to include("don't have access to Duo")
        end
      end

      it 'does not let another sender in the group decide', :aggregate_failures do
        stub_resolution(resolution_success)
        stub_authorization(ServiceResponse.success)
        allow_next_instance_of(::Ai::Messaging::Adapters::Feishu) do |adapter|
          allow(adapter).to receive(:trigger).and_return(ServiceResponse.success(payload: { workflow: nil }))
        end

        expect(::Ai::Messaging::ApprovalDecisionService).not_to receive(:new)

        build_service(from: 'feishu-user-2').execute
      end

      context 'when the request was already handled' do
        let(:decision_result) { ServiceResponse.error(message: 'gone', reason: :approval_not_pending) }

        it 'says so' do
          expect(service.execute).to include('no longer waiting for your decision')
        end
      end
    end

    context 'when rate limited' do
      before do
        allow(::Gitlab::ApplicationRateLimiter).to receive(:throttled?)
          .with(:feishu_duo_chat, scope: { user: user }).and_return(true)
      end

      it 'returns the throttle hint without triggering' do
        expect(::Ai::Messaging::Adapters::Feishu).not_to receive(:new)

        expect(service.execute).to eq(
          s_('JH|DuoFeishu|You are sending messages too quickly. Wait a moment and try again.')
        )
      end
    end

    context 'with a reset command' do
      let(:message) { '/reset' }

      it 'clears only this conversation', :aggregate_failures do
        session_store.start_turn!('an earlier question')
        other = ::Gitlab::Feishu::DuoSessionStore.new(
          app_id: 'cli_app', chat_id: 'oc_other', sender_id: sender_id, user_id: user.id
        )
        other.start_turn!('elsewhere')

        expect(service.execute).to eq(
          s_('JH|DuoFeishu|Cleared the conversation. Your next message starts a new session.')
        )
        expect(session_store.transcript).to be_empty
        expect(other.transcript.pluck('text')).to eq(['elsewhere'])
      end
    end
  end
end
