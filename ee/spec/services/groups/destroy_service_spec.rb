# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::DestroyService, feature_category: :groups_and_projects do
  include ::EE::GeoHelpers

  let_it_be(:user, freeze: false) { create(:user) }
  let!(:group) { create(:group) }

  before do
    group.add_owner(user)
  end

  subject { described_class.new(group, user, {}) }

  context 'audit events' do
    include_examples 'audit event logging' do
      let(:operation) { subject.execute }
      let(:fail_condition!) do
        expect(group).to receive(:destroy).and_return(group)
      end

      let_it_be(:event_type, freeze: false) { 'group_destroyed' }

      let(:attributes) do
        {
          author_id: user.id,
          entity_id: group.id,
          entity_type: 'Group',
          details: {
            remove: 'group',
            author_name: user.name,
            author_class: user.class.name,
            event_name: "group_destroyed",
            target_id: group.id,
            target_type: 'Group',
            target_details: group.full_path,
            custom_message: 'Group destroyed'
          }
        }
      end
    end
  end

  context 'streaming audit event for sub group' do
    let_it_be(:parent_group, freeze: false) { create :group }
    let(:group) { create :group, parent: parent_group }

    subject { described_class.new(group, user, {}).execute }

    before_all do
      parent_group.add_owner(user)
    end

    before do
      stub_licensed_features(external_audit_events: true)
      create(:audit_events_group_external_streaming_destination, group: parent_group)
    end

    it 'sends the audit streaming event with json format' do
      expect(AuditEvents::AuditEventStreamingWorker).to receive(:perform_async).with(
        'group_destroyed',
        nil,
        a_string_including("group_entity_id\":#{parent_group.id}"))

      subject
    end
  end

  context 'dependency_proxy_blobs' do
    let_it_be(:blob, freeze: false) { create(:dependency_proxy_blob) }
    let_it_be(:group, freeze: false) { blob.group }

    before_all do
      group.add_owner(user)
    end

    it 'destroys the dependency proxy blobs' do
      expect { subject.execute }.to change { DependencyProxy::Blob.count }.by(-1)
    end
  end

  context 'when on a Geo primary site' do
    let_it_be(:geo_primary_site, freeze: false) { create(:geo_node, :primary) }

    before do
      stub_current_geo_node(geo_primary_site)
    end

    context 'when group_wiki_repository does not exist' do
      it 'does not call replicator to update Geo' do
        expect_next_instance_of(Geo::GroupWikiRepositoryReplicator).never

        subject.execute
      end
    end

    it 'calls replicator to update Geo' do
      group.wiki.create_wiki_repository

      expect(group.group_wiki_repository.replicator).to receive(:geo_handle_after_destroy)

      subject.execute
    end
  end

  context 'when not on a Geo primary site' do
    it 'does not call replicator to update Geo' do
      group.wiki.create_wiki_repository

      expect(group.group_wiki_repository.replicator).not_to receive(:geo_handle_after_destroy)

      subject.execute
    end
  end

  context 'when group epics have parent epic outside of group' do
    let!(:parent_group) { create(:group) }
    let!(:group) { create(:group, parent: parent_group) }
    let!(:parent_epic1) { create(:epic, group: parent_group) }
    let!(:parent_epic2) { create(:epic, group: parent_group) }
    let!(:parent_epic3) { create(:epic, group: parent_group) }
    let!(:epic1) { create(:epic, group: group, parent: parent_epic1) }
    let!(:epic2) { create(:epic, group: group, parent: parent_epic2) }
    let!(:epic3) { create(:epic, group: group, parent: parent_epic3) }
    # update should not be called for this as parent is in the same group:
    let!(:epic4) { create(:epic, group: group, parent: epic2) }

    before do
      group.add_owner(user)
    end

    it 'schedules cache update for associated epics in batches' do
      stub_const('::Epics::UpdateCachedMetadataWorker::BATCH_SIZE', 2)

      expect(::Epics::UpdateCachedMetadataWorker).to receive(:bulk_perform_in) do |delay, ids|
        expect(delay).to eq(1.minute)
        expect(ids.map(&:first).map(&:length)).to eq([2, 1])
        expect(ids.flatten).to match_array([parent_epic1.id, parent_epic2.id, parent_epic3.id])
      end.once

      subject.execute
    end
  end

  context 'associated records' do
    let!(:service_account) { create(:service_account, provisioned_by_group: group) }
    let!(:service_account_another_group) { create(:service_account, provisioned_by_group: create(:group)) }
    let!(:provisioned_user) { create(:user, provisioned_by_group: group) }

    it 'deletes group serviced accounts and user bots', :sidekiq_inline do
      subject.execute

      expect(
        Users::GhostUserMigration.where(user: service_account, initiator_user: user)
      ).to be_exists
      expect(
        Users::GhostUserMigration.where(user: service_account_another_group, initiator_user: user)
      ).to be_empty
      expect(
        Users::GhostUserMigration.where(user: provisioned_user, initiator_user: user)
      ).to be_empty
    end
  end

  context 'when group has a secrets manager' do
    context 'and the secrets manager is active' do
      let!(:secrets_manager) { create(:group_secrets_manager, :active, group: group) }

      it 'initiates deprovision with snapshot ids AFTER the group is destroyed' do
        fake_service = instance_double(
          SecretsManagement::GroupSecretsManagers::InitiateDeprovisionService,
          execute: ServiceResponse.success
        )

        captured_organization_id = group.organization_id
        captured_root_namespace_id = group.root_ancestor.id
        captured_group_id = group.id

        expect(SecretsManagement::GroupSecretsManagers::InitiateDeprovisionService).to receive(:new).with(
          secrets_manager,
          user,
          group_id: captured_group_id,
          organization_id: captured_organization_id,
          root_namespace_id: captured_root_namespace_id
        ).and_return(fake_service)

        subject.execute

        # Hook should fire after super; verify the group is actually gone.
        expect(Group.find_by(id: captured_group_id)).to be_nil
      end

      it 'lets exceptions raised by InitiateDeprovisionService bubble up to Sentry' do
        # The only realistic post-super failure is infrastructure (DB hiccup,
        # Redis outage, OOM). We deliberately do NOT rescue; the orphan
        # reaper (gitlab-org/gitlab#600120) backstops via the SM record's
        # `where(group_id: nil)` query.
        allow(SecretsManagement::GroupSecretsManagers::InitiateDeprovisionService)
          .to receive(:new).and_raise(ActiveRecord::StatementInvalid, 'db down')

        expect { subject.execute }
          .to raise_error(ActiveRecord::StatementInvalid, /db down/)
      end
    end

    context 'and the secrets manager is still provisioning' do
      let!(:secrets_manager) { create(:group_secrets_manager, :provisioning, group: group) }

      it 'destroys the group anyway and leaves the SM for the orphan reaper' do
        # The provisioning state isn't a reason to block destroy. The
        # orphan reaper (gitlab-org/gitlab#600120) finds these stuck rows
        # later via `where(group_id: nil)` and finishes the cleanup.
        expect(SecretsManagement::GroupSecretsManagers::InitiateDeprovisionService).not_to receive(:new)

        subject.execute

        expect(Group.find_by(id: group.id)).to be_nil
        expect(secrets_manager.reload).to be_provisioning
        expect(secrets_manager.group_id).to be_nil
      end
    end

    context 'and the secrets manager is already deprovisioning' do
      let!(:secrets_manager) { create(:group_secrets_manager, :deprovisioning, group: group) }

      context 'and a maintenance task exists' do
        let!(:existing_task) do
          create(:group_secrets_manager_maintenance_task, :deprovision,
            group: group,
            user: user
          )
        end

        it 're-enqueues the latest deprovision maintenance task and completes destroy' do
          expect(SecretsManagement::GroupSecretsManagers::InitiateDeprovisionService).not_to receive(:new)
          expect(SecretsManagement::DeprovisionGroupSecretsManagerWorker)
            .to receive(:perform_async).with(existing_task.id)

          subject.execute

          expect(Group.find_by(id: group.id)).to be_nil
        end
      end

      context 'and no maintenance task exists' do
        # Rare edge case: SM is in deprovisioning but the task is gone
        # (a prior worker already finished OpenBao teardown). We do
        # nothing here on purpose. After super destroys the parent
        # group, the SM ends up with `group_id = NULL` and the orphan
        # reaper (gitlab-org/gitlab#600120) sweeps it up.
        it 'leaves the orphan secrets manager for the reaper' do
          expect(SecretsManagement::DeprovisionGroupSecretsManagerWorker).not_to receive(:perform_async)

          subject.execute

          expect(Group.find_by(id: group.id)).to be_nil
          expect(secrets_manager.reload).to be_deprovisioning
          expect(secrets_manager.group_id).to be_nil
        end
      end
    end

    context 'when super raises mid-destroy' do
      let!(:secrets_manager) { create(:group_secrets_manager, :active, group: group) }

      it 'does not initiate deprovision when super fails' do
        allow(group).to receive(:destroy).and_raise(StandardError, 'kaboom')

        expect(SecretsManagement::GroupSecretsManagers::InitiateDeprovisionService).not_to receive(:new)

        expect { subject.execute }.to raise_error(StandardError, 'kaboom')
        expect(secrets_manager.reload).to be_active
      end
    end

    context 'and the group has descendant groups + projects with SMs' do
      # The destroy hook only handles this group's SM. Descendant groups and
      # projects are handled by their own EE hooks during the recursive
      # destroy. This spec asserts that hand-off works.
      let!(:subgroup) { create(:group, parent: group) }
      let!(:subgroup_project) { create(:project, namespace: subgroup) }
      let!(:group_sm)            { create(:group_secrets_manager, :active, group: group) }
      let!(:subgroup_sm)         { create(:group_secrets_manager, :active, group: subgroup) }
      let!(:subgroup_project_sm) { create(:project_secrets_manager, :active, project: subgroup_project) }

      it 'invokes InitiateDeprovisionService for this group + each descendant via recursion' do
        # 2 groups (self + subgroup) + 1 project = 3 InitiateDeprovision calls,
        # each fired by the corresponding entity's own destroy hook.
        group_init_calls = 0
        project_init_calls = 0

        allow(SecretsManagement::GroupSecretsManagers::InitiateDeprovisionService)
          .to receive(:new) do |*_args|
            group_init_calls += 1
            instance_double(SecretsManagement::GroupSecretsManagers::InitiateDeprovisionService,
              execute: ServiceResponse.success)
          end

        allow(SecretsManagement::ProjectSecretsManagers::InitiateDeprovisionService)
          .to receive(:new) do |*_args|
            project_init_calls += 1
            instance_double(SecretsManagement::ProjectSecretsManagers::InitiateDeprovisionService,
              execute: ServiceResponse.success)
          end

        subject.execute

        expect(group_init_calls).to eq(2)
        expect(project_init_calls).to eq(1)
      end
    end
  end

  context 'when group has no secrets manager' do
    it 'does not call the deprovision service' do
      expect(SecretsManagement::GroupSecretsManagers::InitiateDeprovisionService).not_to receive(:new)

      subject.execute
    end

    context 'but a descendant subgroup has a secrets manager' do
      # Edge case: parent group has no SM, but a descendant does.
      # The base destroy service recurses into child groups via
      # `DestroyService.new(child).unsafe_execute`, so the descendant's
      # own EE hook fires and handles its SM. We assert that hand-off
      # still happens even when there's nothing to do at the parent.
      let!(:subgroup) { create(:group, parent: group) }
      let!(:subgroup_sm) { create(:group_secrets_manager, :active, group: subgroup) }

      it 'still initiates deprovision for the descendant via recursion' do
        fake_service = instance_double(
          SecretsManagement::GroupSecretsManagers::InitiateDeprovisionService,
          execute: ServiceResponse.success
        )
        expect(SecretsManagement::GroupSecretsManagers::InitiateDeprovisionService)
          .to receive(:new).with(
            subgroup_sm,
            user,
            hash_including(group_id: subgroup.id)
          ).and_return(fake_service)

        subject.execute
      end
    end

    context 'but a descendant project has a secrets manager' do
      # Same edge case for descendant projects: each project destroy
      # via `Projects::DestroyService` fires its own EE hook.
      let!(:descendant_project) { create(:project, namespace: group) }
      let!(:project_sm) { create(:project_secrets_manager, :active, project: descendant_project) }

      it 'still initiates deprovision for the descendant project' do
        fake_service = instance_double(
          SecretsManagement::ProjectSecretsManagers::InitiateDeprovisionService,
          execute: ServiceResponse.success
        )
        expect(SecretsManagement::ProjectSecretsManagers::InitiateDeprovisionService)
          .to receive(:new).with(
            project_sm,
            user,
            hash_including(project_id: descendant_project.id)
          ).and_return(fake_service)

        subject.execute
      end
    end
  end
end
