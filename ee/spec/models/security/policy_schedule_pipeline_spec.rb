# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::PolicySchedulePipeline, feature_category: :security_policy_management do
  describe 'associations' do
    it { is_expected.to belong_to(:security_policy).class_name('Security::Policy') }
    it { is_expected.to belong_to(:pipeline).class_name('Ci::Pipeline') }
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    subject { build(:security_policy_schedule_pipeline) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:security_policy) }
    it { is_expected.to validate_presence_of(:pipeline) }
    it { is_expected.to validate_presence_of(:project) }

    describe 'uniqueness of pipeline' do
      let_it_be(:existing_record) { create(:security_policy_schedule_pipeline) }

      it 'validates uniqueness of pipeline' do
        new_record = build(:security_policy_schedule_pipeline, pipeline: existing_record.pipeline)

        expect(new_record).not_to be_valid
        expect(new_record.errors[:pipeline]).to include('has already been taken')
      end
    end
  end

  describe '.safe_create' do
    let_it_be(:project) { create(:project) }
    let_it_be(:policy) { create(:security_policy, :pipeline_execution_schedule_policy) }
    let_it_be(:pipeline) { create(:ci_pipeline, project: project) }

    it 'creates a record' do
      expect { described_class.safe_create(security_policy: policy, pipeline: pipeline, project: project) }
        .to change { described_class.count }.by(1)
    end

    context 'when the record is invalid' do
      it 'tracks the exception and does not raise' do
        expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
          an_instance_of(ActiveRecord::RecordInvalid),
          security_policy_id: policy.id,
          pipeline_id: pipeline.id
        )

        expect { described_class.safe_create(security_policy: policy, pipeline: pipeline, project: nil) }
          .not_to raise_error
      end
    end

    context 'when the record already exists' do
      before do
        described_class.safe_create(security_policy: policy, pipeline: pipeline, project: project)
      end

      it 'does not raise an error' do
        expect { described_class.safe_create(security_policy: policy, pipeline: pipeline, project: project) }
          .not_to raise_error
      end

      it 'does not create a duplicate record' do
        expect { described_class.safe_create(security_policy: policy, pipeline: pipeline, project: project) }
          .not_to change { described_class.count }
      end
    end

    context 'when a race condition triggers RecordNotUnique' do
      before do
        allow(described_class).to receive(:create!).and_raise(ActiveRecord::RecordNotUnique)
      end

      it 'returns nil and does not raise' do
        result = described_class.safe_create(security_policy: policy, pipeline: pipeline, project: project)

        expect(result).to be_nil
      end
    end
  end
end
