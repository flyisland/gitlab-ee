# frozen_string_literal: true

require 'spec_helper'

# Protects provider repository identity, authority fencing, and autosave ordering.
# The examples do not enqueue importer jobs; failures indicate that a connected
# project could become writable or ambiguously routed.
RSpec.describe Import::Sync::Repository, feature_category: :importers do
  using RSpec::Parameterized::TableSyntax

  subject(:repository) { build(:import_sync_repository) }

  describe 'associations' do
    it { is_expected.to belong_to(:project).required.inverse_of(:import_sync_repository) }
    it { is_expected.to belong_to(:connected_by_user).class_name('User').optional }

    it 'defines the per-domain sync state association' do
      is_expected.to have_many(:sync_states)
        .class_name('Import::Sync::RepositoryState')
        .inverse_of(:repository)
    end

    it 'defines the external object mapping association' do
      is_expected.to have_many(:external_objects)
        .class_name('Import::Sync::ExternalObject')
        .inverse_of(:repository)
    end
  end

  describe 'provider' do
    it { is_expected.to define_enum_for(:provider).with_values(github: 0).with_prefix }
  end

  describe 'authority state' do
    it 'defines every authority and cutover state' do
      is_expected.to define_enum_for(:authority_state).with_values(
        provisioning: 0,
        bootstrap_canceled: 1,
        provider_canonical: 2,
        disconnected: 3,
        cutting_over: 4,
        cutover_failed: 5,
        gitlab_canonical: 6
      )
    end

    it 'defines durable lifecycle recovery state' do
      is_expected.to define_enum_for(:disconnect_reason).with_values(
        installation_suspended: 0,
        installation_removed: 1,
        repository_access_removed: 2,
        github_app_permissions_required: 3,
        token_revoked: 4,
        insufficient_scope: 5,
        user_deauthorized: 6
      ).with_prefix(:disconnected_because)
      is_expected.to define_enum_for(:restore_authority_state).with_values(
        provisioning: 0,
        provider_canonical: 2
      ).with_prefix(:restore_to)
    end
  end

  describe 'validations' do
    it 'requires a positive integer account ID and an optional positive integer installation ID' do
      is_expected.to validate_numericality_of(:provider_installation_xid).only_integer.is_greater_than(0).allow_nil
      is_expected.to validate_numericality_of(:provider_account_xid).only_integer.is_greater_than(0)
    end

    it 'is valid for an OAuth-connected repository without an installation ID' do
      expect(build(:import_sync_repository, :oauth)).to be_valid
    end

    it { is_expected.to validate_presence_of(:provider_account_login) }
    it { is_expected.to validate_length_of(:provider_account_login).is_at_most(255) }
    it { is_expected.to validate_presence_of(:provider_repository_node_id) }
    it { is_expected.to validate_length_of(:provider_repository_node_id).is_at_most(255) }
    it { is_expected.to validate_presence_of(:provider_full_name) }
    it { is_expected.to validate_length_of(:provider_full_name).is_at_most(255) }
    it { is_expected.to validate_length_of(:provider_default_branch).is_at_most(255).allow_nil }
    it { is_expected.to validate_numericality_of(:provider_repository_xid).only_integer.is_greater_than(0) }

    it 'requires a nonnegative integer application generation' do
      is_expected.to validate_numericality_of(:application_generation)
        .only_integer
        .is_greater_than_or_equal_to(0)
    end

    it 'requires a nonnegative integer consecutive auth failure count' do
      is_expected.to validate_numericality_of(:consecutive_auth_failures)
        .only_integer
        .is_greater_than_or_equal_to(0)
    end

    it 'allows the same stable provider repository across different projects' do
      existing = create(:import_sync_repository)
      duplicate = build(:import_sync_repository, provider_repository_xid: existing.provider_repository_xid)

      expect(duplicate).to be_valid
    end

    it 'requires a recovery reason and prior authority while disconnected' do
      repository.authority_state = :disconnected

      expect(repository).not_to be_valid
      expect(repository.errors).to include(:disconnect_reason, :restore_authority_state)

      repository.disconnect_reason = :repository_access_removed
      repository.restore_authority_state = :provider_canonical

      expect(repository).to be_valid
    end

    it 'does not retain recovery fields outside the disconnected state' do
      repository.disconnect_reason = :repository_access_removed
      repository.restore_authority_state = :provider_canonical

      expect(repository).not_to be_valid
      expect(repository.errors).to include(:disconnect_reason, :restore_authority_state)
    end

    it 'rejects a second provider mapping for one project' do
      existing = create(:import_sync_repository)
      duplicate = build(:import_sync_repository, project: existing.project)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:project_id]).to include('has already been taken')
    end
  end

  describe '#sync_states_for_update' do
    let_it_be_with_reload(:repository) { create(:import_sync_repository) }

    it 'returns the requested rows keyed by domain name' do
      result = repository.transaction { repository.sync_states_for_update(%w[source work_items]) }

      expect(result.keys).to match_array(%w[source work_items])
      expect(result['source']).to eq(repository.sync_states.find_by!(domain: :source))
    end

    it 'creates the missing domain rows first, each needing its first sync' do
      expect { repository.transaction { repository.sync_states_for_update(%w[source]) } }
        .to change { repository.sync_states.count }.from(0).to(3)

      expect(repository.sync_states.map(&:domain)).to match_array(%w[inventory source work_items])
      expect(repository.sync_states).to all(have_attributes(
        project_id: repository.project_id,
        state: 'pending',
        desired_generation: 1,
        synced_generation: 0
      ))
    end

    it 'does not insert rows again once they exist' do
      repository.transaction { repository.sync_states_for_update(%w[source]) }

      recorder = ActiveRecord::QueryRecorder.new do
        expect { repository.transaction { repository.sync_states_for_update(%w[source]) } }
          .not_to change { Import::Sync::RepositoryState.count }
      end

      expect(recorder.log.grep(/INSERT INTO "import_sync_repository_states"/)).to be_empty
    end

    it 'leaves rows that already exist untouched' do
      existing = create(:import_sync_repository_state, repository: repository, domain: :source, state: :current,
        desired_generation: 4, synced_generation: 4)

      repository.transaction { repository.sync_states_for_update(%w[source]) }

      expect(existing.reload).to have_attributes(state: 'current', desired_generation: 4, synced_generation: 4)
    end

    it 'locks the rows' do
      recorder = ActiveRecord::QueryRecorder.new do
        repository.transaction { repository.sync_states_for_update(%w[source]) }
      end

      expect(recorder.log.grep(/FOR UPDATE/)).not_to be_empty
    end
  end

  describe '#read_only?' do
    where(:authority_state, :expected_result) do
      'provisioning'       | true
      'provider_canonical' | true
      'disconnected'       | true
      'cutting_over'       | true
      'cutover_failed'     | true
      'bootstrap_canceled' | false
      'gitlab_canonical'   | false
    end

    with_them do
      before do
        repository.authority_state = authority_state
      end

      it { expect(repository.read_only?).to eq(expected_result) }
    end
  end

  describe '#provider_bound?' do
    where(:authority_state, :expected_result) do
      'provisioning'       | true
      'provider_canonical' | true
      'disconnected'       | true
      'cutting_over'       | true
      'cutover_failed'     | true
      'bootstrap_canceled' | false
      'gitlab_canonical'   | false
    end

    with_them do
      before do
        repository.authority_state = authority_state
      end

      it { expect(repository.provider_bound?).to eq(expected_result) }
    end
  end

  describe '.provider_bound' do
    where(:authority_state, :expected_result) do
      'provisioning'       | true
      'provider_canonical' | true
      'disconnected'       | true
      'cutting_over'       | true
      'cutover_failed'     | true
      'bootstrap_canceled' | false
      'gitlab_canonical'   | false
    end

    with_them do
      before do
        extra_attributes =
          if authority_state == 'disconnected'
            { disconnect_reason: :installation_suspended, restore_authority_state: :provider_canonical }
          else
            {}
          end

        repository.update!(authority_state: authority_state, **extra_attributes)
      end

      it 'matches the #provider_bound? predicate' do
        expect(described_class.provider_bound.exists?(repository.id)).to eq(expected_result)
      end
    end
  end

  describe '#application_generation_current?' do
    before do
      repository.application_generation = 4
    end

    it 'accepts only the exact captured integer generation' do
      expect(repository.application_generation_current?(4)).to be(true)
      expect(repository.application_generation_current?(3)).to be(false)
      expect(repository.application_generation_current?('4')).to be(false)
      expect(repository.application_generation_current?(nil)).to be(false)
    end
  end

  describe 'webhook attributes' do
    it { expect(described_class.encrypted_attributes).to include(:webhook_secret) }
    it { is_expected.to validate_length_of(:webhook_secret).is_at_most(510).allow_nil }

    it 'does not serialize the webhook secret' do
      repository.webhook_secret = 'secret'

      expect(repository.serializable_hash).not_to have_key('webhook_secret')
    end

    it 'persists the webhook secret' do
      repository = create(:import_sync_repository, webhook_secret: 'secret')

      expect(repository.reload.webhook_secret).to eq('secret')
    end

    where(:provider_webhook_xid, :valid) do
      nil | true
      1   | true
      0   | false
      -1  | false
    end

    with_them do
      it 'validates the provider webhook xid' do
        repository.provider_webhook_xid = provider_webhook_xid

        expect(repository.valid?).to eq(valid)
      end
    end
  end

  describe '#record_auth_failure!' do
    it 'increments the counter without disconnecting below the threshold' do
      expect { repository.record_auth_failure! }
        .to change { repository.consecutive_auth_failures }.from(0).to(1)

      expect(repository).not_to be_disconnected
    end

    it 'disconnects once the threshold is reached' do
      described_class::MAX_CONSECUTIVE_AUTH_FAILURES.times { repository.record_auth_failure! }

      expect(repository).to be_disconnected
      expect(repository).to be_disconnected_because_token_revoked
      expect(repository).to be_restore_to_provider_canonical
      expect(repository.consecutive_auth_failures).to eq(0)
    end

    it 'records the given reason when it trips the disconnect' do
      described_class::MAX_CONSECUTIVE_AUTH_FAILURES.times do
        repository.record_auth_failure!(reason: :insufficient_scope)
      end

      expect(repository).to be_disconnected_because_insufficient_scope
    end
  end

  describe '#clear_auth_failures!' do
    it 'resets a nonzero counter' do
      repository.update!(consecutive_auth_failures: 2)

      expect { repository.clear_auth_failures! }
        .to change { repository.consecutive_auth_failures }.from(2).to(0)
    end

    it 'does not issue a write when the counter is already zero' do
      expect { repository.clear_auth_failures! }.not_to change { repository.updated_at }
    end
  end

  describe '#disconnect!' do
    it 'moves to the disconnected state and records the recovery reason' do
      repository.disconnect!(:user_deauthorized)

      expect(repository).to be_disconnected
      expect(repository).to be_disconnected_because_user_deauthorized
      expect(repository).to be_restore_to_provider_canonical
    end
  end

  describe '#restore!' do
    it 'raises when the repository is not disconnected' do
      expect { repository.restore! }.to raise_error(described_class::NotDisconnectedError)
    end

    it 'returns to the recorded authority state and clears recovery fields' do
      repository = create(:import_sync_repository, :token_revoked)

      repository.restore!

      expect(repository).to be_provider_canonical
      expect(repository.disconnect_reason).to be_nil
      expect(repository.restore_authority_state).to be_nil
    end
  end

  describe 'project autosave' do
    it 'persists the provider mapping with a newly created project' do
      project = build(:project, skip_disk_validation: true)
      project.build_import_sync_repository(
        connected_by_user: create(:user),
        provider_installation_xid: 20_991,
        provider_account_xid: 10_991,
        provider_account_login: 'github-account-991',
        provider_repository_xid: 991,
        provider_repository_node_id: 'R_991',
        provider_full_name: 'provider/repository'
      )

      expect { project.save! }.to change { described_class.count }.by(1)
      expect(project.import_sync_repository).to be_persisted
    end
  end
end
