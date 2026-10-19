# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Analytics::Orbit::NamespaceType, feature_category: :knowledge_graph do
  include GraphqlHelpers

  specify { expect(described_class.graphql_name).to eq('OrbitNamespace') }

  it 'exposes the enabled_at field' do
    expect(described_class).to have_graphql_field(:enabled_at)
  end

  describe '#enabled_at' do
    context 'when Orbit indexing is enabled' do
      let_it_be(:group) { create(:group) }
      let_it_be(:enabled_namespace) { create(:knowledge_graph_enabled_namespace, namespace: group) }

      it 'returns when indexing was enabled' do
        expect(resolve_field(:enabled_at, group)).to be_like_time(enabled_namespace.created_at)
      end
    end

    context 'when Orbit is not enabled' do
      let_it_be(:group) { create(:group) }

      it 'returns nil' do
        expect(resolve_field(:enabled_at, group)).to be_nil
      end
    end

    context 'for a subgroup and a project of a group with Orbit on' do
      let_it_be(:group) { create(:group) }
      let_it_be(:subgroup) { create(:group, parent: group) }
      let_it_be(:project) { create(:project, group: group) }

      before_all do
        create(:knowledge_graph_enabled_namespace, namespace: group)
      end

      it 'returns nil, because only the top-level group records it' do
        expect(resolve_field(:enabled_at, subgroup)).to be_nil
        expect(resolve_field(:enabled_at, project)).to be_nil
      end
    end
  end
end
