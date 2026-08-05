# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::ApplicationFlowDefinition, feature_category: :continuous_delivery do
  let_it_be(:application) { create(:cd_application) }

  describe 'associations' do
    it { is_expected.to belong_to(:application).required }
  end

  describe 'sharding key' do
    subject { build(:cd_application_flow_definition, application: application) }

    it { is_expected.to populate_sharding_key(:organization_id).with(application.organization_id) }
  end

  describe 'definition storage' do
    it 'persists the definition in object storage and reads it back' do
      content = "stages:\n  - build\n  - deploy\n"

      flow_definition = create(:cd_application_flow_definition, application: application, definition: content)

      expect(flow_definition.file_store).to eq(ObjectStorage::Store::LOCAL)
      expect(flow_definition.file.filename).to eq('definition.yml')
      expect(flow_definition.reload.definition).to eq(content)
    end
  end

  describe 'validations' do
    subject { build(:cd_application_flow_definition, application: application) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:definition) }
    it { is_expected.to validate_length_of(:definition).is_at_most(1.megabyte) }

    describe 'version' do
      it { is_expected.to validate_numericality_of(:version).only_integer.is_greater_than(0) }

      it 'enforces uniqueness of version scoped to application_id' do
        create(:cd_application_flow_definition, application: application, version: 2)

        duplicate = build(:cd_application_flow_definition, application: application, version: 2)

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:version]).to include('has already been taken')
      end
    end

    describe 'application organization' do
      it 'is invalid when the application belongs to a different organization' do
        other_organization = create(:organization)

        flow_definition = build(:cd_application_flow_definition, application: application,
          organization_id: other_organization.id)

        expect(flow_definition).not_to be_valid
        expect(flow_definition.errors[:application]).to include('must belong to the same organization.')
      end
    end
  end

  describe 'immutability' do
    let_it_be(:original) { "stages: []\n" }
    let_it_be(:flow_definition) do
      create(:cd_application_flow_definition, application: application, definition: original)
    end

    it 'raises when the definition content is changed' do
      expect { flow_definition.update!(definition: "stages: [changed]\n") }
        .to raise_error(ActiveRecord::ReadOnlyRecord)

      expect(flow_definition.reload.definition).to eq(original)
    end

    it 'raises when another attribute is changed' do
      expect { flow_definition.update!(version: 99) }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end

    it 'does not raise when creating a new version' do
      expect { create(:cd_application_flow_definition, application: application) }.not_to raise_error
    end
  end

  describe 'version assignment' do
    it 'assigns version 1 to the first definition for an application' do
      definition = create(:cd_application_flow_definition, application: application)

      expect(definition.version).to eq(1)
    end

    it 'increments the version per application on each save' do
      create(:cd_application_flow_definition, application: application)
      second = create(:cd_application_flow_definition, application: application)

      expect(second.version).to eq(2)
    end

    it 'numbers versions independently per application' do
      other_application = create(:cd_application)
      create(:cd_application_flow_definition, application: application)

      definition = create(:cd_application_flow_definition, application: other_application)

      expect(definition.version).to eq(1)
    end

    it 'respects an explicitly provided version' do
      definition = create(:cd_application_flow_definition, application: application, version: 5)

      expect(definition.version).to eq(5)
    end
  end

  describe '.ordered' do
    it 'returns definitions newest version first' do
      first = create(:cd_application_flow_definition, application: application)
      second = create(:cd_application_flow_definition, application: application)

      expect(described_class.for_application(application.id).ordered).to eq([second, first])
    end
  end

  describe '#revert_to_previous_version' do
    it 'appends a new version copying the previous version definition' do
      create(:cd_application_flow_definition, application: application, definition: "stages: []\n")
      latest = create(:cd_application_flow_definition, application: application, definition: "stages: [build]\n")

      reverted = latest.revert_to_previous_version

      expect(reverted.version).to eq(3)
      expect(reverted.definition).to eq("stages: []\n")
    end

    it 'preserves the reverted-to version' do
      first = create(:cd_application_flow_definition, application: application)
      latest = create(:cd_application_flow_definition, application: application)

      latest.revert_to_previous_version

      expect(described_class.for_application(application.id)).to include(first)
    end

    it 'reverts using only the application own versions' do
      create(:cd_application_flow_definition, application: application, definition: "stages: []\n")
      latest = create(:cd_application_flow_definition, application: application, definition: "stages: [build]\n")
      create(:cd_application_flow_definition, definition: "stages: [from-other]\n")

      reverted = latest.revert_to_previous_version

      expect(reverted.definition).to eq("stages: []\n")
    end

    it 'returns nil and creates nothing when there is no previous version' do
      only = create(:cd_application_flow_definition, application: application)

      expect { expect(only.revert_to_previous_version).to be_nil }
        .not_to change { described_class.for_application(application.id).count }
    end
  end
end
