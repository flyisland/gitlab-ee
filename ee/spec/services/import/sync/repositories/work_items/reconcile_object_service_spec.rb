# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Import::Sync::Repositories::WorkItems::ReconcileObjectService,
  :use_clean_rails_memory_store_caching, feature_category: :importers do
  let(:repository) { create(:import_sync_repository, :oauth) }
  let(:project) { repository.project }
  let(:client) { instance_double(Gitlab::GithubImport::Client) }
  let(:fence) { instance_spy(Import::Sync::Repositories::ApplicationLease::Context) }
  let(:provider_updated_at) { Time.zone.parse('2026-08-25 12:00:00') }
  let(:issue_counter_cache_keys) do
    issue_count_service = Projects::OpenIssuesCountService.new(project)
    work_item_count_service = Projects::OpenWorkItemsCountService.new(project)

    [
      issue_count_service.public_count_cache_key,
      issue_count_service.total_count_cache_key,
      work_item_count_service.public_count_cache_key,
      work_item_count_service.total_count_cache_key
    ]
  end

  let(:merge_request_counter_cache_key) { Projects::OpenMergeRequestsCountService.new(project).cache_key }
  let(:representation) do
    instance_double(
      Gitlab::GithubImport::Representation::Issue,
      iid: 42,
      milestone_number: nil,
      updated_at: provider_updated_at
    )
  end

  let(:import_attributes) do
    {
      iid: 42,
      title: 'Current GitHub title',
      state_id: Issue.available_states[:closed],
      updated_at: provider_updated_at,
      imported_from: Import::HasImportSource::IMPORT_SOURCES[:github]
    }
  end

  let(:importer) do
    instance_double(
      Gitlab::GithubImport::Importer::IssueImporter,
      import_attributes: import_attributes,
      push_placeholder_references: nil
    )
  end

  let(:logger) { Gitlab::GithubImport::Logger }

  subject(:service) do
    described_class.new(repository, client: client, verify_fence: -> { fence.verify! })
  end

  before do
    allow(Gitlab::GithubImport::Importer::IssueImporter).to receive(:new).and_return(importer)
  end

  def map_record(record, kind:, provider_object_xid:, provider_updated_at: nil, column: nil)
    column ||= { issue: :issue, pull_request: :merge_request, issue_comment: :note }.fetch(kind)

    create(
      :import_sync_external_object,
      repository: repository,
      kind: kind,
      provider_object_xid: provider_object_xid,
      provider_updated_at: provider_updated_at || (self.provider_updated_at - 1.day),
      issue: nil,
      column => record
    )
  end

  def mapping_for(kind, xid)
    Import::Sync::ExternalObject.for_provider(repository: repository, kind: kind, provider_object_xid: xid)
  end

  def lose_lease_on_fence_check(check_number)
    fence_checks = 0
    allow(fence).to receive(:verify!) do
      fence_checks += 1
      raise Import::Sync::Repositories::ApplicationLease::LostLeaseError, 'lost' if fence_checks == check_number
    end
  end

  it 'rejects a provider object without a positive id' do
    expect do
      service.execute(kind: :issue, provider_object: { id: 0 }, representation: representation)
    end.to raise_error(Import::Sync::Errors::ProviderObjectError, /identity/)
  end

  it 'rejects a provider object without a usable update time' do
    [nil, 123].each do |updated_at|
      allow(representation).to receive(:updated_at).and_return(updated_at)

      expect do
        service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)
      end.to raise_error(Import::Sync::Errors::ProviderObjectError, /update time/)
    end
  end

  it 'updates a mapped issue and refreshes its mapping' do
    issue = create(:issue, project: project, iid: 42, title: 'Initial title', state: :opened, imported_from: :github)
    map_record(issue, kind: :issue, provider_object_xid: 7001)
    issue_counter_cache_keys.each { |key| Rails.cache.write(key, 17) }

    result = service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)

    expect(result).to eq(issue)
    expect(issue.reload).to have_attributes(title: 'Current GitHub title', state: 'closed')
    expect(importer).not_to have_received(:push_placeholder_references)
    expect(mapping_for(:issue, 7001)).to have_attributes(local_record: issue, provider_updated_at: provider_updated_at)
    expect(fence).to have_received(:verify!).twice
    expect(issue_counter_cache_keys.map { |key| Rails.cache.read(key) }).to all(be_nil)
  end

  it 'preserves issue counter caches for a title-only update' do
    issue = create(:issue, project: project, iid: 42, title: 'Initial title', state: :closed, imported_from: :github)
    map_record(issue, kind: :issue, provider_object_xid: 7001)
    issue_counter_cache_keys.each { |key| Rails.cache.write(key, 17) }

    service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)

    expect(issue.reload).to have_attributes(title: 'Current GitHub title', state: 'closed')
    expect(issue_counter_cache_keys.map { |key| Rails.cache.read(key) }).to all(eq(17))
  end

  it 'pushes placeholder references only when an assignee was added' do
    issue = create(:issue, project: project, iid: 42, title: 'Initial title', state: :closed, imported_from: :github)
    map_record(issue, kind: :issue, provider_object_xid: 7001)
    assignee = create(:user)
    allow(importer).to receive(:import_attributes).and_return(import_attributes.merge(assignee_ids: [assignee.id]))

    service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)

    expect(issue.reload.assignee_ids).to eq([assignee.id])
    expect(importer).to have_received(:push_placeholder_references).with(issue)
  end

  it 'keeps the current milestone when the GitHub milestone has no GitLab counterpart yet' do
    milestone = create(:milestone, project: project)
    issue = create(:issue, project: project, iid: 42, milestone: milestone, imported_from: :github)
    map_record(issue, kind: :issue, provider_object_xid: 7001)
    allow(representation).to receive(:milestone_number).and_return(9)
    allow(importer).to receive(:import_attributes).and_return(import_attributes.merge(milestone_id: nil))

    service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)

    expect(issue.reload).to have_attributes(title: 'Current GitHub title', milestone: milestone)
  end

  it 'clears the milestone when GitHub has none' do
    milestone = create(:milestone, project: project)
    issue = create(:issue, project: project, iid: 42, milestone: milestone, imported_from: :github)
    map_record(issue, kind: :issue, provider_object_xid: 7001)
    allow(importer).to receive(:import_attributes).and_return(import_attributes.merge(milestone_id: nil))

    service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)

    expect(issue.reload.milestone).to be_nil
  end

  it 'ignores a provider version older than its durable mapping' do
    issue = create(:issue, project: project, iid: 42, title: 'Newer title', imported_from: :github)
    map_record(issue, kind: :issue, provider_object_xid: 7001, provider_updated_at: provider_updated_at + 1.minute)

    result = service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)

    expect(result).to eq(issue)
    expect(issue.reload.title).to eq('Newer title')
    expect(importer).not_to have_received(:push_placeholder_references)
    expect(fence).not_to have_received(:verify!)
  end

  it 'leaves a record alone when its mapping already has this provider version, even if attributes differ' do
    issue = create(:issue, project: project, iid: 42, title: 'Rewritten after import', state: :closed,
      imported_from: :github)
    mapping = map_record(issue, kind: :issue, provider_object_xid: 7001, provider_updated_at: provider_updated_at)

    expect do
      service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)
    end.not_to change { issue.reload.updated_at }

    expect(issue.title).to eq('Rewritten after import')
    expect(importer).not_to have_received(:push_placeholder_references)
    expect(mapping.reload.provider_updated_at).to be_like_time(provider_updated_at)
    expect(fence).not_to have_received(:verify!)
  end

  it 'does not rewrite attachment links when the attachments stage is disabled' do
    issue = create(:issue, project: project, iid: 42, title: 'Initial title', state: :closed, imported_from: :github)
    map_record(issue, kind: :issue, provider_object_xid: 7001)
    expect(Gitlab::GithubImport::Importer::NoteAttachmentsImporter).not_to receive(:new)

    service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)
  end

  context 'when the attachments stage is enabled' do
    let(:attachments_importer) do
      instance_double(Gitlab::GithubImport::Importer::NoteAttachmentsImporter, execute: nil)
    end

    before do
      project.build_or_assign_import_data(data: { 'optional_stages' => { 'attachments_import' => true } }).save!
      allow(Gitlab::GithubImport::Importer::NoteAttachmentsImporter).to receive(:new).and_return(attachments_importer)
    end

    it 'rewrites attachment links after updating a mapped record' do
      issue = create(:issue, project: project, iid: 42, title: 'Initial title', state: :closed, imported_from: :github)
      map_record(issue, kind: :issue, provider_object_xid: 7001)

      service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)

      expect(Gitlab::GithubImport::Importer::NoteAttachmentsImporter).to have_received(:new).with(
        an_object_having_attributes(record_type: 'Issue', record_db_id: issue.id), project, client
      )
      expect(attachments_importer).to have_received(:execute)
    end

    it 'rewrites attachment links after creating a record' do
      allow(importer).to receive(:execute) { create(:issue, project: project, iid: 42, imported_from: :github) }

      service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)

      expect(attachments_importer).to have_received(:execute)
    end

    it 'leaves attachments alone for a record whose provider version is already applied' do
      issue = create(:issue, project: project, iid: 42, title: 'Current GitHub title', state: :closed,
        updated_at: provider_updated_at, imported_from: :github)
      map_record(issue, kind: :issue, provider_object_xid: 7001, provider_updated_at: provider_updated_at)

      service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)

      expect(attachments_importer).not_to have_received(:execute)
    end
  end

  describe '#provider_version_applied?' do
    let(:issue) { create(:issue, project: project, iid: 42, imported_from: :github) }

    def provider_version_applied?
      service.provider_version_applied?(kind: :issue, provider_object: { id: 7001 }, representation: representation)
    end

    it 'is false without a mapping' do
      expect(provider_version_applied?).to be(false)
    end

    it 'is false when the mapping is older than the provider version' do
      map_record(issue, kind: :issue, provider_object_xid: 7001, provider_updated_at: provider_updated_at - 1.minute)

      expect(provider_version_applied?).to be(false)
    end

    it 'is true when the mapping is at or past the provider version' do
      mapping = map_record(issue, kind: :issue, provider_object_xid: 7001, provider_updated_at: provider_updated_at)

      expect(provider_version_applied?).to be(true)

      mapping.update!(provider_updated_at: provider_updated_at + 1.minute)

      expect(provider_version_applied?).to be(true)
    end
  end

  it 'rejects a mapped issue that was created in GitLab' do
    issue = create(:issue, project: project, iid: 42, imported_from: :none)
    map_record(issue, kind: :issue, provider_object_xid: 7001)

    expect do
      service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)
    end.to raise_error(Import::Sync::Errors::MappingConflictError, /overwrite/)

    expect(fence).not_to have_received(:verify!)
  end

  it 'rejects a mapped record with a different IID' do
    issue = create(:issue, project: project, iid: 43, imported_from: :github)
    map_record(issue, kind: :issue, provider_object_xid: 7001)

    expect do
      service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)
    end.to raise_error(Import::Sync::Errors::MappingConflictError, /IID/)
  end

  it 'rejects a mapping whose record has the wrong type' do
    note = create(:note, project: project, imported_from: :github)
    map_record(note, kind: :issue, provider_object_xid: 7001, column: :note)

    expect do
      service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)
    end.to raise_error(Import::Sync::Errors::MappingConflictError, /wrong GitLab record type/)

    expect(importer).not_to have_received(:push_placeholder_references)
    expect(fence).not_to have_received(:verify!)
  end

  it 'rejects a mapped record from another project' do
    issue = create(:issue, iid: 42, imported_from: :github)
    map_record(issue, kind: :issue, provider_object_xid: 7001)

    expect do
      service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)
    end.to raise_error(Import::Sync::Errors::MappingConflictError, /synced project/)
  end

  context 'when there is no mapping' do
    it 'skips and logs an existing same-IID issue without creating or mapping it' do
      issue = create(:issue, project: project, iid: 42, title: 'Original', imported_from: :github)

      expect(logger).to receive(:warn).with(
        message: 'skipping unmapped GitHub object',
        import_sync_repository_id: repository.id,
        Labkit::Fields::GL_PROJECT_ID => project.id,
        kind: :issue,
        iid: 42
      )

      expect do
        result = service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)

        expect(result).to be_nil
      end.not_to change { Import::Sync::ExternalObject.count }

      expect(importer).not_to have_received(:import_attributes)
      expect(issue.reload.title).to eq('Original')
      expect(fence).not_to have_received(:verify!)
    end

    it 'skips an existing same-IID issue that was created in GitLab' do
      issue = create(:issue, project: project, iid: 42, title: 'Local', imported_from: :none)

      expect(logger).to receive(:warn).with(hash_including(kind: :issue, iid: 42))

      expect(service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)).to be_nil
      expect(issue.reload.title).to eq('Local')
    end

    it 'creates a new-IID issue through the importer and maps it' do
      imported_issue = nil
      allow(importer).to receive(:import_attributes).and_return(
        import_attributes.merge(state_id: Issue.available_states.fetch(:opened))
      )
      allow(importer).to receive(:execute) do
        imported_issue = create(:issue, project: project, iid: 42, imported_from: :github)
      end
      issue_counter_cache_keys.each { |key| Rails.cache.write(key, 17) }

      expect do
        service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)
      end.to change { Import::Sync::ExternalObject.count }.by(1)

      expect(importer).to have_received(:execute)
      expect(mapping_for(:issue, 7001).local_record).to eq(imported_issue)
      expect(issue_counter_cache_keys.map { |key| Rails.cache.read(key) }).to all(be_nil)
    end

    it 'claims a created issue before the fence check so a retry updates it instead of skipping it' do
      imported_issue = nil
      allow(importer).to receive(:execute) do
        imported_issue = create(:issue, project: project, iid: 42, title: 'Created', imported_from: :github)
      end
      lose_lease_on_fence_check(2)

      expect { service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation) }
        .to raise_error(Import::Sync::Repositories::ApplicationLease::LostLeaseError, 'lost')

      expect(mapping_for(:issue, 7001)).to have_attributes(local_record: imported_issue, provider_updated_at: nil)

      expect(logger).not_to receive(:warn)
      expect do
        service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)
      end.not_to change { project.issues.count }

      expect(importer).to have_received(:execute).once
      expect(imported_issue.reload.title).to eq('Current GitHub title')
      expect(mapping_for(:issue, 7001).provider_updated_at).to be_like_time(provider_updated_at)
    end

    it 'claims an issue the importer committed before raising' do
      imported_issue = nil
      allow(importer).to receive(:import_attributes).and_return(
        import_attributes.merge(state_id: Issue.available_states.fetch(:opened))
      )
      allow(importer).to receive(:execute) do
        imported_issue = create(:issue, project: project, iid: 42, imported_from: :github)
        raise StandardError, 'placeholder push failed'
      end
      issue_counter_cache_keys.each { |key| Rails.cache.write(key, 17) }

      expect { service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation) }
        .to raise_error(StandardError, 'placeholder push failed')

      expect(mapping_for(:issue, 7001)).to have_attributes(local_record: imported_issue, provider_updated_at: nil)
      expect(issue_counter_cache_keys.map { |key| Rails.cache.read(key) }).to all(be_nil)
    end

    it 'claims nothing when the importer fails before creating the issue' do
      allow(importer).to receive(:execute).and_raise(StandardError, 'rate limited')

      expect { service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation) }
        .to raise_error(StandardError, 'rate limited')

      expect(mapping_for(:issue, 7001)).to be_nil
    end

    it 'does not claim a same-IID issue created in GitLab while the importer failed' do
      allow(importer).to receive(:execute) do
        create(:issue, project: project, iid: 42, imported_from: :none)
        raise StandardError, 'duplicate iid'
      end

      expect { service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation) }
        .to raise_error(StandardError, 'duplicate iid')

      expect(mapping_for(:issue, 7001)).to be_nil
    end

    it 'preserves a partial-create importer error when cache eviction also fails' do
      importer_error = StandardError.new('placeholder push failed')
      cache_error = StandardError.new('cache unavailable')
      allow(importer).to receive(:import_attributes).and_return(
        import_attributes.merge(state_id: Issue.available_states.fetch(:opened))
      )
      allow(importer).to receive(:execute) do
        create(:issue, project: project, iid: 42, imported_from: :github)
        raise importer_error
      end
      allow(Projects::OpenIssuesCountService).to receive(:new).with(project).and_raise(cache_error)
      expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
        cache_error,
        project_id: project.id,
        provider_kind: :issue,
        provider_object_xid: 7001
      )

      expect do
        service.execute(kind: :issue, provider_object: { id: 7001 }, representation: representation)
      end.to raise_error { |error| expect(error).to equal(importer_error) }
    end
  end

  context 'for a pull request' do
    let(:pull_request_representation) do
      instance_double(
        Gitlab::GithubImport::Representation::PullRequest,
        iid: 7,
        assignee: nil,
        milestone_number: nil,
        source_branch_sha: 'c' * 40,
        target_branch: 'master',
        updated_at: provider_updated_at
      )
    end

    let(:pull_request_attributes) do
      {
        iid: 7,
        title: 'Current GitHub pull request',
        state_id: MergeRequest.available_states[:closed],
        updated_at: provider_updated_at,
        imported_from: Import::HasImportSource::IMPORT_SOURCES[:github]
      }
    end

    let(:pull_request_importer) do
      instance_double(
        Gitlab::GithubImport::Importer::PullRequestImporter,
        import_attributes: pull_request_attributes,
        pull_request: pull_request_representation,
        set_merge_request_assignees: nil,
        insert_git_data: nil,
        push_placeholder_references: nil
      )
    end

    let(:merge_request) do
      create(
        :merge_request,
        source_project: project,
        target_project: project,
        iid: 7,
        title: 'Initial pull request',
        state: :opened,
        imported_from: :github
      )
    end

    before do
      allow(Gitlab::GithubImport::Importer::PullRequestImporter).to receive(:new).and_return(pull_request_importer)
    end

    def execute_pull_request
      service.execute(
        kind: :pull_request,
        provider_object: { id: 8001 },
        representation: pull_request_representation
      )
    end

    it 'updates and closes a mapped merge request' do
      map_record(merge_request, kind: :pull_request, provider_object_xid: 8001)
      Rails.cache.write(merge_request_counter_cache_key, 17)

      execute_pull_request

      expect(merge_request.reload).to have_attributes(title: 'Current GitHub pull request', state: 'closed')
      expect(pull_request_importer).to have_received(:set_merge_request_assignees).with(merge_request)
      expect(pull_request_importer).to have_received(:insert_git_data).with(merge_request, false)
      expect(pull_request_importer).not_to have_received(:push_placeholder_references)
      expect(mapping_for(:pull_request, 8001).local_record).to eq(merge_request)
      expect(Rails.cache.read(merge_request_counter_cache_key)).to be_nil
    end

    it 'preserves the merge request counter cache across non-open states' do
      merge_request.update!(state: :closed)
      map_record(merge_request, kind: :pull_request, provider_object_xid: 8001)
      allow(pull_request_importer).to receive(:import_attributes).and_return(
        pull_request_attributes.merge(state_id: MergeRequest.available_states.fetch(:merged))
      )
      Rails.cache.write(merge_request_counter_cache_key, 17)

      execute_pull_request

      expect(merge_request.reload).to have_attributes(title: 'Current GitHub pull request', state: 'merged')
      expect(Rails.cache.read(merge_request_counter_cache_key)).to eq(17)
    end

    # A comment or label edit bumps the pull request's updated_at, and a rebuild adds a diff version.
    it 'leaves the Git data alone when the head and target branch are unchanged' do
      map_record(merge_request, kind: :pull_request, provider_object_xid: 8001)
      allow(pull_request_representation).to receive_messages(
        source_branch_sha: merge_request.merge_request_diff.head_commit_sha,
        target_branch: merge_request.target_branch
      )

      execute_pull_request

      expect(merge_request.reload.title).to eq('Current GitHub pull request')
      expect(pull_request_importer).not_to have_received(:insert_git_data)
      expect(mapping_for(:pull_request, 8001).provider_updated_at).to be_like_time(provider_updated_at)
    end

    it 'applies the Git data again when only the target branch changed' do
      map_record(merge_request, kind: :pull_request, provider_object_xid: 8001)
      allow(pull_request_representation).to receive_messages(
        source_branch_sha: merge_request.merge_request_diff.head_commit_sha,
        target_branch: 'release'
      )

      execute_pull_request

      expect(pull_request_importer).to have_received(:insert_git_data).with(merge_request, false)
    end

    it 'creates a new pull request using the merge request the importer returned' do
      imported_merge_request = nil
      allow(pull_request_importer).to receive(:import_attributes).and_return(
        pull_request_attributes.merge(state_id: MergeRequest.available_states.fetch(:opened))
      )
      allow(pull_request_importer).to receive(:execute) do
        imported_merge_request = create(
          :merge_request,
          source_project: project,
          target_project: project,
          iid: 7,
          state: :opened,
          imported_from: :github
        )
      end
      Rails.cache.write(merge_request_counter_cache_key, 17)

      execute_pull_request

      expect(mapping_for(:pull_request, 8001).local_record).to eq(imported_merge_request)
      expect(Rails.cache.read(merge_request_counter_cache_key)).to be_nil
    end

    it 'raises instead of mapping when the importer returns no merge request' do
      allow(pull_request_importer).to receive(:execute).and_return(nil)

      expect { execute_pull_request }
        .to raise_error(Import::Sync::Errors::ProviderObjectError, /could not be created/)

      expect(mapping_for(:pull_request, 8001)).to be_nil
    end

    it 'claims a merge request the importer committed before its Git data write failed' do
      created_merge_request = nil
      allow(pull_request_importer).to receive(:execute) do
        created_merge_request = create(
          :merge_request, source_project: project, target_project: project, iid: 7, imported_from: :github
        )
        raise Gitlab::Git::CommandError, 'Git data write failed'
      end

      expect { execute_pull_request }.to raise_error(Gitlab::Git::CommandError, 'Git data write failed')

      expect(mapping_for(:pull_request, 8001))
        .to have_attributes(local_record: created_merge_request, provider_updated_at: nil)

      execute_pull_request

      expect(pull_request_importer).to have_received(:execute).once
      expect(pull_request_importer).to have_received(:insert_git_data).with(created_merge_request, false)
      expect(created_merge_request.reload).to have_attributes(title: 'Current GitHub pull request', state: 'closed')
      expect(mapping_for(:pull_request, 8001).provider_updated_at).to be_like_time(provider_updated_at)
    end

    it 'skips an existing same-IID merge request without reaching the importer adoption path' do
      merge_request
      allow(pull_request_importer).to receive(:execute)

      expect(logger).to receive(:warn).with(
        message: 'skipping unmapped GitHub object',
        import_sync_repository_id: repository.id,
        Labkit::Fields::GL_PROJECT_ID => project.id,
        kind: :pull_request,
        iid: 7
      )

      expect { expect(execute_pull_request).to be_nil }.not_to change { Import::Sync::ExternalObject.count }

      expect(pull_request_importer).not_to have_received(:execute)
      expect(pull_request_importer).not_to have_received(:insert_git_data)
      expect(merge_request.reload.title).to eq('Initial pull request')
      expect(fence).not_to have_received(:verify!)
    end

    it 'retries pull request Git data before its mapping is version-current' do
      map_record(merge_request, kind: :pull_request, provider_object_xid: 8001)
      git_data_attempts = 0
      allow(pull_request_importer).to receive(:insert_git_data) do
        git_data_attempts += 1
        raise Gitlab::Git::CommandError, 'Git data write failed' if git_data_attempts == 1
      end
      Rails.cache.write(merge_request_counter_cache_key, 17)

      expect { execute_pull_request }.to raise_error(Gitlab::Git::CommandError, 'Git data write failed')

      expect(merge_request.reload).to have_attributes(title: 'Current GitHub pull request', state: 'closed')
      expect(mapping_for(:pull_request, 8001).provider_updated_at).not_to be_like_time(provider_updated_at)

      execute_pull_request

      expect(git_data_attempts).to eq(2)
      expect(mapping_for(:pull_request, 8001)).to have_attributes(
        local_record: merge_request,
        provider_updated_at: provider_updated_at
      )
    end

    it 'reapplies pull request Git data when its mapping version is stale' do
      merge_request.update!(title: 'Current GitHub pull request', state: :closed, updated_at: provider_updated_at)
      mapping = map_record(
        merge_request,
        kind: :pull_request,
        provider_object_xid: 8001,
        provider_updated_at: provider_updated_at - 1.minute
      )

      execute_pull_request

      expect(pull_request_importer).to have_received(:insert_git_data).with(merge_request, false)
      expect(mapping.reload.provider_updated_at).to be_like_time(provider_updated_at)
    end

    context 'with a real repository and diff versions' do
      let(:repository) { create(:import_sync_repository, :oauth, project: create(:project, :repository)) }
      let!(:original_diff) { merge_request.merge_request_diff }
      let(:original_head_sha) { original_diff.head_commit_sha }
      let(:moved_head_sha) { project.repository.commit('improve/awesome').sha }
      let(:pull_request_head_sha) { original_head_sha }
      let(:pull_request_target_branch) { merge_request.target_branch }

      before do
        map_record(merge_request, kind: :pull_request, provider_object_xid: 8001)
        allow(pull_request_representation).to receive_messages(
          source_branch_sha: pull_request_head_sha,
          target_branch: pull_request_target_branch,
          target_branch_sha: project.repository.commit(pull_request_target_branch).sha
        )
        # The parent context stubs .new with the double; the real importer has to build the diff here.
        allow(Gitlab::GithubImport::Importer::PullRequestImporter).to receive(:new).and_call_original
        allow_next_instance_of(Gitlab::GithubImport::Importer::PullRequestImporter) do |importer|
          allow(importer).to receive_messages(
            import_attributes: pull_request_attributes.merge(target_branch: pull_request_target_branch),
            set_merge_request_assignees: nil
          )
        end
      end

      def diff_ids
        merge_request.merge_request_diffs.reload.ids
      end

      context 'when the head moved' do
        let(:pull_request_head_sha) { moved_head_sha }

        it 'adds a diff version and keeps the existing one', :aggregate_failures do
          expect { execute_pull_request }.to change { merge_request.merge_request_diffs.count }.from(1).to(2)

          new_diff = merge_request.merge_request_diffs.where.not(id: original_diff.id).sole
          expect(diff_ids).to match_array([original_diff.id, new_diff.id])
          expect(new_diff.head_commit_sha).to eq(moved_head_sha)
          expect(merge_request.reload.latest_merge_request_diff_id).to eq(new_diff.id)
        end

        shared_examples 'a pull request update that adds no diff version' do
          it 'creates and deletes no diff, leaves the latest one as is and still records the mapping',
            :aggregate_failures do
            expect(logger).to receive(:info).with(
              message: 'skipping new merge request diff version, diff limit reached',
              import_sync_repository_id: repository.id,
              Labkit::Fields::GL_PROJECT_ID => project.id,
              merge_request_id: merge_request.id
            )

            execute_pull_request

            expect(diff_ids).to eq([original_diff.id])
            expect(merge_request.reload.latest_merge_request_diff_id).to eq(original_diff.id)
            expect(mapping_for(:pull_request, 8001).provider_updated_at).to be_like_time(provider_updated_at)
          end
        end

        context 'when the diff versions limit is reached' do
          before do
            stub_application_setting(diff_max_versions: 1)
          end

          it_behaves_like 'a pull request update that adds no diff version'
        end

        context 'when the diff commits limit is reached' do
          before do
            stub_application_setting(diff_max_commits: 1)
          end

          it_behaves_like 'a pull request update that adds no diff version'
        end
      end

      context 'when the target branch changed' do
        let(:pull_request_target_branch) { 'improve/awesome' }

        it 'adds a diff version and keeps the existing one', :aggregate_failures do
          expect { execute_pull_request }.to change { merge_request.merge_request_diffs.count }.from(1).to(2)

          new_diff = merge_request.merge_request_diffs.where.not(id: original_diff.id).sole
          expect(diff_ids).to match_array([original_diff.id, new_diff.id])
          expect(new_diff).to have_attributes(
            head_commit_sha: original_head_sha,
            start_commit_sha: project.repository.commit('improve/awesome').sha
          )
          expect(merge_request.reload).to have_attributes(
            target_branch: 'improve/awesome',
            latest_merge_request_diff_id: new_diff.id
          )
        end
      end
    end
  end

  context 'for an issue comment' do
    let(:issue) { create(:issue, project: project, iid: 42, imported_from: :github) }
    let(:comment_created_at) { Time.zone.parse('2026-08-24 09:00:00') }
    let(:comment_representation) do
      instance_double(
        Gitlab::GithubImport::Representation::Note,
        updated_at: provider_updated_at,
        noteable_id: 42,
        noteable_type: 'Issue'
      )
    end

    let(:comment_attributes) do
      {
        noteable_type: 'Issue',
        noteable_id: issue.id,
        project_id: project.id,
        author_id: project.creator_id,
        note: 'Edited on GitHub',
        discussion_id: 'a' * 40,
        system: false,
        created_at: comment_created_at,
        updated_at: provider_updated_at,
        imported_from: Import::HasImportSource::IMPORT_SOURCES[:github]
      }
    end

    let(:note_importer) do
      instance_double(
        Gitlab::GithubImport::Importer::NoteImporter,
        import_attributes: comment_attributes,
        find_noteable_id: issue.id,
        push_placeholder_references: nil
      )
    end

    before do
      allow(Gitlab::GithubImport::Importer::NoteImporter).to receive(:new).and_return(note_importer)
    end

    def execute_comment
      service.execute(
        kind: :issue_comment,
        provider_object: { id: 9001 },
        representation: comment_representation
      )
    end

    it 'updates a mapped note without duplicating it' do
      note = create(
        :note,
        project: project,
        noteable: issue,
        author: project.creator,
        note: 'Initial body',
        discussion_id: comment_attributes[:discussion_id],
        created_at: comment_created_at,
        imported_from: :github
      )
      map_record(note, kind: :issue_comment, provider_object_xid: 9001)

      expect(note_importer).not_to receive(:execute)

      expect { execute_comment }.not_to change { project.notes.count }

      expect(note.reload.note).to eq('Edited on GitHub')
      expect(note_importer).not_to have_received(:push_placeholder_references)
      expect(mapping_for(:issue_comment, 9001).local_record).to eq(note)
    end

    it 'keeps the discussion id assigned at creation and leaves an unchanged note untouched' do
      note = create(
        :note,
        project: project,
        noteable: issue,
        author: project.creator,
        note: 'Edited on GitHub',
        discussion_id: 'b' * 40,
        created_at: comment_created_at,
        updated_at: provider_updated_at,
        imported_from: :github
      )
      map_record(note, kind: :issue_comment, provider_object_xid: 9001)

      expect { execute_comment }.not_to change { note.reload.attributes }

      expect(note.discussion_id).to eq('b' * 40)
      expect(note_importer).not_to have_received(:push_placeholder_references)
    end

    it 'does not overwrite the discussion id when the note body changes' do
      note = create(
        :note,
        project: project,
        noteable: issue,
        author: project.creator,
        note: 'Initial body',
        discussion_id: 'b' * 40,
        created_at: comment_created_at,
        imported_from: :github
      )
      map_record(note, kind: :issue_comment, provider_object_xid: 9001)

      execute_comment

      expect(note.reload).to have_attributes(note: 'Edited on GitHub', discussion_id: 'b' * 40)
    end

    it 'creates and maps a comment under a mapped parent using the imported note id' do
      map_record(issue, kind: :issue, provider_object_xid: 7001)
      imported_note = build(:note, project: project, noteable: issue, author: project.creator, imported_from: :github)
      allow(note_importer).to receive(:execute) { imported_note.save! }
      allow(note_importer).to receive(:imported_note_id) { imported_note.id }

      expect { execute_comment }.to change { project.notes.count }.by(1)

      expect(mapping_for(:issue_comment, 9001).local_record).to eq(imported_note)
    end

    it 'claims a created note before the fence check so a retry does not insert a duplicate' do
      map_record(issue, kind: :issue, provider_object_xid: 7001)
      imported_note = build(:note, project: project, noteable: issue, author: project.creator, imported_from: :github)
      allow(note_importer).to receive(:execute) { imported_note.save! }
      allow(note_importer).to receive(:imported_note_id) { imported_note.id }
      lose_lease_on_fence_check(2)

      expect { execute_comment }.to raise_error(Import::Sync::Repositories::ApplicationLease::LostLeaseError, 'lost')

      expect(mapping_for(:issue_comment, 9001))
        .to have_attributes(local_record: imported_note, provider_updated_at: nil)

      expect { execute_comment }.not_to change { project.notes.count }

      expect(note_importer).to have_received(:execute).once
      expect(imported_note.reload.note).to eq('Edited on GitHub')
      expect(mapping_for(:issue_comment, 9001).provider_updated_at).to be_like_time(provider_updated_at)
    end

    it 'creates and maps a comment under a mapped merge request' do
      merge_request = create(:merge_request, source_project: project, target_project: project, imported_from: :github)
      map_record(merge_request, kind: :pull_request, provider_object_xid: 8001)
      allow(comment_representation).to receive_messages(noteable_type: 'MergeRequest', noteable_id: merge_request.iid)
      imported_note = build(:note, project: project, noteable: merge_request, author: project.creator,
        imported_from: :github)
      allow(note_importer).to receive_messages(
        find_noteable_id: merge_request.id,
        import_attributes: comment_attributes.merge(noteable_type: 'MergeRequest', noteable_id: merge_request.id)
      )
      allow(note_importer).to receive(:execute) { imported_note.save! }
      allow(note_importer).to receive(:imported_note_id) { imported_note.id }

      expect { execute_comment }.to change { project.notes.count }.by(1)

      expect(mapping_for(:issue_comment, 9001).local_record).to eq(imported_note)
    end

    it 'claims a note the importer inserted before raising' do
      map_record(issue, kind: :issue, provider_object_xid: 7001)
      imported_note = build(:note, project: project, noteable: issue, author: project.creator, imported_from: :github)
      allow(note_importer).to receive(:execute) do
        imported_note.save!
        raise StandardError, 'placeholder push failed'
      end
      allow(note_importer).to receive(:imported_note_id) { imported_note.id }

      expect { execute_comment }.to raise_error(StandardError, 'placeholder push failed')

      expect(mapping_for(:issue_comment, 9001))
        .to have_attributes(local_record: imported_note, provider_updated_at: nil)
    end

    it 'claims nothing when the importer fails before inserting the note' do
      map_record(issue, kind: :issue, provider_object_xid: 7001)
      allow(note_importer).to receive(:imported_note_id).and_return(nil)
      allow(note_importer).to receive(:execute).and_raise(StandardError, 'rate limited')

      expect { execute_comment }.to raise_error(StandardError, 'rate limited')

      expect(mapping_for(:issue_comment, 9001)).to be_nil
    end

    it 'skips and logs a comment whose parent belongs to another project' do
      other_issue = create(:issue, iid: 42, imported_from: :github)
      allow(note_importer).to receive(:find_noteable_id).and_return(other_issue.id)

      expect(note_importer).not_to receive(:execute)
      expect(logger).to receive(:warn).with(hash_including(kind: :issue_comment, iid: 42))

      expect(execute_comment).to be_nil
    end

    it 'skips and logs a comment whose parent is not mapped' do
      expect(note_importer).not_to receive(:execute)
      expect(logger).to receive(:warn).with(
        message: 'skipping unmapped GitHub object',
        import_sync_repository_id: repository.id,
        Labkit::Fields::GL_PROJECT_ID => project.id,
        kind: :issue_comment,
        iid: 42
      )

      expect { expect(execute_comment).to be_nil }
        .to not_change { Import::Sync::ExternalObject.count }
        .and not_change { project.notes.count }

      expect(note_importer).not_to have_received(:import_attributes)
    end

    it 'skips and logs a comment whose parent does not exist' do
      allow(note_importer).to receive(:find_noteable_id).and_return(nil)

      expect(note_importer).not_to receive(:execute)
      expect(logger).to receive(:warn).with(hash_including(kind: :issue_comment))

      expect(execute_comment).to be_nil
    end
  end

  context 'when a source user is reassigned to a real user between passes',
    :clean_gitlab_redis_shared_state do
    let(:github_author) { { id: 501, login: 'source-author' } }
    let(:first_updated_at) { Time.zone.parse('2026-08-25 10:00:00') }
    let(:second_updated_at) { Time.zone.parse('2026-08-25 11:00:00') }
    let(:real_user) { create(:user) }
    let(:group) { create(:group) }
    let(:github_project) do
      create(:project, group: group, import_type: 'github', import_url: 'https://github.com/example/connected.git')
    end

    let(:repository) { create(:import_sync_repository, :oauth, project: github_project) }

    let!(:source_user) do
      create(
        :import_source_user,
        namespace: group,
        source_user_identifier: github_author[:id].to_s,
        placeholder_user: create(:user, :import_user)
      )
    end

    def issue_representation(updated_at)
      Gitlab::GithubImport::Representation::Issue.from_api_response(
        {
          id: 101,
          number: 4,
          title: 'Issue',
          body: 'Body',
          state: 'open',
          milestone: nil,
          assignees: [],
          labels: [],
          user: github_author,
          created_at: 2.days.ago,
          updated_at: updated_at,
          pull_request: nil
        },
        { work_item_type_id: WorkItems::TypesFramework::Provider.new(project).default_issue_type.id }
      )
    end

    before do
      project.build_or_assign_import_data(data: { user_contribution_mapping_enabled: true }).save!
      allow(client).to receive_messages(web_endpoint: 'https://github.com/', user: { id: 501, login: 'source-author' })
      allow(Gitlab::GithubImport::Importer::IssueImporter).to receive(:new).and_call_original
    end

    it 'updates the record to the real user and pushes no new placeholder reference' do
      service.execute(
        kind: :issue, provider_object: { id: 101 }, representation: issue_representation(first_updated_at)
      )

      issue = project.issues.find_by_iid(4)
      expect(issue.author_id).to eq(source_user.placeholder_user_id)
      expect(project.placeholder_reference_store.count).to eq(1)

      project.placeholder_reference_store.clear!
      source_user.update!(status: Import::SourceUser::STATUSES[:completed], reassign_to_user: real_user)

      service.execute(
        kind: :issue, provider_object: { id: 101 }, representation: issue_representation(second_updated_at)
      )

      expect(issue.reload.author_id).to eq(real_user.id)
      expect(project.placeholder_reference_store.count).to eq(0)
    end
  end
end
