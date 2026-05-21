# frozen_string_literal: true

module Gitlab
  module Duo
    module Developments
      class SweBenchSeeder
        require_relative 'swe_bench_seeder/config'
        require_relative 'swe_bench_seeder/group_manager'
        require_relative 'swe_bench_seeder/repository_manager'
        require_relative 'swe_bench_seeder/issue_manager'
        require_relative 'swe_bench_seeder/dataset_processor'
        require_relative 'swe_bench_seeder/langsmith_client'
        require_relative 'swe_bench_seeder/agent_config_manager'

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity -- Main orchestration method
        def self.seed(project_filter: nil)
          puts "Seeding SWE Bench data structure..."
          puts "Filtering to projects: #{project_filter.join(', ')}" if project_filter

          ensure_local_url_allowed

          user = User.find_by_username('root')
          parent_group = GroupManager.find_or_create_parent_group(user)
          subgroup = GroupManager.find_or_create_subgroup(parent_group, user)

          puts "Subgroup URL: #{Config.seed_base_url}/#{subgroup.full_path}"

          # Fetch dataset first -- needed for both cleanup scoping and seeding.
          dataset, _dataset_name, _split_name = DatasetProcessor.fetch_dataset_from_langsmith
          return if dataset.empty?

          examples = DatasetProcessor.filter_by_project(dataset, project_filter).select do |e|
            e['inputs']['instance_id'] && e['inputs']['repo'] &&
              e['inputs']['base_commit'] && e['inputs']['problem_statement']
          end

          # When no filter is active, wipe the whole subgroup for a clean slate.
          # When a filter is active, only destroy the specific instance projects being
          # re-seeded -- leave all other already-seeded projects untouched.
          if project_filter&.any?
            examples.each do |e|
              instance_id = e['inputs']['instance_id']
              project_name = RepositoryManager.instance_id_to_project_name(instance_id)
              project = Project.find_by_full_path("#{subgroup.full_path}/#{project_name}")
              next unless project

              puts "Destroying existing project for re-seed: #{project.full_path}"
              ::Projects::DestroyService.new(project, user, {}).execute # rubocop:disable Gitlab/HardDeleteCalls -- Dev-only seeder, not production data
            end
          else
            IssueManager.destroy_instance_projects(subgroup, user)
          end

          puts "\n=== Processing examples from SWE Bench Dataset ==="
          puts "==========================================\n"

          issue_data = []

          puts "Found #{examples.size} example(s) to seed\n"

          # Fire all mirrors + forks in parallel, wait with a single polling loop
          projects_by_instance = RepositoryManager.setup_instance_projects(examples, subgroup, user)

          # Commit agent config and create issue for each successfully seeded project
          projects_by_instance.each do |instance_id, project|
            example = examples.find { |e| e['inputs']['instance_id'] == instance_id }
            next unless example

            inputs = example['inputs']

            AgentConfigManager.commit_agent_config(project, user, instance_id: instance_id)

            issue = IssueManager.create_issue_from_problem_statement(project, user, inputs['problem_statement'])
            next unless issue

            issue_url = Rails.application.routes.url_helpers.project_issue_url(project, issue)

            issue_data << {
              inputs: { issue_url: issue_url, **inputs },
              outputs: example['outputs']
            }
          end

          puts "\n#{'=' * 60}"
          puts "SEEDING COMPLETE: #{projects_by_instance.size}/#{examples.size} project(s) seeded"
          puts "=" * 60

          if projects_by_instance.size < examples.size
            raise "Seeding incomplete: only #{projects_by_instance.size}/#{examples.size} projects seeded successfully."
          end

          save_to_langsmith = ENV['SAVE_TO_LANGSMITH'].presence
          if save_to_langsmith.present? && issue_data.any?
            LangsmithClient.save_issue_urls_to_langsmith(issue_data, save_to_langsmith)
          end
        rescue StandardError => e
          puts "Error seeding SWE Bench structure: #{e.message}"
          puts e.backtrace.first(5).join("\n")
          raise
        end

        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        # Ensure the seed_base_url hostname is in the outbound local requests
        # allowlist so that Sidekiq import workers can clone from local mirrors
        # without being blocked by DNS rebinding protection.
        def self.ensure_local_url_allowed
          seed_host = URI.parse(Config.seed_base_url).host
          return unless seed_host

          settings = ApplicationSetting.current_without_cache
          allowlist = settings.outbound_local_requests_whitelist || [] # rubocop:disable Naming/InclusiveLanguage -- existing setting
          return if allowlist.include?(seed_host)

          settings.update!(outbound_local_requests_whitelist: allowlist + [seed_host])
          puts "Added '#{seed_host}' to outbound local requests allowlist"
        end
      end
    end
  end
end
