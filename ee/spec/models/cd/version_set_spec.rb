# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::VersionSet, feature_category: :continuous_delivery do
  let_it_be(:application) { create(:cd_application) }

  describe 'associations' do
    it { is_expected.to belong_to(:application).required }
    it { is_expected.to have_many(:version_set_entries) }
    it { is_expected.to have_many(:versions).through(:version_set_entries) }
    it { is_expected.to have_many(:rollout_environments) }
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

    it 'enforces uniqueness of entries_digest scoped to application_id, allowing nil' do
      create(:cd_version_set, application: application, name: 'release-1').update_column(:entries_digest, 'abc123')

      expect(build(:cd_version_set, application: application, name: 'release-2', entries_digest: 'abc123'))
        .not_to be_valid
      expect(build(:cd_version_set, application: application, name: 'release-3', entries_digest: nil)).to be_valid
    end
  end

  describe 'entries digest' do
    let_it_be(:version_set) { create(:cd_version_set, application: application) }
    let_it_be(:entry_a) { create(:cd_version_set_entry, version_set: version_set) }
    let_it_be(:entry_b) { create(:cd_version_set_entry, version_set: version_set) }

    describe '#compute_entries_digest' do
      it 'returns a stable SHA-256 hex digest of the entries' do
        digest = version_set.compute_entries_digest

        expect(digest).to match(/\A[0-9a-f]{64}\z/)
        expect(version_set.reload.compute_entries_digest).to eq(digest)
      end

      it 'returns nil when the version set has no entries' do
        expect(create(:cd_version_set, application: application).compute_entries_digest).to be_nil
      end

      it 'differs from a version set with different entries' do
        other = create(:cd_version_set, application: application)
        create(:cd_version_set_entry, version_set: other)

        expect(other.compute_entries_digest).not_to eq(version_set.compute_entries_digest)
      end
    end

    describe '#update_entries_digest!' do
      it 'persists the computed digest' do
        expected = version_set.compute_entries_digest

        expect { version_set.update_entries_digest! }
          .to change { version_set.reload.entries_digest }.from(nil).to(expected)
      end
    end
  end

  describe 'sharding key' do
    subject { build(:cd_version_set, application: application) }

    it { is_expected.to populate_sharding_key(:organization_id).with(application.organization_id) }
  end
end
