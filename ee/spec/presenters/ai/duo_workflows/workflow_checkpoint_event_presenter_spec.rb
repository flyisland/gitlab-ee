# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Ai::DuoWorkflows::WorkflowCheckpointEventPresenter, feature_category: :duo_agent_platform do
  let(:checkpoint) { build_stubbed(:duo_workflows_checkpoint) }
  let_it_be(:user) { build_stubbed(:user) }

  subject(:presenter) { described_class.new(checkpoint, current_user: user) }

  describe 'thread_ts' do
    it 'returns the checkpoint thread_ts' do
      expect(presenter.thread_ts).to eq(checkpoint.thread_ts)
    end
  end

  describe 'parent_ts' do
    it 'returns nil if the checkpoint has no parent ts' do
      checkpoint.parent_ts = nil
      expect(presenter.parent_ts).to be_nil
    end

    it 'returns the checkpoint parent_ts' do
      expect(presenter.parent_ts).to eq(checkpoint.parent_ts)
    end
  end

  describe 'metadata' do
    it 'returns the checkpoint metadata' do
      expect(presenter.metadata).to eq(checkpoint.metadata)
    end
  end

  describe 'checkpoint' do
    it 'returns the checkpoint' do
      expect(presenter.checkpoint).to eq(checkpoint.checkpoint)
    end
  end

  describe 'workflow_status' do
    it 'returns the workflow status' do
      expect(presenter.workflow_status).to eq(checkpoint.workflow.status)
    end
  end

  describe 'execution_status' do
    context 'when checkpoint channel values is empty' do
      it 'returns the workflow status' do
        expect(presenter.execution_status).to eq(checkpoint.workflow.human_status_name.titleize)
      end
    end

    context 'when graph execution has started' do
      let(:checkpoint_data) do
        {
          'channel_values' =>
            {
              'plan' => { 'steps' => [] },
              'status' => 'Planning',
              'handover' => [],
              'ui_chat_log' => [],
              'last_human_input' => nil,
              'conversation_history' => {}
            }
        }
      end

      before do
        checkpoint.checkpoint = checkpoint_data
      end

      it 'returns the graph execution status' do
        expect(presenter.execution_status).to eq('Planning')
      end
    end

    context 'when graph execution has not started' do
      let(:checkpoint_data) do
        {
          'channel_values' =>
            {
              'plan' => { 'steps' => [] },
              'status' => 'Not Started',
              'handover' => [],
              'ui_chat_log' => [],
              'last_human_input' => nil,
              'conversation_history' => {}
            }
        }
      end

      before do
        checkpoint.checkpoint = checkpoint_data
      end

      it 'returns the workflow status' do
        expect(presenter.execution_status).to eq(checkpoint.workflow.human_status_name.titleize)
      end
    end
  end

  describe 'duo_messages' do
    let(:checkpoint_data) do
      {
        'channel_values' =>
          {
            'ui_chat_log' => ui_chat_log
          }
      }
    end

    before do
      checkpoint.checkpoint = checkpoint_data
    end

    context 'when all supported fields are present' do
      let(:ui_chat_log) do
        [
          {
            'content' => 'Delegating task',
            'message_type' => 'system',
            'status' => 'in_progress',
            'tool_info' => { 'tool_name' => 'todo_write' },
            'timestamp' => '2026-01-01T00:00:00Z',
            'correlation_id' => 'abc-123',
            'role' => 'assistant',
            'message_sub_type' => 'delegation',
            'component_name' => 'duo_developer',
            'subsession_id' => 'session-1'
          }
        ]
      end

      it 'passes through new fields' do
        message = presenter.duo_messages.first

        expect(message.message_sub_type).to eq('delegation')
        expect(message.component_name).to eq('duo_developer')
        expect(message.subsession_id).to eq('session-1')
      end

      it 'preserves existing fields' do
        message = presenter.duo_messages.first

        expect(message.content).to eq('Delegating task')
        expect(message.message_type).to eq('system')
        expect(message.status).to eq('in_progress')
        expect(message.tool_info).to eq({ 'tool_name' => 'todo_write' })
        expect(message.timestamp).to eq('2026-01-01T00:00:00Z')
        expect(message.correlation_id).to eq('abc-123')
        expect(message.role).to eq('assistant')
      end
    end

    context 'when new fields are missing' do
      let(:ui_chat_log) do
        [
          {
            'content' => 'Legacy message',
            'message_type' => 'request',
            'status' => 'done',
            'tool_info' => nil,
            'timestamp' => '2026-01-01T00:00:00Z',
            'correlation_id' => 'legacy-1',
            'role' => 'user'
          }
        ]
      end

      it 'defaults new fields to nil' do
        message = presenter.duo_messages.first

        expect(message.message_sub_type).to be_nil
        expect(message.component_name).to be_nil
        expect(message.subsession_id).to be_nil
      end
    end
  end

  describe 'workflow_goal' do
    it 'returns the workflow goal' do
      expect(presenter.workflow_goal).to eq(checkpoint.workflow.goal)
    end
  end

  describe 'workflow_definition' do
    it 'returns the workflow definition' do
      expect(presenter.workflow_definition).to eq(checkpoint.workflow.workflow_definition)
    end
  end

  describe '#duo_messages' do
    let(:checkpoint_data) do
      {
        'channel_values' => {
          'ui_chat_log' => [
            {
              'content' => 'hi',
              'message_type' => 'user',
              'message_sub_type' => 'start_flow',
              'status' => 'success',
              'tool_info' => nil,
              'timestamp' => '2025-11-25T21:10:57.734182+00:00',
              'correlation_id' => 'corr-123',
              'role' => nil,
              'message_id' => 'msg-123',
              'additional_context' => [{ 'id' => 'context-item-1', 'type' => 'file' }]
            }
          ]
        }
      }
    end

    before do
      checkpoint.checkpoint = checkpoint_data
    end

    it 'extracts message_id, message_sub_type, and additional_context from the checkpoint chat log',
      :aggregate_failures do
      message = presenter.duo_messages.first

      expect(message.message_id).to eq('msg-123')
      expect(message.message_sub_type).to eq('start_flow')
      expect(message.additional_context).to match_array([{ 'id' => 'context-item-1', 'type' => 'file' }])
    end
  end

  describe 'workflow_summary' do
    it 'returns the workflow summary' do
      expect(presenter.workflow_summary).to eq(checkpoint.workflow.summary)
    end
  end
end
