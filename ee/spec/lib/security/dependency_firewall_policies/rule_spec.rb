# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Security::DependencyFirewallPolicies::Rule, feature_category: :dependency_firewall do
  let(:denied_rule) do
    {
      type: "license",
      denied: [{ name: 'MIT' }, { name: 'GPL-3.0' }],
      allowed: [],
      exceptions: [{ purl: 'pkg:npm/lodash@4.17.21' }]
    }
  end

  let(:allowed_rule) do
    {
      type: "license",
      denied: [],
      allowed: [{ name: 'MIT' }, { name: 'Apache-2.0' }],
      exceptions: []
    }
  end

  let(:vulnerability_rule) do
    {
      type: "vulnerability",
      denied: [{ name: 'CVE-2023-1234' }],
      allowed: [],
      exceptions: []
    }
  end

  describe '#license_rule?' do
    context 'when type is license' do
      subject { described_class.new(denied_rule).license_rule? }

      it { is_expected.to be true }
    end

    context 'when type is not license' do
      subject { described_class.new(vulnerability_rule).license_rule? }

      it { is_expected.to be false }
    end
  end

  describe '#purl_excepted?' do
    let(:rule) { described_class.new(denied_rule) }

    it 'returns true when package matches an exception purl' do
      expect(rule.purl_excepted?({ name: 'lodash', purl_type: 'npm', version: '4.17.21' })).to be true
    end

    it 'returns false when package does not match any exception purl' do
      expect(rule.purl_excepted?({ name: 'express', purl_type: 'npm', version: '4.18.0' })).to be false
    end

    it 'returns false when version is nil and does not match with package version' do
      expect(rule.purl_excepted?({ name: 'express', purl_type: 'npm' })).to be false
    end

    context 'when version is blank' do
      let(:denied_rule_no_version) do
        {
          type: "license",
          denied: [{ name: 'MIT' }],
          allowed: [],
          exceptions: [{ purl: 'pkg:npm/lodash' }]
        }
      end

      let(:rule) { described_class.new(denied_rule_no_version) }

      it 'matches exception purl without version' do
        expect(rule.purl_excepted?({ name: 'lodash', purl_type: 'npm', version: nil })).to be true
      end

      it 'matches exception purl when version is empty string' do
        expect(rule.purl_excepted?({ name: 'lodash', purl_type: 'npm', version: '' })).to be true
      end

      it 'matches when version is present but exception has none' do
        expect(rule.purl_excepted?({ name: 'lodash', purl_type: 'npm', version: '4.17.21' })).to be true
      end
    end

    context 'when exception purl is a scoped package without version' do
      let(:scoped_rule) do
        {
          type: "license",
          denied: [{ name: 'MIT' }],
          allowed: [],
          exceptions: [{ purl: 'pkg:npm/@babel/core' }]
        }
      end

      let(:rule) { described_class.new(scoped_rule) }

      it 'matches any version of the scoped package' do
        expect(rule.purl_excepted?({ name: '@babel/core', purl_type: 'npm', version: '7.0.0' })).to be true
      end
    end
  end

  describe '#evaluate' do
    let(:package) { { name: 'express', purl_type: 'npm', version: '4.18.0' } }
    let(:licenses) { [] }

    subject { described_class.new(rule).evaluate(package, licenses) }

    context 'when rule is not a license rule' do
      let(:rule) { vulnerability_rule }
      let(:licenses) { ['MIT'] }

      it { is_expected.to be_nil }
    end

    context 'when package is in exceptions' do
      let(:rule) { denied_rule }
      let(:package) { { name: 'lodash', purl_type: 'npm', version: '4.17.21' } }
      let(:licenses) { ['MIT'] }

      it { is_expected.to eq({ action: :allowed, reason: :exception }) }
    end

    context 'with denied rule' do
      let(:rule) { denied_rule }

      context 'when license is in denied list' do
        let(:licenses) { ['MIT'] }

        it { is_expected.to eq({ action: :denied, reason: :evaluation }) }
      end

      context 'when any license is denied' do
        let(:licenses) { %w[MIT Apache-2.0] }

        it { is_expected.to eq({ action: :denied, reason: :evaluation }) }
      end

      context 'when license is not in denied list' do
        let(:licenses) { ['Apache-2.0'] }

        it { is_expected.to eq({ action: :allowed, reason: :evaluation }) }
      end

      context 'when multiple licenses and none are denied' do
        let(:licenses) { %w[Apache-2.0 BSD-3-Clause] }

        it { is_expected.to eq({ action: :allowed, reason: :evaluation }) }
      end
    end

    context 'with allowed rule' do
      let(:rule) { allowed_rule }

      context 'when all licenses are in allowed list' do
        let(:licenses) { ['MIT'] }

        it { is_expected.to eq({ action: :allowed, reason: :evaluation }) }
      end

      context 'when all licenses are allowed' do
        let(:licenses) { %w[MIT Apache-2.0] }

        it { is_expected.to eq({ action: :allowed, reason: :evaluation }) }
      end

      context 'when some licenses are not in allowed list' do
        let(:licenses) { ['GPL-3.0'] }

        it { is_expected.to eq({ action: :denied, reason: :evaluation }) }
      end

      context 'when any license is not allowed' do
        let(:licenses) { %w[MIT GPL-3.0] }

        it { is_expected.to eq({ action: :denied, reason: :evaluation }) }
      end
    end

    context 'with empty licenses array' do
      let(:licenses) { [] }

      context 'for denied rule' do
        let(:rule) { denied_rule }

        it { is_expected.to eq({ action: :denied, reason: :evaluation }) }
      end

      context 'for allowed rule' do
        let(:rule) { allowed_rule }

        it { is_expected.to eq({ action: :denied, reason: :evaluation }) }
      end
    end
  end

  describe '#denied_license_names' do
    it 'extracts license names from denied list' do
      rule = described_class.new(denied_rule)
      expect(rule.denied_license_names).to eq(%w[MIT GPL-3.0])
    end

    it 'returns empty array when no denied licenses' do
      rule = described_class.new(allowed_rule)
      expect(rule.denied_license_names).to eq([])
    end
  end

  describe '#allowed_license_names' do
    it 'extracts license names from allowed list' do
      rule = described_class.new(allowed_rule)
      expect(rule.allowed_license_names).to eq(%w[MIT Apache-2.0])
    end

    it 'returns empty array when no allowed licenses' do
      rule = described_class.new(denied_rule)
      expect(rule.allowed_license_names).to eq([])
    end
  end
end
