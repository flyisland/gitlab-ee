# frozen_string_literal: true

ENV['MT_NO_PLUGINS'] = '1'

require 'json'
require 'minitest/autorun'
require_relative '../lib/pipeline_diagnostics'

module FixPipeline
  class PipelineDiagnosticsTest < Minitest::Test
    def test_extracts_upstream_failed_example_and_jh_root_cause
      log = <<~LOG
      2026-08-07T04:50:42.135832Z 01O Failure/Error: @rules = rules.map { |rule| build_rule(rule) }

      ArgumentError: Invalid action: :block. Must be one of: [:limit, :log, :skip]
      # ./jh/lib/jh/gitlab/application_rate_limiter/labkit_adapter/supported_rate_limits.rb:18
      # ./spec/lib/gitlab/application_rate_limiter_spec.rb:42
      Console error in jh/app/assets/javascripts/pipeline_editor_app.vue

      Failed examples:
      rspec ./spec/lib/gitlab/application_rate_limiter_spec.rb:42 # builds the rules
      LOG

      diagnostics = PipelineDiagnostics.analyze(log, job_name: 'rspec unit pg17 1/44')

      assert_equal 'rspec', diagnostics['category']
      assert_equal ['spec/lib/gitlab/application_rate_limiter_spec.rb:42'], diagnostics['failed_examples']
      assert_includes diagnostics['candidate_files'],
        'jh/lib/jh/gitlab/application_rate_limiter/labkit_adapter/supported_rate_limits.rb'
      assert_includes diagnostics['candidate_files'], 'jh/app/assets/javascripts/pipeline_editor_app.vue'
      assert_equal 'ArgumentError: Invalid action: :block. Must be one of: [:limit, :log, :skip]',
        diagnostics['failure_signature']
      assert_equal ['bundle exec rspec spec/lib/gitlab/application_rate_limiter_spec.rb:42'],
        diagnostics['reproduction_hints']
    end

    def test_clusters_jobs_with_the_same_exception
      rows = [
        diagnostic_row(101, shared_failure_log('spec/models/user_spec.rb:10')),
        diagnostic_row(102, shared_failure_log('ee/spec/services/audit_spec.rb:20')),
        diagnostic_row(103, shared_failure_log('spec/models/project_spec.rb:30', exception: 'TypeError: wrong type'))
      ]

      # rubocop:disable Gitlab/Json -- this standalone utility cannot load the Rails-only Gitlab::Json wrapper
      payload = JSON.parse(PipelineDiagnostics.render_json({ 'pipeline_id' => 123 }, rows))
      # rubocop:enable Gitlab/Json

      assert_equal 2, payload.fetch('clusters').length
      assert_equal 2, payload.fetch('clusters').first.fetch('job_count')
      assert_equal [101, 102], payload.fetch('clusters').first.fetch('job_ids')
      assert_equal payload.fetch('jobs')[0].dig('diagnostics', 'cluster_id'),
        payload.fetch('jobs')[1].dig('diagnostics', 'cluster_id')
      assert_operator payload.fetch('jobs')[0].dig('diagnostics', 'cluster_id'), :!=,
        payload.fetch('jobs')[2].dig('diagnostics', 'cluster_id')

      markdown = PipelineDiagnostics.render_markdown({ 'pipeline_id' => 123 }, rows)

      assert_includes markdown, '## Failure clusters'
      assert_includes markdown, 'ArgumentError: Invalid action: :block'
    end

    def test_extracts_rubocop_candidate_from_full_log
      log = <<~LOG
      Inspecting 2 files
      jh/app/services/example.rb:12:7: C: Layout/EmptyLineAfterGuardClause: Add empty line after guard clause.
      2 files inspected, 1 offense detected
      LOG

      diagnostics = PipelineDiagnostics.analyze(log, job_name: 'rubocop-jh')

      assert_equal 'rubocop', diagnostics['category']
      assert_equal ['jh/app/services/example.rb'], diagnostics['candidate_files']
      assert_equal ['BUNDLE_GEMFILE=jh/Gemfile bundle exec rubocop jh/app/services/example.rb'],
        diagnostics['reproduction_hints']
    end

    def test_marks_runner_system_failure_as_infrastructure
      diagnostics = PipelineDiagnostics.analyze(
        'ERROR: Job failed (system failure): prepare environment',
        job_name: 'rspec unit pg17',
        failure_reason: 'runner_system_failure'
      )

      assert_equal 'infrastructure', diagnostics['category']
      assert diagnostics['infrastructure_failure']
    end

    def test_does_not_merge_unknown_jobs_with_only_generic_errors
      rows = [
        diagnostic_row(201, 'ERROR: Job failed: exit code 1', job_name: 'docs-lint'),
        diagnostic_row(202, 'ERROR: Job failed: exit code 1', job_name: 'graphql-schema-dump')
      ]

      # rubocop:disable Gitlab/Json -- this standalone utility cannot load the Rails-only Gitlab::Json wrapper
      payload = JSON.parse(PipelineDiagnostics.render_json({ 'pipeline_id' => 123 }, rows))
      # rubocop:enable Gitlab/Json

      assert_equal 2, payload.fetch('clusters').length
    end

    private

    def diagnostic_row(job_id, log, job_name: 'rspec unit pg17')
      {
        'job_id' => job_id,
        'job_name' => job_name,
        'diagnostics' => PipelineDiagnostics.analyze(log, job_name: job_name)
      }
    end

    def shared_failure_log(example, exception: 'ArgumentError: Invalid action: :block')
      <<~LOG
      Failure/Error: build_rule
      #{exception}
      # ./jh/lib/jh/rule_builder.rb:12
      Failed examples:
      rspec ./#{example}
      LOG
    end
  end
end
