# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['ArtifactRegistryManifest'], feature_category: :artifact_registry do
  using RSpec::Parameterized::TableSyntax

  subject { described_class }

  specify { expect(described_class.graphql_name).to eq('ArtifactRegistryManifest') }

  it { is_expected.to require_graphql_authorizations(:read_artifact_registry) }

  it 'exposes the identifier and the manifest fields the view reads, and nothing it does not' do
    is_expected.to have_graphql_fields(:id, :digest, :media_type, :artifact_type, :subject_digest, :size, :created_at)
  end

  describe 'field types and nullability' do
    where(:field_name, :type_name, :null) do
      'id'            | 'ID'     | false
      'digest'        | 'String' | false
      'mediaType'     | 'String' | false
      'artifactType'  | 'String' | true
      'subjectDigest' | 'String' | true
      'size'          | 'BigInt' | false
      'createdAt'     | 'Time'   | true
    end

    with_them do
      it 'renders the field as the declared type and nullability' do
        field = described_class.fields[field_name]

        expect(field.type.unwrap.graphql_name).to eq(type_name)
        expect(field.type.non_null?).to eq(!null)
      end
    end
  end

  it 'marks every field experiment ahead of general availability' do
    expect(described_class.fields.values)
      .to all(have_attributes(deprecation_reason: a_string_including('Status: Experiment.')))
  end
end
