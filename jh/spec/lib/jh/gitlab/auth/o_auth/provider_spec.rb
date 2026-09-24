# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Auth::OAuth::Provider, feature_category: :system_access do
  describe '.label_for' do
    # Views iterate `Provider.providers`, which yields symbols, so a String-only
    # lookup silently fell back to `titleize`.
    it 'returns the JH label whether the provider is a symbol or a string' do
      expect(described_class.label_for(:wecom)).to eq('WeCom')
      expect(described_class.label_for('wecom')).to eq('WeCom')
      expect(described_class.label_for(:dingtalk)).to eq('DingTalk')
      expect(described_class.label_for('dingtalk')).to eq('DingTalk')
    end

    it 'falls back to the upstream behaviour for other providers' do
      expect(described_class.label_for(:github)).to eq('GitHub')
    end

    # The docs tell administrators they can override the button text, so a
    # configured label has to win over the JH default.
    it 'lets a configured label win' do
      allow(described_class).to receive(:config_for).with('wecom').and_return({ 'label' => 'Company Chat' })

      expect(described_class.label_for(:wecom)).to eq('Company Chat')
    end
  end
end
