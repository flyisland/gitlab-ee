# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoWorkflows::CheckpointBlob, feature_category: :duo_agent_platform do
  let_it_be(:workflow) { create(:duo_workflows_workflow) }

  subject(:blob) { build(:duo_workflows_checkpoint_blob, workflow: workflow) }

  describe 'associations' do
    it { is_expected.to belong_to(:workflow).class_name('Ai::DuoWorkflows::Workflow') }
    it { is_expected.to belong_to(:project).optional }
    it { is_expected.to belong_to(:namespace).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:workflow) }
    it { is_expected.to validate_presence_of(:thread_ts) }
    it { is_expected.to validate_presence_of(:channel) }
    it { is_expected.to validate_presence_of(:version) }
    it { is_expected.to validate_presence_of(:write_type) }
    it { is_expected.to validate_presence_of(:step_action) }
    it { is_expected.to validate_inclusion_of(:step_action).in_array(%w[conversation compaction]) }
    it { is_expected.to validate_presence_of(:data) }
    it { is_expected.to validate_length_of(:data).is_at_most(described_class::BLOB_DATA_LIMIT) }
  end

  describe '.for_thread_ts' do
    let_it_be(:on_chain) { create(:duo_workflows_checkpoint_blob, workflow: workflow, thread_ts: 'ts-1') }
    let_it_be(:off_chain) { create(:duo_workflows_checkpoint_blob, workflow: workflow, thread_ts: 'ts-2') }

    it 'returns the blobs on the given thread_ts' do
      expect(described_class.for_thread_ts(%w[ts-1 ts-3]).pluck(:thread_ts)).to eq(%w[ts-1])
    end

    it 'accepts a single thread_ts' do
      expect(described_class.for_thread_ts('ts-1').pluck(:thread_ts)).to eq(%w[ts-1])
    end

    it 'returns no blobs for an empty chain' do
      expect(described_class.for_thread_ts([])).to be_empty
    end

    it 'matches a thread_ts that contains array literal syntax' do
      thread_ts = %q(a,b"{c}\d'e)
      create(:duo_workflows_checkpoint_blob, workflow: workflow, thread_ts: thread_ts)

      expect(described_class.for_thread_ts([thread_ts, 'ts-1']).pluck(:thread_ts)).to contain_exactly(thread_ts, 'ts-1')
    end

    it 'passes the chain as one array literal, not an IN list' do
      expect(described_class.for_thread_ts(%w[ts-1 ts-2]).to_sql)
        .to include(%q(.thread_ts = ANY(ARRAY(SELECT unnest('{ts-1,ts-2}'::text[])))))
    end
  end

  describe 'syncing workflow container' do
    context 'with a project-level workflow' do
      it 'sets project_id from the workflow' do
        blob.valid?
        expect(blob.project_id).to eq(workflow.project_id)
      end
    end

    context 'with a namespace-level workflow' do
      let_it_be(:workflow) { create(:duo_workflows_workflow, namespace: create(:group)) }

      it 'sets namespace_id from the workflow' do
        blob.valid?
        expect(blob.namespace_id).to eq(workflow.namespace_id)
      end
    end
  end
end
