# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::ArtifactSource, feature_category: :continuous_delivery do
  let_it_be(:service) { create(:cd_service) }

  describe 'associations' do
    it { is_expected.to belong_to(:service).required }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:versions) }
  end

  describe 'enums' do
    it 'defines source_type with the expected values' do
      is_expected.to define_enum_for(:source_type).with_values(
        internal_pipeline: 0,
        external_registry: 1,
        desired_state: 2
      )
    end
  end

  describe 'defaults' do
    it 'defaults source_type to internal_pipeline' do
      expect(described_class.new.source_type).to eq('internal_pipeline')
    end
  end

  describe 'validations' do
    subject { build(:cd_artifact_source, service: service) }

    it { is_expected.to be_valid }

    it 'enforces uniqueness of service_id at the database level' do
      create(:cd_artifact_source, service: service)

      expect { create(:cd_artifact_source, service: service) }
        .to raise_error(ActiveRecord::RecordInvalid, /Service has already been taken/)
    end

    context 'when source_type is internal_pipeline' do
      it 'requires a project' do
        artifact_source = build(:cd_artifact_source, service: service, project: nil)

        expect(artifact_source).not_to be_valid
        expect(artifact_source.errors[:project]).to include("can't be blank")
      end

      it 'enforces project presence at the database level' do
        artifact_source = build(:cd_artifact_source, service: service, project: nil,
          organization_id: service.organization_id)

        expect { artifact_source.save!(validate: false) }
          .to raise_error(ActiveRecord::StatementInvalid, /check_project_id_present_when_internal_pipeline/)
      end
    end

    context 'when source_type is external_registry' do
      it 'does not require project_id' do
        expect(build(:cd_artifact_source, :external_registry, service: service)).to be_valid
      end
    end

    context 'when source_type is desired_state' do
      it 'does not require project_id' do
        expect(build(:cd_artifact_source, :desired_state, service: service)).to be_valid
      end
    end

    context 'when project belongs to a different organization than the service group' do
      let_it_be(:other_organization) { create(:organization) }
      let_it_be(:other_project) { create(:project, organization: other_organization) }

      it 'is invalid' do
        artifact_source = build(:cd_artifact_source, service: service, project: other_project)

        expect(artifact_source).not_to be_valid
        expect(artifact_source.errors[:project])
          .to include("must belong to the same organization.")
      end
    end

    context 'when project belongs to the same organization as the service' do
      it 'is valid' do
        same_org_project = create(:project, organization: service.organization)

        expect(build(:cd_artifact_source, service: service, project: same_org_project)).to be_valid
      end
    end
  end

  describe 'sharding key' do
    subject { build(:cd_artifact_source, service: service) }

    it { is_expected.to populate_sharding_key(:organization_id).with(service.organization_id) }
  end
end
