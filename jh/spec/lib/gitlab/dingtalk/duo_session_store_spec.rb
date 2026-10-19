# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Dingtalk::DuoSessionStore, :clean_gitlab_redis_shared_state,
  feature_category: :duo_agent_platform do
  subject(:store) { build_store }

  def build_store(sender_staff_id: 'staff-1', user_id: 7)
    described_class.new(corp_id: 'corp-1', conversation_id: 'cid-1', sender_staff_id: sender_staff_id,
      user_id: user_id)
  end

  def transcript_texts(from = store)
    from.transcript.pluck('text')
  end

  describe '#store! and #current_workflow_id' do
    it 'remembers the latest workflow' do
      store.store!(42)

      expect(store.current_workflow_id).to eq(42)
    end

    it 'keeps sessions apart per sender' do
      store.store!(42)

      expect(build_store(sender_staff_id: 'staff-2').current_workflow_id).to be_nil
    end
  end

  describe '#lock_turn! and #unlock_turn!' do
    it 'lets one holder in at a time', :aggregate_failures do
      token = store.lock_turn!

      expect(token).to be_present
      expect(build_store.lock_turn!).to be_nil

      store.unlock_turn!(token)

      expect(build_store.lock_turn!).to be_present
    end

    it 'leaves a lock taken over by someone else in place' do
      store.lock_turn!
      store.unlock_turn!('stale-token')

      expect(build_store.lock_turn!).to be_nil
    end
  end

  describe '#start_turn!' do
    it 'records the message and hands back the token for the turn', :aggregate_failures do
      token = store.start_turn!('question')

      expect(token).to be_present
      expect(store.transcript).to eq([{ 'role' => 'user', 'text' => 'question' }])
    end

    it 'opens a turn even for a message it has nothing to record' do
      expect(store.start_turn!('')).to be_present
      expect(store.transcript).to be_empty
    end

    it 'supersedes the previous turn' do
      first = store.start_turn!('question')
      store.start_turn!('second question')

      expect(store.record_answer!(first, 'late answer')).to be(false)
    end
  end

  describe '#record_answer!' do
    it 'appends the answer for the turn that is still current', :aggregate_failures do
      token = store.start_turn!('question')

      expect(store.record_answer!(token, 'answer')).to be(true)
      expect(store.transcript).to eq([
        { 'role' => 'user', 'text' => 'question' },
        { 'role' => 'assistant', 'text' => 'answer' }
      ])
    end

    it 'refuses an answer once the conversation was cleared', :aggregate_failures do
      token = store.start_turn!('question')
      store.clear!

      expect(store.record_answer!(token, 'answer')).to be(false)
      expect(store.transcript).to be_empty
    end

    it 'refuses an answer without a token or without text', :aggregate_failures do
      token = store.start_turn!('question')

      expect(store.record_answer!(nil, 'answer')).to be(false)
      expect(store.record_answer!(token, '')).to be(false)
      expect(transcript_texts).to eq(['question'])
    end
  end

  describe '#transcript' do
    it 'keeps only the newest messages', :aggregate_failures do
      token = store.start_turn!('question')
      (described_class::TRANSCRIPT_LIMIT + 1).times { |i| store.record_answer!(token, "answer #{i}") }

      texts = transcript_texts

      expect(texts.size).to eq(described_class::TRANSCRIPT_LIMIT)
      expect(texts.last).to eq("answer #{described_class::TRANSCRIPT_LIMIT}")
      expect(texts).not_to include('question')
    end

    it 'truncates each message it keeps', :aggregate_failures do
      token = store.start_turn!('q' * (described_class::ENTRY_MAX_LENGTH + 1))
      store.record_answer!(token, 'a' * (described_class::ENTRY_MAX_LENGTH + 1))

      expect(transcript_texts.map(&:length)).to all(eq(described_class::ENTRY_MAX_LENGTH))
    end

    it 'keeps no more history than the goal can hold' do
      expect(described_class::TRANSCRIPT_LIMIT * described_class::ENTRY_MAX_LENGTH)
        .to be <= ::Ai::DuoWorkflows::Workflow::GOAL_MAX_LENGTH
    end

    it 'expires with the session' do
      store.start_turn!('question')

      ttl = Gitlab::Redis::SharedState.with do |redis|
        redis.ttl('dingtalk:duo:{corp-1:cid-1:staff-1:7}:transcript')
      end

      expect(ttl).to be_within(5).of(described_class::TTL.to_i)
    end

    # A DingTalk account re-bound to another GitLab user must not hand that user
    # the previous owner's conversation.
    it 'keeps the history apart per GitLab user', :aggregate_failures do
      store.store!(42)
      store.start_turn!('question')
      rebound = build_store(user_id: 8)

      expect(rebound.transcript).to be_empty
      expect(rebound.current_workflow_id).to be_nil
    end

    it 'skips entries it cannot read' do
      Gitlab::Redis::SharedState.with do |redis|
        redis.rpush('dingtalk:duo:{corp-1:cid-1:staff-1:7}:transcript', 'not json')
      end
      store.start_turn!('question')

      expect(transcript_texts).to eq(['question'])
    end
  end

  describe '#clear!' do
    it 'drops the pointer and the history', :aggregate_failures do
      store.store!(42)
      store.start_turn!('question')

      store.clear!

      expect(store.current_workflow_id).to be_nil
      expect(store.transcript).to be_empty
    end
  end
end
