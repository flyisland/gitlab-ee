# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::BulkDuoWorkflow::ExecutionState,
  :clean_gitlab_redis_shared_state,
  feature_category: :vulnerability_management do
  using RSpec::Parameterized::TableSyntax

  let(:project) { build_stubbed(:project) }

  let(:execution_id) { state.start!(fingerprint: fingerprint) }
  let(:workflow_name) { :sast_fp_detection }
  let(:fingerprint) { 'abc123' }

  subject(:state) { described_class.new(project: project, workflow_name: workflow_name) }

  describe '#start!' do
    before do
      execution_id
    end

    it 'stores execution metadata', :aggregate_failures do
      snap = state.snapshot

      expect(execution_id).to be_present
      expect(snap[:execution_id]).to eq(execution_id)
      expect(snap[:workflow_name]).to eq(workflow_name)
      expect(snap[:fingerprint]).to eq(fingerprint)
      expect(snap[:status]).to eq(:running)
      expect(snap[:cancel_requested]).to be(false)
      expect(snap[:started_at]).to be_present
      expect(snap[:ended_at]).to be_nil
    end
  end

  describe '#cancel!' do
    before do
      execution_id

      state.cancel!(execution_id)
    end

    it 'marks execution cancelled', :aggregate_failures do
      snap = state.snapshot

      expect(snap[:status]).to eq(:cancelled)
      expect(snap[:cancel_requested]).to be(true)
      expect(snap[:ended_at]).to be_present
    end

    it 'returns stale' do
      expect(state.cancel!('stale')).to eq(:stale)
    end
  end

  describe '#active?' do
    where(:status, :active) do
      nil        | false
      :running   | true
      :completed | false
      :failed    | false
      :cancelled | false
    end

    with_them do
      before do
        allow(state).to receive(:status).and_return(status)
      end

      it 'returns expected state' do
        expect(state.active?).to eq(active)
      end
    end
  end

  describe '#status' do
    where(:cancelled, :status) do
      false | :running
      true  | :cancelled
    end

    with_them do
      before do
        execution_id

        state.cancel!(execution_id) if cancelled
      end

      it 'returns status' do
        expect(state.status).to eq(status)
      end
    end
  end

  describe '#same_fingerprint?' do
    before do
      execution_id
    end

    where(:value, :result) do
      'abc123' | true
      'other'  | false
    end

    with_them do
      it 'compares fingerprints' do
        expect(state.same_fingerprint?(value)).to eq(result)
      end
    end
  end

  describe '#snapshot' do
    before do
      execution_id
    end

    it 'includes workflow name' do
      expect(state.snapshot[:workflow_name]).to eq(workflow_name)
    end
  end
end
