# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::ScanProfileTrigger, feature_category: :security_testing_configuration do
  let_it_be(:group) { create(:group) }
  let_it_be(:scan_profile) { create(:security_scan_profile, namespace: group) }

  describe 'associations' do
    it { is_expected.to belong_to(:scan_profile).class_name('Security::ScanProfile').required }
    it { is_expected.to belong_to(:namespace).required }
  end

  describe 'validations' do
    subject { create(:security_scan_profile_trigger, namespace: group, scan_profile: scan_profile) }

    it { is_expected.to validate_presence_of(:trigger_type) }
    it { is_expected.to validate_uniqueness_of(:security_scan_profile_id).scoped_to(:trigger_type) }

    describe '#trigger_type_compatible_with_profile' do
      using RSpec::Parameterized::TableSyntax

      let_it_be(:scanner_profile) { scan_profile }
      let_it_be(:post_processing_profile) do
        create(:security_scan_profile, :dependency_scanning_post_processing, namespace: group)
      end

      where(:trigger_type, :profile_kind, :expected_error) do
        :default_branch_pipeline | :scanner         | nil
        :default_branch_pipeline | :post_processing | 'is not allowed on post processing scan profiles'
        :merge_request_pipeline  | :scanner         | nil
        :merge_request_pipeline  | :post_processing | 'is not allowed on post processing scan profiles'
        :git_push_event          | :scanner         | nil
        :git_push_event          | :post_processing | nil
        :sbom_ingested           | :scanner         | 'is only allowed on post processing scan profiles'
        :sbom_ingested           | :post_processing | nil
      end

      with_them do
        let(:profile) { profile_kind == :scanner ? scanner_profile : post_processing_profile }

        subject(:trigger) do
          build(:security_scan_profile_trigger,
            namespace: group,
            scan_profile: profile,
            trigger_type: trigger_type)
        end

        it 'enforces the compatibility matrix', :aggregate_failures do
          if expected_error.nil?
            expect(trigger).to be_valid
          else
            expect(trigger).not_to be_valid
            expect(trigger.errors[:trigger_type]).to include(expected_error)
          end
        end
      end
    end
  end

  context 'with loose foreign key on namespaces.id' do
    it_behaves_like 'cleanup by a loose foreign key' do
      let_it_be(:parent) { group }
      let_it_be(:model) { create(:security_scan_profile_trigger, scan_profile: scan_profile, namespace: parent) }
    end
  end
end
