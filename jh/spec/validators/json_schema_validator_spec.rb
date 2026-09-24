# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JsonSchemaValidator, feature_category: :duo_agent_platform do
  using RSpec::Parameterized::TableSyntax

  describe '#schema' do
    let(:validator) do
      described_class.new(attributes: [:definition],
        base_directory: %w[app validators json_schemas ai_catalog], filename: 'third_party_flow_v1')
    end

    let(:definition) { { 'image' => 'ruby:3.0', 'commands' => ['echo hello'] } }

    it 'accepts existing external agent definitions without the option' do
      expect(validator.schema.valid?(definition)).to be(true)
    end

    context 'with useAgentConfigImage' do
      where(:value, :valid) do
        true   | true
        false  | true
        'true' | false
        nil    | false
        1      | false
      end

      with_them do
        it 'accepts only boolean values' do
          expect(validator.schema.valid?(definition.merge('useAgentConfigImage' => value))).to be(valid)
        end
      end
    end

    it 'still rejects unknown properties' do
      expect(validator.schema.valid?(definition.merge('unknown' => true))).to be(false)
    end

    it 'still requires an image for fallback' do
      expect(validator.schema.valid?(definition.except('image').merge('useAgentConfigImage' => true))).to be(false)
    end

    context 'with a different schema' do
      let(:validator) { described_class.new(attributes: [:config], filename: 'duo_agent_config') }

      it 'does not add the external agent option to other schemas', :aggregate_failures do
        expect(validator.schema.valid?({ 'image' => 'ruby:3.0' })).to be(true)
        expect(validator.schema.valid?({ 'image' => 'ruby:3.0', 'useAgentConfigImage' => true })).to be(false)
      end
    end
  end
end
