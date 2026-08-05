# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::EnvironmentDriverBinding, feature_category: :continuous_delivery do
  let_it_be(:environment) { create(:cd_environment) }

  describe 'factory' do
    it 'creates a valid driver binding using factory defaults' do
      expect(create(:cd_environment_driver_binding)).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:environment).required }
    it { is_expected.to belong_to(:organization).required }
    it { is_expected.to have_many(:rollout_environments) }
  end

  describe 'scopes' do
    describe '.ordered' do
      it 'orders by version descending' do
        environment = create(:cd_environment)
        older = create(:cd_environment_driver_binding, environment: environment, version: 1)
        newer = create(:cd_environment_driver_binding, environment: environment, version: 2)

        expect(described_class.ordered).to eq([newer, older])
      end
    end
  end

  describe 'validations' do
    subject { build(:cd_environment_driver_binding, environment: environment) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:driver_ref) }
    it { is_expected.to validate_length_of(:driver_ref).is_at_most(255) }
    it { is_expected.to validate_presence_of(:version) }

    it 'rejects a duplicate version for the same environment' do
      create(:cd_environment_driver_binding, environment: environment, version: 1)

      duplicate = build(:cd_environment_driver_binding, environment: environment, version: 1)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:version]).to be_present
    end

    it 'allows the same version on a different environment' do
      create(:cd_environment_driver_binding, environment: environment, version: 1)

      other = build(:cd_environment_driver_binding, environment: create(:cd_environment), version: 1)

      expect(other).to be_valid
    end

    it 'rejects a non-object driver_config' do
      binding = build(:cd_environment_driver_binding, environment: environment, driver_config: [])

      expect(binding).not_to be_valid
    end
  end

  describe 'sharding key' do
    subject { build(:cd_environment_driver_binding, environment: environment) }

    it { is_expected.to populate_sharding_key(:organization_id).with(environment.organization_id) }
  end

  describe 'append-only' do
    it 'prevents modification of a persisted record' do
      binding = create(:cd_environment_driver_binding, environment: environment)

      expect { binding.update!(driver_ref: 'changed') }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end
end
