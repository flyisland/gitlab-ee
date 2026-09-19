# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'gitlab:geo:logical_replication rake tasks', :silence_stdout, feature_category: :geo_replication do
  before do
    Rake.application.rake_require 'tasks/gitlab/helpers'
    Rake.application.rake_require 'tasks/gitlab/geo/logical_replication'
  end

  describe 'gitlab:geo:logical_replication:sync_sequences' do
    let(:service) { instance_double(Gitlab::Database::SyncSequencesWithTableData) }

    it 'invokes SyncSequencesWithTableData without a sequence scope' do
      expect(Gitlab::Database::SyncSequencesWithTableData).to receive(:new)
        .with(only_sequences: nil).and_return(service)
      expect(service).to receive(:execute)

      run_rake_task('gitlab:geo:logical_replication:sync_sequences')
    end

    it 'passes ONLY_SEQUENCES as the sequence scope' do
      stub_env('ONLY_SEQUENCES', 'geo_nodes_id_seq, geo_node_namespace_links_id_seq')

      expect(Gitlab::Database::SyncSequencesWithTableData).to receive(:new)
        .with(only_sequences: %w[geo_nodes_id_seq geo_node_namespace_links_id_seq]).and_return(service)
      expect(service).to receive(:execute)

      run_rake_task('gitlab:geo:logical_replication:sync_sequences')
    end

    it 'aborts with the error message when the sync fails' do
      allow(Gitlab::Database::SyncSequencesWithTableData).to receive(:new).and_return(service)
      allow(service).to receive(:execute)
        .and_raise(Gitlab::Database::SyncSequencesWithTableData::SyncError, 'sync failed for: foo_id_seq')

      expect { run_rake_task('gitlab:geo:logical_replication:sync_sequences') }
        .to raise_error(SystemExit).and output(/sync failed for: foo_id_seq/).to_stderr
    end

    # This task must be runnable at initial LR setup while the subscription is live (the
    # active-subscription gate belongs only to the promotion path). A real integration test with
    # an active subscription isn't possible in specs (it needs superuser rights and a live
    # publisher), so this invariant is pinned at the mocking boundary instead.
    # https://gitlab.com/gitlab-org/gitlab/-/work_items/613693
    it 'does not gate on an active subscription' do
      allow(Gitlab::Database::SyncSequencesWithTableData).to receive(:new).and_return(service)
      allow(service).to receive(:execute)

      expect(Gitlab::Geo::LogicalReplication).not_to receive(:ensure_no_active_subscription!)

      run_rake_task('gitlab:geo:logical_replication:sync_sequences')
    end
  end
end
