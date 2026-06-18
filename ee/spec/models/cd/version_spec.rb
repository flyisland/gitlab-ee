# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::Version, feature_category: :continuous_delivery do
  let_it_be(:artifact_source) { create(:cd_artifact_source) }

  describe 'associations' do
    it { is_expected.to belong_to(:artifact_source).required }
    it { is_expected.to have_many(:version_set_entries) }
  end

  describe 'validations' do
    subject { build(:cd_version, artifact_source: artifact_source) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }

    describe 'name format' do
      it { is_expected.to allow_value('my-version').for(:name) }
      it { is_expected.to allow_value('my_version').for(:name) }
      it { is_expected.to allow_value('MyVersion').for(:name) }
      it { is_expected.to allow_value('version1').for(:name) }
      it { is_expected.to allow_value('1version').for(:name) }
      it { is_expected.not_to allow_value('-version').for(:name) }
      it { is_expected.not_to allow_value('version-').for(:name) }
      it { is_expected.not_to allow_value('my version').for(:name) }
      it { is_expected.not_to allow_value('version/name').for(:name) }
      it { is_expected.not_to allow_value('version.name').for(:name) }
      it { is_expected.not_to allow_value('version!').for(:name) }
    end

    it { is_expected.to validate_length_of(:digest).is_at_most(255) }
    it { is_expected.to validate_length_of(:reference).is_at_most(1024) }

    it 'enforces uniqueness of name scoped to artifact_source_id at the database level' do
      create(:cd_version, artifact_source: artifact_source, name: 'v1_0_0')

      expect { create(:cd_version, artifact_source: artifact_source, name: 'v1_0_0') }
        .to raise_error(ActiveRecord::RecordInvalid, /Name has already been taken/)
    end
  end

  describe 'sharding key' do
    subject { build(:cd_version, artifact_source: artifact_source) }

    it { is_expected.to populate_sharding_key(:organization_id).with(artifact_source.organization_id) }
  end
end
