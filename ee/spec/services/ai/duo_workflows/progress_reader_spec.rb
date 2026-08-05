# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoWorkflows::ProgressReader, feature_category: :duo_agent_platform do
  let_it_be_with_reload(:workflow) { create(:duo_workflows_workflow) }

  let(:reader) { described_class.new }

  def create_checkpoint(thread_ts:, messages:)
    create(:duo_workflows_checkpoint,
      workflow: workflow,
      thread_ts: thread_ts,
      checkpoint: { 'channel_values' => { 'ui_chat_log' => messages } })
  end

  def msg(id, type: 'agent', content: 'hi', tool: nil)
    {
      'message_id' => id,
      'message_type' => type,
      'content' => content,
      'tool_info' => tool && { 'name' => tool }
    }
  end

  describe '#delta_since' do
    context 'when there are no checkpoints' do
      it 'returns an empty delta and preserves the cursor', :aggregate_failures do
        delta = reader.delta_since(workflow, cursor: { 'thread_ts' => 'x' })

        expect(delta).to be_empty
        expect(delta.cursor).to eq({ 'thread_ts' => 'x' })
      end
    end

    context 'with a nil cursor (first read)' do
      before do
        create_checkpoint(thread_ts: '001', messages: [msg('a'), msg('b', tool: 'todo_write')])
      end

      it 'returns the whole log and a cursor pointing at the last message', :aggregate_failures do
        delta = reader.delta_since(workflow, cursor: nil)

        expect(delta.messages.map { |m| m['message_id'] }).to eq(%w[a b])
        expect(delta.cursor).to eq({ 'thread_ts' => '001', 'message_id' => 'b' })
      end
    end

    context 'when the latest checkpoint has not advanced' do
      before do
        create_checkpoint(thread_ts: '001', messages: [msg('a')])
      end

      it 'returns an empty delta (cheap no-op guard)' do
        delta = reader.delta_since(workflow, cursor: { 'thread_ts' => '001', 'message_id' => 'a' })

        expect(delta).to be_empty
      end
    end

    context 'when new messages were appended in a newer checkpoint' do
      before do
        create_checkpoint(thread_ts: '001', messages: [msg('a'), msg('b')])
        create_checkpoint(thread_ts: '002', messages: [msg('a'), msg('b'), msg('c'), msg('d')])
      end

      it 'returns only the entries after the cursor', :aggregate_failures do
        delta = reader.delta_since(workflow, cursor: { 'thread_ts' => '001', 'message_id' => 'b' })

        expect(delta.messages.map { |m| m['message_id'] }).to eq(%w[c d])
        expect(delta.cursor).to eq({ 'thread_ts' => '002', 'message_id' => 'd' })
      end
    end

    context 'when the cursor message_id is no longer present (e.g. compaction)' do
      before do
        create_checkpoint(thread_ts: '002', messages: [msg('x'), msg('y')])
      end

      it 'falls back to returning the whole log' do
        delta = reader.delta_since(workflow, cursor: { 'thread_ts' => '001', 'message_id' => 'gone' })

        expect(delta.messages.map { |m| m['message_id'] }).to eq(%w[x y])
      end
    end
  end
end
