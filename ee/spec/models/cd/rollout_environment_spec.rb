# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::RolloutEnvironment, feature_category: :continuous_delivery do
  let_it_be(:rollout) { create(:cd_rollout) }
  let_it_be(:environment) { create(:cd_environment) }

  describe 'factory' do
    it 'creates a valid rollout environment using factory defaults' do
      expect(create(:cd_rollout_environment)).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:rollout).required }
    it { is_expected.to belong_to(:environment).required }
    it { is_expected.to belong_to(:driver_binding).required }
    it { is_expected.to belong_to(:previous_version_set).optional }
    it { is_expected.to belong_to(:organization).required }
    it { is_expected.to have_many(:deployments) }
  end

  describe 'enums' do
    it 'defines state enum' do
      is_expected.to define_enum_for(:state).with_values(
        pending: 0,
        in_progress: 1,
        paused: 2,
        completed: 3,
        failed: 4,
        cancelled: 5
      )
    end
  end

  describe 'scopes' do
    describe '.ordered' do
      it 'returns rollout environments ordered by position ascending' do
        # Created out of position order so the assertion proves the scope reorders them.
        second = create(:cd_rollout_environment, rollout: rollout, position: 2)
        first = create(:cd_rollout_environment, rollout: rollout, position: 1)

        expect(described_class.where(rollout: rollout).ordered).to eq([first, second])
      end
    end
  end

  describe 'validations' do
    subject { build(:cd_rollout_environment, rollout: rollout, environment: environment) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:position) }

    it 'rejects a second rollout environment for the same environment in the same rollout' do
      create(:cd_rollout_environment, rollout: rollout, environment: environment)

      duplicate = build(:cd_rollout_environment, rollout: rollout, environment: environment)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:environment_id]).to include('already has a rollout environment in this rollout')
    end
  end

  describe 'sharding key' do
    subject { build(:cd_rollout_environment, rollout: rollout, environment: environment) }

    it { is_expected.to populate_sharding_key(:organization_id).with(rollout.organization_id) }
  end
end
