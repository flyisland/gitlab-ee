# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe 'dependency_firewall_policy_content.json', feature_category: :dependency_firewall do
  let(:schema_path) do
    Rails.root.join("ee/app/validators/json_schemas/dependency_firewall_policy_content.json")
  end

  let(:schema) { JSONSchemer.schema(schema_path) }
  let(:validation_result) { schema.validate(policy, output_format: 'basic') }

  let(:policy) do
    {
      name: 'License Policy #1',
      description: 'Two rules for licenses',
      enabled: true,
      enforcement_type: 'warn',
      bypass_settings: { users: [{ id: 123 }], access_tokens: [{ id: 334 }] },
      rules: [
        {
          type: 'license',
          denied: [{ name: 'NIST Software License' }, { name: 'NTP License' }],
          exceptions: [{ purl: 'pkg:npm/my-internal-lib' }]
        },
        {
          type: 'license',
          allowed: [{ name: 'MIT License' }, { name: 'Apache License 2.0' }],
          exceptions: [{ purl: 'pkg:npm/my-internal-lib' }]
        }
      ]
    }
  end

  def expect_errors_to_include(expected_error)
    expect(validation_result["errors"].pluck("error")).to include expected_error
  end

  context 'when policy has empty rules array' do
    before do
      policy[:rules] = []
    end

    specify do
      expect(validation_result["valid"]).to be false
      expect_errors_to_include('array size at `/rules` is less than: 1')
    end
  end

  context 'when policy has rules' do
    specify { expect(validation_result["valid"]).to be true }

    context 'with both allowed and denied is invalid' do
      before do
        policy[:rules] = [{
          type: 'license',
          denied: [{ name: 'NIST Software License' }, { name: 'NTP License' }],
          allowed: [{ name: 'MIT License' }, { name: 'Apache License 2.0' }]
        }]
      end

      specify do
        expect(validation_result["valid"]).to be false
        expect_errors_to_include('value at `/rules/0` does not match exactly one `oneOf` schema')
      end
    end

    context 'when exception purl is invalid' do
      before do
        policy[:rules][0][:exceptions][0][:purl] = 'notpkg:npm/my-internal-lib'
      end

      specify do
        expect(validation_result["valid"]).to be false
        expect_errors_to_include('string at `/rules/0/exceptions/0/purl` does not match pattern: ^pkg:')
      end
    end
  end

  context 'when policy has invalid structure' do
    before do
      policy[:rules] = 'not_an_array'
    end

    specify do
      expect(validation_result["valid"]).to be false
      expect_errors_to_include('value at `/rules` is not an array')
    end
  end

  context 'when policy has additional properties' do
    before do
      policy[:unexpected_field] = 'value'
    end

    specify do
      expect(validation_result["valid"]).to be false
      expect_errors_to_include('object property at `/unexpected_field` is a disallowed additional property')
    end
  end
end
