# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::ActiveContext::Embedding, feature_category: :global_search do
  let_it_be(:model_metadata_validation_schema) do
    file_path = Rails.root.join('ee/app/validators/json_schemas/ai_active_context_embedding_metadata.json')
    Gitlab::Json.safe_parse(File.read(file_path))
  end

  let(:supported_model_types) { [:gitlab_managed] }
  let(:schema_model_types) do
    model_metadata_validation_schema['properties']['model_type']['enum'].compact.map(&:to_sym)
  end

  let(:supported_dimensions) { [768] }
  let(:schema_dimensions) do
    model_metadata_validation_schema['properties']['dimensions']['enum'].compact
  end

  it 'defines all supported model types and matches the model metadata validation schema' do
    defined_model_types = described_class::MODEL_TYPES

    expect(defined_model_types).to match_array(supported_model_types)
    expect(defined_model_types).to match_array(schema_model_types)
  end

  it 'defines all supported dimensions and matches the model metadata validation schema' do
    defined_dimensions = described_class::EMBEDDING_DIMENSIONS

    expect(defined_dimensions).to match_array(supported_dimensions)
    expect(defined_dimensions).to match_array(schema_dimensions)
  end

  describe 'gitlab-managed models lookup' do
    let(:supported_models) { ['text_embedding_005_vertex'] }
    let(:models_lookup) { described_class::MODELS_LOOKUP }

    it 'defines the supported models' do
      expect(models_lookup.keys).to match_array(supported_models)
    end

    it 'defines a name for each model' do
      expect(models_lookup).to all(satisfy { |_k, m| m[:model_name].present? })
    end
  end

  describe '.valid_model_ref?' do
    it 'validates against the models lookup' do
      expect(described_class.valid_model_ref?('text_embedding_005_vertex')).to be(true)
      expect(described_class.valid_model_ref?('test_model_1')).to be(false)
    end
  end
end
