# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::UpdateJobTagsService, :aggregate_failures, feature_category: :continuous_integration do
  let_it_be_with_refind(:user) { create(:user) }
  let(:project) { create(:project, :repository, maintainers: user) }
  let(:pipeline) { create(:ci_pipeline, project: project) }
  let(:job) { create(:ci_build, :pending, pipeline: pipeline, tag_list: ['runner-a']).reload }
  let(:current_user) { user }
  let(:tags) { ['runner-b'] }

  subject(:execute) { described_class.new(job, current_user: current_user, tags: tags).execute }

  before do
    stub_not_protect_default_branch
  end

  it 'updates only this job and its queue while preserving its configuration and execution identity' do
    original_definition = job.job_definition
    original_attributes = original_definition.job_attributes
    original_identity = job.user_id
    other_job = create(:ci_build, :pending, pipeline: pipeline, tag_list: ['runner-a'])
    other_job.job_definition_instance.update!(job_definition_id: original_definition.id)
    job.build_matcher

    expect { execute }.to change { job.reload.lock_version }.by(1)

    expect(job.tag_list).to eq(tags)
    expect(job.build_matcher.tag_list).to eq(tags)
    expect(job.job_definition.job_attributes).to eq(original_attributes.merge(tag_list: tags))
    expect(original_definition.reload.job_attributes).to eq(original_attributes)
    expect(other_job.tag_list).to eq(['runner-a'])
    expect(job.user_id).to eq(original_identity)
    expect(job).to be_pending
    expect(Ci::PendingBuild.find_by!(build_id: job.id).tag_ids).to eq(Ci::Tag.named('runner-b').pluck(:id))
  end

  it 'invalidates runners that have already read the old tags' do
    stale_job = Ci::Build.find(job.id)
    stale_job.build_matcher

    expect(execute).to be_success
    stale_job.runner = create(:ci_runner, :project, projects: [project], tag_list: ['runner-a'])

    expect { stale_job.run! }.to raise_error(ActiveRecord::StaleObjectError)
    expect(job.reload).to be_pending
    expect(job.runner_id).to be_nil
  end

  it 'lets the new runner claim the job instead of the old runner' do
    old_runner = create(:ci_runner, :project, projects: [project], tag_list: ['runner-a'])
    new_runner = create(:ci_runner, :project, projects: [project], tag_list: tags)

    expect(execute).to be_success

    expect(Ci::RegisterJobService.new(old_runner, nil).execute.build).to be_nil
    expect(Ci::RegisterJobService.new(new_runner, nil).execute.build).to eq(job)
    expect(job.reload.runner).to eq(new_runner)
  end

  it 'refreshes the polling cache and notifies runners after saving' do
    expect(job).to receive(:expire_etag_cache!)
    expect(BuildQueueWorker).to receive(:perform_async).with(job.id)
    expect(Gitlab::AppJsonLogger).to receive(:info).with(hash_including(
      event: 'job_tags_updated', user_id: user.id, job_id: job.id,
      old_tags: ['runner-a'], new_tags: tags
    ))

    expect(execute).to be_success
  end

  it 'carries the updated tags into retries' do
    expect(execute).to be_success

    clone = Ci::CloneJobService.new(job, current_user: user).execute

    expect(clone.tag_list).to eq(tags)
  end

  context 'with a cached runner match', :use_clean_rails_memory_store_caching do
    [true, false].each do |matching|
      it "rechecks whether the updated tags match a runner (matching: #{matching})" do
        create(:ci_runner, :online, :project, projects: [project], tag_list: ['runner-b'])
        new_tags = matching ? ['runner-b'] : ['unmatched']
        expect(job.stuck?).to be(true)
        expect(Rails.cache.read(['has-online-runners', job.id])).to be(false)

        result = described_class.new(job, current_user: user, tags: new_tags).execute

        expect(result).to be_success
        expect(job.reload.stuck?).to eq(!matching)
      end
    end
  end

  it 'reuses an existing definition with the same configuration' do
    existing_job = create(:ci_build, :pending, pipeline: pipeline, tag_list: ['runner-a']).reload
    described_class.new(existing_job, current_user: user, tags: tags).execute
    job

    expect { execute }.not_to change { Ci::JobDefinition.count }
    expect(job.job_definition.id).to eq(existing_job.job_definition.id)
  end

  context 'with comma-separated, duplicate and empty tags' do
    let(:tags) { ['runner-b, runner-c, runner-b, '] }

    it 'normalizes the tags' do
      expect(execute.payload[:tags]).to eq(%w[runner-b runner-c])
    end
  end

  context 'with no tags' do
    let(:tags) { [] }

    it 'allows runners that accept untagged jobs to find the job' do
      expect(execute).to be_success
      expect(job.tag_list).to be_empty
      expect(Ci::PendingBuild.for_tags([]).where(build_id: job.id)).to exist
    end
  end

  context 'with invalid tags' do
    using RSpec::Parameterized::TableSyntax

    where(:tags) do
      [nil, 'runner-b', [123], ['a' * 256], Array.new(50) { |i| "tag-#{i}" }]
    end

    with_them do
      it 'rejects the update without changing the job' do
        expect(execute.reason).to eq(:unprocessable_entity)
        expect(job.tag_list).to eq(['runner-a'])
      end
    end
  end

  context 'when the user has a role below maintainer' do
    using RSpec::Parameterized::TableSyntax

    let(:current_user) { create(:user) }

    where(:role) do
      %i[guest planner reporter developer]
    end

    with_them do
      before do
        project.add_role(current_user, role)
        Ci::PendingBuild.upsert_from_build!(job)
      end

      it 'rejects the update without changing the job or queue' do
        original_definition_id = job.job_definition.id
        original_lock_version = job.lock_version
        original_queue_tags = Ci::PendingBuild.find_by!(build_id: job.id).tag_ids

        response = execute

        expect(response.reason).to eq(:forbidden)
        expect(job.reload.job_definition.id).to eq(original_definition_id)
        expect(job.lock_version).to eq(original_lock_version)
        expect(job.tag_list).to eq(['runner-a'])
        expect(Ci::PendingBuild.find_by!(build_id: job.id).tag_ids).to eq(original_queue_tags)
      end
    end
  end

  context 'when the user is the project owner' do
    let(:current_user) { project.first_owner }

    it 'allows the tags to be updated' do
      expect(execute).to be_success
      expect(job.reload.tag_list).to eq(tags)
    end
  end

  context 'when the maintainer role is inherited from a group' do
    let(:group) { create(:group, maintainers: user) }
    let(:project) { create(:project, :repository, group: group) }

    it 'allows the tags to be updated' do
      expect(execute).to be_success
      expect(job.reload.tag_list).to eq(tags)
    end
  end

  context 'when the user is an administrator', :enable_admin_mode do
    let(:current_user) { create(:admin) }

    it 'allows the tags to be updated' do
      expect(execute).to be_success
      expect(job.reload.tag_list).to eq(tags)
    end
  end

  context 'when the user is not a project member' do
    let(:current_user) { create(:user) }

    it 'rejects the update' do
      expect(execute.reason).to eq(:forbidden)
      expect(job.tag_list).to eq(['runner-a'])
    end
  end

  context 'when the user is anonymous' do
    let(:current_user) { nil }

    it 'rejects the update' do
      expect(execute.reason).to eq(:forbidden)
      expect(job.reload.tag_list).to eq(['runner-a'])
    end
  end

  context 'when the ref is protected against the user' do
    before do
      create(:protected_branch, :no_one_can_push, :no_one_can_merge, project: project, name: job.ref)
    end

    it 'enforces the retry permission on the job' do
      expect(execute.reason).to eq(:forbidden)
    end
  end

  context 'when a runner has already claimed the job' do
    before do
      Ci::Build.find(job.id).update!(status: :running, runner: create(:ci_runner))
    end

    it 'rechecks the state under the lock' do
      expect(execute.reason).to eq(:conflict)
      expect(job.tag_list).to eq(['runner-a'])
    end
  end

  context 'when the pending job has a runner assigned' do
    before do
      job.update!(runner: create(:ci_runner))
    end

    it 'rejects the update' do
      expect(execute.reason).to eq(:conflict)
    end
  end

  context 'when the queue update fails' do
    it 'rolls back the configuration and lock version' do
      original_definition_id = job.job_definition.id
      original_lock_version = job.lock_version
      allow(Ci::PendingBuild).to receive(:upsert_from_build!).and_raise(ActiveRecord::RecordInvalid.new(job))
      expect(BuildQueueWorker).not_to receive(:perform_async)

      expect(execute).to be_error
      expect(job.reload.job_definition.id).to eq(original_definition_id)
      expect(job.lock_version).to eq(original_lock_version)
    end
  end

  it 'enforces the same identity verification as retrying a job' do
    expect_next_instance_of(Users::IdentityVerification::AuthorizeCi, user: user, project: project) do |authorization|
      expect(authorization).to receive(:authorize_run_jobs!).and_raise(Users::IdentityVerification::Error)
    end

    response = described_class.new(job, current_user: user, tags: ['runner-b']).execute

    expect(response.reason).to eq(:forbidden)
    expect(job.tag_list).to eq(['runner-a'])
  end

  context 'when the job deploys to a protected environment' do
    let(:environment) { create(:environment, project: project, name: 'production') }
    let(:job) do
      create(:ci_build, :pending, pipeline: pipeline, environment: environment.name, tag_list: ['runner-a']).reload
    end

    let!(:protected_environment) { create(:protected_environment, name: environment.name, project: project) }

    before do
      stub_licensed_features(protected_environments: true)
    end

    it 'denies users who cannot retry the deployment' do
      response = described_class.new(job, current_user: user, tags: ['runner-b']).execute

      expect(response.reason).to eq(:forbidden)
      expect(job.tag_list).to eq(['runner-a'])
    end

    context 'when the user can deploy to the environment' do
      before do
        protected_environment.deploy_access_levels.create!(user: user)
      end

      it 'allows the tags to be updated' do
        response = described_class.new(job, current_user: user, tags: ['runner-b']).execute

        expect(response).to be_success
        expect(job.tag_list).to eq(['runner-b'])
      end
    end
  end
end
