# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::VersionSet, feature_category: :continuous_delivery do
  let_it_be(:application) { create(:cd_application) }

  describe 'associations' do
    it { is_expected.to belong_to(:application).required }
    it { is_expected.to have_many(:version_set_entries) }
    it { is_expected.to have_many(:versions).through(:version_set_entries) }
  end

  describe 'validations' do
    subject { build(:cd_version_set, application: application) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }

    describe 'name format' do
      it { is_expected.to allow_value('my-version-set').for(:name) }
      it { is_expected.to allow_value('my_version_set').for(:name) }
      it { is_expected.to allow_value('MyVersionSet').for(:name) }
      it { is_expected.to allow_value('versionset1').for(:name) }
      it { is_expected.to allow_value('1versionset').for(:name) }
      it { is_expected.not_to allow_value('-versionset').for(:name) }
      it { is_expected.not_to allow_value('versionset-').for(:name) }
      it { is_expected.not_to allow_value('my version set').for(:name) }
      it { is_expected.not_to allow_value('versionset/name').for(:name) }
      it { is_expected.not_to allow_value('versionset.name').for(:name) }
      it { is_expected.not_to allow_value('versionset!').for(:name) }
    end

    it 'enforces uniqueness of name scoped to application_id' do
      create(:cd_version_set, application: application, name: 'release-1')

      expect { create(:cd_version_set, application: application, name: 'release-1') }
        .to raise_error(ActiveRecord::RecordInvalid, /Name has already been taken/)
    end
  end

  describe 'sharding key' do
    subject { build(:cd_version_set, application: application) }

    it { is_expected.to populate_sharding_key(:organization_id).with(application.organization_id) }
  end
end
