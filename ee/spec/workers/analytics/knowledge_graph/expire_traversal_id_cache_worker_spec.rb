# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::KnowledgeGraph::ExpireTraversalIdCacheWorker, feature_category: :knowledge_graph do
  let(:worker) { described_class.new }

  describe 'event subscriptions' do
    before do
      stub_feature_flags(knowledge_graph_infra: true)
    end

    it 'is subscribed to AuthorizationsAddedEvent' do
      subscriptions = Gitlab::EventStore.instance.subscriptions[ProjectAuthorizations::AuthorizationsAddedEvent]

      expect(subscriptions.map(&:worker)).to include(described_class)
    end

    it 'is subscribed to AuthorizationsRemovedEvent' do
      subscriptions = Gitlab::EventStore.instance.subscriptions[ProjectAuthorizations::AuthorizationsRemovedEvent]

      expect(subscriptions.map(&:worker)).to include(described_class)
    end

    it 'is subscribed to MembersAddedEvent' do
      subscriptions = Gitlab::EventStore.instance.subscriptions[Members::MembersAddedEvent]

      expect(subscriptions.map(&:worker)).to include(described_class)
    end

    it 'is subscribed to Members::DestroyedEvent' do
      subscriptions = Gitlab::EventStore.instance.subscriptions[Members::DestroyedEvent]

      expect(subscriptions.map(&:worker)).to include(described_class)
    end
  end

  describe '#handle_event' do
    let_it_be(:user) { create(:user) }

    it 'expires the cache for the user_ids' do
      event = instance_double(Gitlab::EventStore::Event, data: { user_ids: [user.id] })

      expect(Analytics::KnowledgeGraph::AuthorizationContext).to receive(:expire_cache_for_users).with([user.id])

      worker.handle_event(event)
    end

    it 'expires cache for multiple user_ids in a single call' do
      event = instance_double(Gitlab::EventStore::Event, data: { user_ids: [1, 2, 3] })

      expect(Analytics::KnowledgeGraph::AuthorizationContext).to receive(:expire_cache_for_users).with([1, 2, 3])

      worker.handle_event(event)
    end

    it 'does nothing when user_ids is empty' do
      event = instance_double(Gitlab::EventStore::Event, data: { user_ids: [] })

      expect(Analytics::KnowledgeGraph::AuthorizationContext).not_to receive(:expire_cache_for_users)

      worker.handle_event(event)
    end

    it 'does nothing when user_ids is nil' do
      event = instance_double(Gitlab::EventStore::Event, data: { user_ids: nil })

      expect(Analytics::KnowledgeGraph::AuthorizationContext).not_to receive(:expire_cache_for_users)

      worker.handle_event(event)
    end

    it 'clears the Rails cache entry' do
      cache_key = "analytics:knowledge_graph:traversal_ids:#{user.id}"
      Rails.cache.write(cache_key, ['1/22/'], expires_in: 5.minutes)

      event = instance_double(Gitlab::EventStore::Event, data: { user_ids: [user.id] })
      worker.handle_event(event)

      expect(Rails.cache.read(cache_key)).to be_nil
    end

    context 'with MembersAddedEvent payload' do
      it 'extracts user IDs from invited_user_ids' do
        event = instance_double(Gitlab::EventStore::Event,
          data: { source_id: 1, source_type: 'Namespace', invited_user_ids: [user.id] })

        expect(Analytics::KnowledgeGraph::AuthorizationContext).to receive(:expire_cache_for_users).with([user.id])

        worker.handle_event(event)
      end
    end

    context 'with Members::DestroyedEvent payload' do
      it 'extracts user ID from user_id field' do
        event = instance_double(Gitlab::EventStore::Event,
          data: { source_id: 1, source_type: 'Namespace', user_id: user.id })

        expect(Analytics::KnowledgeGraph::AuthorizationContext).to receive(:expire_cache_for_users).with([user.id])

        worker.handle_event(event)
      end
    end
  end
end
