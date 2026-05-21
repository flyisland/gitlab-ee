# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::RestoreService, feature_category: :groups_and_projects do
  let_it_be(:user) { create(:user) }

  let(:group) do
    create(:group_with_deletion_schedule,
      :deletion_scheduled,
      marked_for_deletion_on: 1.day.ago,
      deleting_user: user,
      owners: user).reload # reload clears previous_changes on group settings from the create
  end

  subject(:execute) { described_class.new(group, user, {}).execute }

  context 'for cache invalidation', :use_clean_rails_memory_store_caching do
    it 'invalidates the free group upgrade link cache' do
      cache_key = ['users', user.id, 'free_group_upgrade_link']
      GitlabSubscriptions::FreeGroupUpgradeLinkCache.get(user.id) { 'cached_value' }

      execute

      expect(Rails.cache.read(cache_key)).to be_nil
    end
  end

  context 'for audit events' do
    it 'logs audit event', :aggregate_failures do
      allow(::Gitlab::Audit::Auditor).to receive(:audit).and_call_original
      expect(::Gitlab::Audit::Auditor).to receive(:audit).with(
        hash_including(name: 'group_restored')
      ).and_call_original

      expect { execute }.to change { AuditEvent.count }.by(1)
    end
  end
end
