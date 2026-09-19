# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe ArtifactRegistry::Manifest, feature_category: :artifact_registry do
  let(:attributes) do
    {
      'id' => 'a1b2c3d4-0000-0000-0000-000000000000',
      'digest' => 'sha256:aaaa',
      'media_type' => 'application/vnd.oci.image.manifest.v1+json',
      'artifact_type' => 'application/vnd.example.sbom',
      'subject_digest' => 'sha256:bbbb',
      'size' => 1024,
      'created_at' => '2026-07-03T09:15:00Z'
    }
  end

  subject(:manifest) { described_class.new(attributes) }

  describe 'rendered readers' do
    it 'exposes every documented field, with created_at parsed', :aggregate_failures do
      expect(manifest.id).to eq('a1b2c3d4-0000-0000-0000-000000000000')
      expect(manifest.digest).to eq('sha256:aaaa')
      expect(manifest.media_type).to eq('application/vnd.oci.image.manifest.v1+json')
      expect(manifest.artifact_type).to eq('application/vnd.example.sbom')
      expect(manifest.subject_digest).to eq('sha256:bbbb')
      expect(manifest.size).to eq(1024)
      expect(manifest.created_at).to eq(DateTime.iso8601('2026-07-03T09:15:00Z'))
    end
  end

  describe 'fields the client does not read' do
    let(:attributes) { super().merge('last_downloaded_at' => '2026-07-04T00:00:00Z', 'newly_added_ar_field' => 'x') }

    it 'defines no reader for the contract fields nothing renders yet, nor for unknown keys',
      :aggregate_failures do
      expect(manifest.digest).to eq('sha256:aaaa')
      expect(manifest).not_to respond_to(:last_downloaded_at)
      expect(manifest).not_to respond_to(:newly_added_ar_field)
    end
  end

  describe 'the nullable fields' do
    let(:attributes) { super().merge('artifact_type' => nil, 'subject_digest' => nil) }

    it 'exposes nil for a manifest with no artifact type or subject, which the contract sends as JSON null',
      :aggregate_failures do
      expect(manifest.artifact_type).to be_nil
      expect(manifest.subject_digest).to be_nil
    end
  end

  describe 'absent fields' do
    let(:attributes) { { 'id' => 'a1b2c3d4-0000-0000-0000-000000000000' } }

    it 'returns nil for every absent field without raising', :aggregate_failures do
      expect(manifest.id).to eq('a1b2c3d4-0000-0000-0000-000000000000')
      expect(manifest.digest).to be_nil
      expect(manifest.media_type).to be_nil
      expect(manifest.artifact_type).to be_nil
      expect(manifest.subject_digest).to be_nil
      expect(manifest.size).to be_nil
      expect(manifest.created_at).to be_nil
    end
  end

  describe 'timestamp coercion' do
    context 'when created_at is not parseable' do
      let(:attributes) { super().merge('created_at' => 'not-a-timestamp') }

      it 'coerces to nil without raising' do
        expect(manifest.created_at).to be_nil
      end
    end
  end

  describe 'when constructed with nil attributes' do
    subject(:manifest) { described_class.new(nil) }

    it 'treats it as an empty resource without raising', :aggregate_failures do
      expect(manifest.id).to be_nil
      expect(manifest.digest).to be_nil
      expect(manifest.created_at).to be_nil
    end
  end
end
