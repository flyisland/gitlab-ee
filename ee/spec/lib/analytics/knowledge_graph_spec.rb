# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::KnowledgeGraph, feature_category: :knowledge_graph do
  using RSpec::Parameterized::TableSyntax

  describe '.service_configured?' do
    subject(:configured) { described_class.service_configured? }

    context 'when knowledge_graph.enabled is true' do
      before do
        stub_config(knowledge_graph: { 'enabled' => true })
      end

      it { is_expected.to be(true) }
    end

    context 'when knowledge_graph.enabled is false' do
      before do
        stub_config(knowledge_graph: { 'enabled' => false })
      end

      it { is_expected.to be(false) }
    end

    context 'when knowledge_graph.enabled key is absent' do
      before do
        stub_config(knowledge_graph: {})
      end

      it 'coerces the nil to a strict boolean false' do
        is_expected.to be(false)
      end
    end

    context 'when knowledge_graph config section is missing' do
      before do
        allow(Gitlab.config).to receive(:knowledge_graph).and_raise(Gitlab::Configs::MissingConfig)
      end

      it { is_expected.to be(false) }
    end
  end

  describe '.enabled_for?' do
    let_it_be(:user) { create(:user) }

    subject(:enabled) { described_class.enabled_for?(user) }

    where(:service_configured, :expected) do
      true  | true
      false | false
    end

    with_them do
      before do
        stub_config(knowledge_graph: { 'enabled' => service_configured })
      end

      it { is_expected.to be(expected) }
    end
  end

  describe '.accessible_for?' do
    let_it_be(:user) { create(:user) }

    subject(:accessible) { described_class.accessible_for?(user) }

    before do
      stub_config(knowledge_graph: { 'enabled' => true })
      allow(::Analytics::KnowledgeGraph::OrbitLicense).to receive(:available_for?).with(user).and_return(license)
    end

    context 'when enabled and licensed' do
      let(:license) { true }

      it { is_expected.to be(true) }
    end

    context 'when enabled but not licensed' do
      let(:license) { false }

      it { is_expected.to be(false) }
    end

    context 'when licensed but the service is not configured' do
      let(:license) { true }

      before do
        stub_config(knowledge_graph: { 'enabled' => false })
      end

      it 'does not check the license' do
        expect(::Analytics::KnowledgeGraph::OrbitLicense).not_to receive(:available_for?)

        is_expected.to be(false)
      end
    end
  end

  describe '.gql_enabled_for?' do
    let_it_be(:user) { create(:user) }
    let_it_be(:other_user) { create(:user) }

    it 'is false for anonymous requests' do
      expect(described_class.gql_enabled_for?(nil)).to be(false)
    end

    it 'is false when the flag is off everywhere' do
      stub_feature_flags(orbit_gql_queries: false)

      expect(described_class.gql_enabled_for?(user)).to be(false)
    end

    it 'follows a user actor' do
      stub_feature_flags(orbit_gql_queries: user)

      expect(described_class.gql_enabled_for?(user)).to be(true)
      expect(described_class.gql_enabled_for?(other_user)).to be(false)
    end
  end
end
