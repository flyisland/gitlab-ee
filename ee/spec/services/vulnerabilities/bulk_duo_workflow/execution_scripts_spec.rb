# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::BulkDuoWorkflow::ExecutionScripts,
  :clean_gitlab_redis_shared_state,
  feature_category: :vulnerability_management do
  using RSpec::Parameterized::TableSyntax

  let(:redis) { Gitlab::Redis::SharedState }
  let(:metadata) { redis.with { |r| r.hgetall(keys[:metadata]) } }
  let(:execution_id) { SecureRandom.uuid }
  let(:fingerprint) { 'abc123' }
  let(:ttl) { 1.hour }

  let(:keys) do
    {
      metadata: '{test:bulk_duo_workflow}:metadata'
    }
  end

  subject(:scripts) { described_class.new(redis: redis, keys: keys, ttl: ttl) }

  describe '#start' do
    before do
      scripts.start(execution_id: execution_id, fingerprint: fingerprint)
    end

    it 'stores execution metadata', :aggregate_failures do
      expect(metadata['execution_id']).to eq(execution_id)
      expect(metadata['fingerprint']).to eq(fingerprint)
      expect(metadata['status']).to eq('running')
      expect(metadata['cancel_requested']).to eq('false')
    end

    it 'does not set ended_at' do
      expect(metadata).not_to have_key('ended_at')
    end

    it 'sets ttl' do
      expect(redis.with { |r| r.ttl(keys[:metadata]) }).to be_between(ttl.to_i - 1, ttl.to_i)
    end

    it 'removes previous ended_at value' do
      redis.with { |r| r.hset(keys[:metadata], 'ended_at', Time.current.iso8601) }

      scripts.start(execution_id: SecureRandom.uuid, fingerprint: fingerprint)

      expect(metadata).not_to have_key('ended_at')
    end
  end

  describe '#cancel' do
    before do
      scripts.start(execution_id: execution_id, fingerprint: fingerprint)
    end

    it 'marks execution cancelled', :aggregate_failures do
      expect(scripts.cancel(execution_id: execution_id)).to eq(:cancelled)

      expect(metadata['status']).to eq('cancelled')
      expect(metadata['cancel_requested']).to eq('true')
      expect(metadata['ended_at']).to be_present
    end

    it 'returns stale for stale execution id' do
      expect(scripts.cancel(execution_id: 'stale')).to eq(:stale)
    end

    context 'when execution does not exist' do
      it 'returns stale' do
        redis.with { |r| r.del(keys[:metadata]) }

        expect(scripts.cancel(execution_id: execution_id)).to eq(:stale)
      end
    end

    context 'with terminal execution state' do
      where(:status, :expected) do
        'completed' | :completed
        'failed'    | :failed
        'cancelled' | :cancelled
      end

      with_them do
        before do
          redis.with { |r| r.hset(keys[:metadata], 'status', status) }
        end

        it 'returns current status without modifying execution', :aggregate_failures do
          expect(scripts.cancel(execution_id: execution_id)).to eq(expected)

          expect(metadata['status']).to eq(status)
          expect(metadata['cancel_requested']).to eq('false')
          expect(metadata).not_to have_key('ended_at')
        end
      end
    end

    it 'does not rewrite cancelled execution' do
      scripts.cancel(execution_id: execution_id)

      expect(scripts.cancel(execution_id: execution_id)).to eq(:cancelled)
    end
  end
end
