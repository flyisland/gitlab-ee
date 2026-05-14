# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'gitlab:secrets_management:seed', :gitlab_secrets_manager, :silence_stdout, :enable_admin_mode,
  feature_category: :secrets_management do
  before do
    Rake.application.rake_require('tasks/gitlab/secrets_management/seed')
    allow(Rails.env).to receive(:development?).and_return(true)
  end

  let(:user) { create(:user, :admin, username: 'root') }
  let(:root_group) do
    create(:group, name: 'seed-test', path: 'seed-test').tap { |g| g.add_owner(user) }
  end

  subject(:task) { run_rake_task('gitlab:secrets_management:seed', root_group.id) }

  describe 'argument validation' do
    it 'aborts when not in development environment' do
      allow(Rails.env).to receive(:development?).and_return(false)

      expect { task }.to raise_error(SystemExit)
    end

    it 'aborts when no argument is provided' do
      expect { run_rake_task('gitlab:secrets_management:seed') }.to raise_error(SystemExit)
    end

    it 'aborts when namespace id is not an integer' do
      expect { run_rake_task('gitlab:secrets_management:seed', 'abc') }.to raise_error(SystemExit)
    end

    it 'aborts when namespace does not exist' do
      expect { run_rake_task('gitlab:secrets_management:seed', 0) }.to raise_error(SystemExit)
    end

    it 'aborts when namespace is not a group' do
      project = create(:project, namespace: root_group)
      expect do
        run_rake_task('gitlab:secrets_management:seed', project.project_namespace_id)
      end.to raise_error(SystemExit)
    end
  end

  describe 'feature flags' do
    before do
      stub_feature_flags(secrets_manager: false, group_secrets_manager: false)
    end

    it 'enables secrets_manager and group_secrets_manager flags' do
      task

      expect(Feature.enabled?(:secrets_manager)).to be true # rubocop:disable Gitlab/FeatureFlagWithoutActor -- verifying rake task enabled the flag globally
      expect(Feature.enabled?(:group_secrets_manager)).to be true # rubocop:disable Gitlab/FeatureFlagWithoutActor -- verifying rake task enabled the flag globally
    end
  end

  describe 'hierarchy creation' do
    it 'creates subgroups and projects under the root namespace', :aggregate_failures do
      task

      expected_groups = %w[
        seed-test/subgroup-a
        seed-test/subgroup-a/subgroup-a1
        seed-test/subgroup-b
        seed-test/subgroup-b/subgroup-b1
      ]

      expected_projects = %w[
        seed-test/project-top1
        seed-test/subgroup-a/project-a1
        seed-test/subgroup-a/project-a2
        seed-test/subgroup-a/subgroup-a1/project-a1a
        seed-test/subgroup-b/project-b1
        seed-test/subgroup-b/subgroup-b1/project-b1x
      ]

      expected_groups.each do |path|
        expect(Group.find_by_full_path(path)).to be_present, "Expected group #{path} to exist"
      end

      expected_projects.each do |path|
        expect(Project.find_by_full_path(path)).to be_present, "Expected project #{path} to exist"
      end
    end

    it 'is idempotent' do
      task

      expect { run_rake_task('gitlab:secrets_management:seed', root_group.id) }.not_to raise_error
    end
  end

  describe 'secrets manager provisioning' do
    before do
      task
    end

    it 'provisions active group secrets managers for all groups', :aggregate_failures do
      root_group.self_and_descendants.each do |group|
        sm = group.reset.secrets_manager
        expect(sm).to be_present, "Expected group SM for #{group.full_path}"
        expect(sm).to be_active, "Expected group SM for #{group.full_path} to be active"
      end
    end

    it 'provisions active project secrets managers for all projects', :aggregate_failures do
      root_group.all_projects.each do |project|
        sm = project.reset.secrets_manager
        expect(sm).to be_present, "Expected project SM for #{project.full_path}"
        expect(sm).to be_active, "Expected project SM for #{project.full_path} to be active"
      end
    end

    it 'creates OpenBao namespaces with KV engines mounted', :aggregate_failures do
      root_group.self_and_descendants.each do |group|
        sm = group.reset.secrets_manager
        next unless sm&.active?

        expect_namespace_to_exist(sm.full_group_namespace_path)
        expect_kv_secret_engine_to_be_mounted(sm.full_group_namespace_path, sm.ci_secrets_mount_path)
      end

      root_group.all_projects.each do |project|
        sm = project.reset.secrets_manager
        next unless sm&.active?

        expect_namespace_to_exist(sm.full_project_namespace_path)
        expect_kv_secret_engine_to_be_mounted(sm.full_project_namespace_path, sm.ci_secrets_mount_path)
      end
    end
  end

  describe 'secret creation' do
    before do
      task
    end

    it 'creates group secrets for every group', :aggregate_failures do
      root_group.self_and_descendants.each do |group|
        next unless group.secrets_manager&.active?

        result = SecretsManagement::GroupSecrets::ListService.new(group, user).execute
        expect(result).to be_success
        expect(result.payload[:secrets]).not_to be_empty,
          "Expected group secrets for #{group.full_path}"
      end
    end

    it 'creates project secrets for every project', :aggregate_failures do
      root_group.all_projects.each do |project|
        next unless project.secrets_manager&.active?

        result = SecretsManagement::ProjectSecrets::ListService.new(project, user).execute
        expect(result).to be_success
        expect(result.payload[:secrets]).not_to be_empty,
          "Expected project secrets for #{project.full_path}"
      end
    end

    it 'creates the expected total number of secrets' do
      total = 0

      root_group.self_and_descendants.each do |group|
        next unless group.secrets_manager&.active?

        result = SecretsManagement::GroupSecrets::ListService.new(group, user).execute
        total += result.payload[:secrets].size if result.success?
      end

      root_group.all_projects.each do |project|
        next unless project.secrets_manager&.active?

        result = SecretsManagement::ProjectSecrets::ListService.new(project, user).execute
        total += result.payload[:secrets].size if result.success?
      end

      expect(total).to eq(26)
    end
  end
end
