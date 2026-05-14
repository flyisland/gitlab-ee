# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::KnowledgeGraph::AuthorizationContext, feature_category: :knowledge_graph do
  let_it_be(:user) { create(:user) }
  let_it_be(:admin) { create(:admin) }
  let_it_be(:root_group) { create(:group) }
  let_it_be(:subgroup) { create(:group, parent: root_group) }
  let_it_be(:project) { create(:project, namespace: subgroup) }

  describe '#admin_user?' do
    context 'with regular user' do
      subject(:context) { described_class.new(user) }

      it 'returns false' do
        expect(context.admin_user?).to be(false)
      end
    end

    context 'with admin user' do
      subject(:context) { described_class.new(admin) }

      before do
        allow(admin).to receive(:can_read_all_resources?).and_return(true)
      end

      it 'returns true' do
        expect(context.admin_user?).to be(true)
      end
    end

    context 'with nil user' do
      subject(:context) { described_class.new(nil) }

      it 'returns false' do
        expect(context.admin_user?).to be(false)
      end
    end
  end

  describe '#anonymous_user?' do
    context 'with user' do
      subject(:context) { described_class.new(user) }

      it 'returns false' do
        expect(context.anonymous_user?).to be(false)
      end
    end

    context 'with nil user' do
      subject(:context) { described_class.new(nil) }

      it 'returns true' do
        expect(context.anonymous_user?).to be(true)
      end
    end
  end

  describe '.expire_cache_for_users' do
    it 'deletes cache keys for all user IDs' do
      expect(Rails.cache).to receive(:delete_multi).with(
        ["analytics:knowledge_graph:traversal_ids:#{user.id}"]
      )

      described_class.expire_cache_for_users([user.id])
    end
  end

  describe '#reporter_plus_traversal_ids' do
    subject(:context) { described_class.new(user) }

    context 'when user has reporter access to a root group' do
      before_all do
        root_group.add_reporter(user)
      end

      it 'returns hash with group_traversal_ids' do
        result = context.reporter_plus_traversal_ids

        expect(result).to be_a(Hash)
        expect(result).to have_key(:group_traversal_ids)
        expect(result[:group_traversal_ids]).not_to be_empty
      end

      it 'formats traversal_ids as slash-separated with trailing slash' do
        result = context.reporter_plus_traversal_ids[:group_traversal_ids]

        expect(result).to all(end_with('/'))
        expect(result).to all(match(%r{\A[\d/]+\z}))
      end

      it 'prefixes traversal_ids with organization_id' do
        result = context.reporter_plus_traversal_ids[:group_traversal_ids]

        expect(result).to all(start_with("#{root_group.organization_id}/"))
      end

      it 'compacts parent and subgroup into a single parent prefix via trie' do
        result = context.reporter_plus_traversal_ids[:group_traversal_ids]

        root_prefix = "#{root_group.organization_id}/#{root_group.id}/"
        subgroup_prefix = "#{root_group.organization_id}/#{subgroup.traversal_ids.join('/')}/"

        expect(result).to include(root_prefix)
        expect(result).not_to include(subgroup_prefix)
      end

      it 'observes traversal ID count metric' do
        expect(Gitlab::Metrics::KnowledgeGraph::TraversalIds).to receive(:observe_traversal_ids_count)
          .with(a_value > 0)

        context.reporter_plus_traversal_ids
      end

      it 'caches the result in Rails.cache with the configured TTL' do
        expect(Rails.cache).to receive(:fetch)
          .with("analytics:knowledge_graph:traversal_ids:#{user.id}", expires_in: described_class::CACHE_TTL)
          .and_call_original

        context.reporter_plus_traversal_ids
      end

      it 'avoids N+1 Redis calls on repeated access' do
        context.reporter_plus_traversal_ids

        control = RedisCommands::Recorder.new { described_class.new(user).reporter_plus_traversal_ids }

        expect(control).not_to exceed_redis_calls_limit(2)
      end
    end

    context 'when user has access to a subgroup but not the parent' do
      let_it_be(:other_root) { create(:group) }
      let_it_be(:other_sub) { create(:group, parent: other_root) }
      let_it_be(:leaf_user) { create(:user) }

      subject(:context) { described_class.new(leaf_user) }

      before_all do
        other_sub.add_reporter(leaf_user)
      end

      it 'returns the subgroup traversal path, not the parent' do
        result = context.reporter_plus_traversal_ids[:group_traversal_ids]

        sub_prefix = "#{other_sub.organization_id}/#{other_sub.traversal_ids.join('/')}/"
        root_only = "#{other_root.organization_id}/#{other_root.id}/"

        expect(result).to include(sub_prefix)
        expect(result).not_to include(root_only)
      end
    end

    context 'when user has access to multiple unrelated groups' do
      let_it_be(:group_a) { create(:group) }
      let_it_be(:group_b) { create(:group) }
      let_it_be(:multi_user) { create(:user) }

      subject(:context) { described_class.new(multi_user) }

      before_all do
        group_a.add_reporter(multi_user)
        group_b.add_reporter(multi_user)
      end

      it 'returns separate traversal paths for each group' do
        result = context.reporter_plus_traversal_ids[:group_traversal_ids]

        expect(result.size).to be >= 2
        expect(result).to include("#{group_a.organization_id}/#{group_a.id}/")
        expect(result).to include("#{group_b.organization_id}/#{group_b.id}/")
      end
    end

    context 'when user has access to both parent and child' do
      let_it_be(:parent) { create(:group) }
      let_it_be(:child) { create(:group, parent: parent) }
      let_it_be(:both_user) { create(:user) }

      subject(:context) { described_class.new(both_user) }

      before_all do
        parent.add_reporter(both_user)
        child.add_reporter(both_user)
      end

      it 'deduplicates via trie to parent prefix only' do
        result = context.reporter_plus_traversal_ids[:group_traversal_ids]
        parent_prefix = "#{parent.organization_id}/#{parent.id}/"
        child_prefix = "#{child.organization_id}/#{child.traversal_ids.join('/')}/"

        expect(result).to include(parent_prefix)
        expect(result).not_to include(child_prefix)
      end
    end

    context 'when user has access to deeply nested group' do
      let_it_be(:level1) { create(:group) }
      let_it_be(:level2) { create(:group, parent: level1) }
      let_it_be(:level3) { create(:group, parent: level2) }
      let_it_be(:deep_user) { create(:user) }

      subject(:context) { described_class.new(deep_user) }

      before_all do
        level3.add_reporter(deep_user)
      end

      it 'returns the full traversal path for the leaf group' do
        result = context.reporter_plus_traversal_ids[:group_traversal_ids]

        expected = "#{level3.organization_id}/#{level3.traversal_ids.join('/')}/"
        expect(result).to include(expected)
        expect(result.size).to eq(1)
      end
    end

    context 'when traversal IDs exceed the threshold' do
      let(:large_traversal_ids) { (1..600).map { |i| [1, i] } }
      let(:plucked_pairs) { large_traversal_ids.map { |ids| [1, ids] } }
      let(:metrics) { Gitlab::Metrics::KnowledgeGraph::TraversalIds }

      before do
        groups_finder = instance_double(Search::GroupsFinder)
        allow(Search::GroupsFinder).to receive(:new).and_return(groups_finder)
        relation = instance_double(ActiveRecord::Relation)
        allow(groups_finder).to receive(:execute).and_return(relation)
        allow(relation).to receive(:pluck).with(:organization_id, :traversal_ids).and_return(plucked_pairs)

        trie = instance_double(Namespaces::Traversal::TrieNode)
        allow(Namespaces::Traversal::TrieNode).to receive(:build).and_return(trie)
        allow(trie).to receive(:to_a).and_return(large_traversal_ids)
        allow(metrics).to receive_messages(
          observe_traversal_ids_count: nil,
          observe_compaction_ratio: nil,
          increment_threshold_exceeded: nil
        )
      end

      it 'increments the threshold exceeded counter' do
        expect(metrics).to receive(:increment_threshold_exceeded)

        context.reporter_plus_traversal_ids
      end

      it 'logs a warning with structured data' do
        expect_next_instance_of(Gitlab::KnowledgeGraph::Logger) do |logger|
          expect(logger).to receive(:warn).with(hash_including(
            message: 'Traversal ID count exceeds threshold',
            Labkit::Fields::GL_USER_ID => user.id,
            traversal_ids_count: 600,
            threshold: described_class::MAX_TRAVERSAL_IDS
          ))
        end

        context.reporter_plus_traversal_ids
      end
    end

    context 'when compaction fallback triggers' do
      let(:large_traversal_ids) { (1..600).map { |i| [i] } }
      let(:plucked_pairs) { large_traversal_ids.map { |ids| [1, ids] } }
      let(:metrics) { Gitlab::Metrics::KnowledgeGraph::TraversalIds }

      before do
        groups_finder = instance_double(Search::GroupsFinder)
        allow(Search::GroupsFinder).to receive(:new).and_return(groups_finder)
        relation = instance_double(ActiveRecord::Relation)
        allow(groups_finder).to receive(:execute).and_return(relation)
        allow(relation).to receive(:pluck).with(:organization_id, :traversal_ids).and_return(plucked_pairs)

        trie = instance_double(Namespaces::Traversal::TrieNode)
        allow(Namespaces::Traversal::TrieNode).to receive(:build).and_return(trie)
        allow(trie).to receive(:to_a).and_return(large_traversal_ids)
        allow(Gitlab::Utils::TraversalIdCompactor).to receive(:compact)
          .and_raise(Gitlab::Utils::TraversalIdCompactor::CompactionLimitCannotBeAchievedError)
        allow(metrics).to receive_messages(
          observe_traversal_ids_count: nil,
          observe_compaction_ratio: nil,
          increment_threshold_exceeded: nil,
          increment_compaction_fallback: nil
        )
      end

      it 'increments the compaction fallback counter' do
        expect(metrics).to receive(:increment_compaction_fallback)

        context.reporter_plus_traversal_ids
      end

      it 'logs an error with structured data' do
        expect_next_instance_of(Gitlab::KnowledgeGraph::Logger) do |logger|
          expect(logger).to receive(:warn)
          expect(logger).to receive(:error).with(hash_including(
            message: 'Traversal ID compaction limit cannot be achieved, falling back to truncation',
            Labkit::Fields::GL_USER_ID => user.id,
            traversal_ids_count: 600,
            limit: described_class::MAX_TRAVERSAL_IDS,
            dropped_count: 100
          ))
        end

        context.reporter_plus_traversal_ids
      end

      it 'still returns results truncated to MAX_TRAVERSAL_IDS' do
        result = context.reporter_plus_traversal_ids[:group_traversal_ids]

        expect(result.size).to eq(described_class::MAX_TRAVERSAL_IDS)
      end
    end

    context 'when user has no group access' do
      let_it_be(:user_without_groups) { create(:user) }

      subject(:context) { described_class.new(user_without_groups) }

      it 'returns hash with empty group_traversal_ids' do
        result = context.reporter_plus_traversal_ids

        expect(result).to eq({ group_traversal_ids: [] })
      end
    end

    context 'when user has guest access only' do
      let_it_be(:guest_user) { create(:user) }
      let_it_be(:guest_group) { create(:group) }

      before_all do
        guest_group.add_guest(guest_user)
      end

      subject(:context) { described_class.new(guest_user) }

      it 'does not include guest-only groups' do
        result = context.reporter_plus_traversal_ids

        expect(result).to eq({ group_traversal_ids: [] })
      end
    end

    context 'with nil user' do
      subject(:context) { described_class.new(nil) }

      it 'returns hash with empty group_traversal_ids' do
        result = context.reporter_plus_traversal_ids

        expect(result).to eq({ group_traversal_ids: [] })
      end
    end

    context 'when original traversal ID count is zero' do
      subject(:context) { described_class.new(user) }

      it 'skips compaction ratio observation' do
        expect(Gitlab::Metrics::KnowledgeGraph::TraversalIds).not_to receive(:observe_compaction_ratio)

        context.send(:observe_compaction_ratio, 0, 0)
      end
    end
  end
end
