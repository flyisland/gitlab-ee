# frozen_string_literal: true

namespace :gitlab do
  namespace :duo do
    desc 'GitLab | Duo | Enable GitLab Duo features'
    task :setup, [:add_on] => :environment do |_, args|
      Gitlab::Duo::Developments::Setup.new(args).execute
    end

    desc 'GitLab | Duo | Enable GitLab Duo feature flags'
    task enable_feature_flags: :gitlab_environment do
      Gitlab::Duo::Developments::FeatureFlagEnabler.execute
    end

    desc 'GitLab | Duo | Seed development self-hosted models'
    task seed_self_hosted_models: :gitlab_environment do
      Gitlab::Duo::Developments::DevSelfHostedModelsManager.seed_models
    end

    desc 'GitLab | Duo | Cleans up seeded self-hosted models and configurations'
    task clean_up_duo_self_hosted: :gitlab_environment do
      Gitlab::Duo::Developments::DevSelfHostedModelsManager.clean_up_duo_self_hosted
    end

    desc 'GitLab | Duo | List self-hosted models'
    task list_self_hosted_models: :gitlab_environment do
      Gitlab::Duo::Developments::DevSelfHostedModelsManager.list_models
    end

    desc 'GitLab | Duo | Create evaluation-ready group'
    task :setup_evaluation, [:root_group_path] => :environment do |_, args|
      Gitlab::Duo::Developments::SetupGroupsForModelEvaluation.new(args).execute
    end

    desc 'GitLab | Duo | Verify self-hosted Duo setup'
    task :verify_self_hosted_setup, [:username] => :gitlab_environment do |_, args|
      Gitlab::Duo::Administration::VerifySelfHostedSetup.new(args[:username]).execute
    end

    desc 'GitLab | Duo | Seed projects and issues for SWE Bench evaluations'
    task :swe_bench_seeder, [:projects] => :environment do |_, args|
      project_filter = args[:projects]&.split(',')&.map(&:strip)&.reject(&:empty?)&.presence
      Gitlab::Duo::Developments::SweBenchSeeder.seed(project_filter: project_filter)
    end

    desc 'GitLab | Duo | Seed pipelines for fix_pipeline evaluation'
    task :fix_pipeline_seeder, [:output] => :environment do |_, args|
      output_file = args[:output] || 'fix_pipeline_evaluation_pipelines.yml'
      Gitlab::Duo::Developments::FixPipelineSeeder.seed_pipelines(output_file: output_file)
    end

    desc 'GitLab | Duo | Onboard Duo Agent Platform'
    task onboard_dap: :gitlab_environment do
      Gitlab::Duo::Developments::DapOnboarding.execute
    end

    desc 'GitLab | Duo | Verify MCP server setup'
    task :verify_mcp_server_setup, [:username] => :gitlab_environment do |_, args|
      Gitlab::Duo::Administration::VerifyMcpServerSetup.new(args[:username]).execute
    end

    desc <<~DESC
      GitLab | Duo | Verify Code Review configuration of a project.

      Checks license, instance Duo settings, namespace and project Duo settings,
      foundational flows (including service accounts and their project roles), and
      Duo Code Review availability.

      Usage:
        bundle exec rake "gitlab:duo:verify_setup[PROJECT_PATH]"

      Examples:
        bundle exec rake "gitlab:duo:verify_setup[my-group/my-project]"
        bundle exec rake "gitlab:duo:verify_setup[my-group/sub-group/my-project]"
    DESC
    task :verify_setup, [:project_path] => :gitlab_environment do |_, args|
      Gitlab::Duo::Administration::VerifySetup.new(args[:project_path]).execute
    end
  end
end
