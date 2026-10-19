#!/usr/bin/env ruby
# frozen_string_literal: true

# Download failed jobs for the current CI pipeline and write diagnostic artifacts.
# Requires the `gitlab` gem via Bundler: bundle exec ruby ... (from repo root).
#
# Required env:
#   JH_FIX_PIPELINE_PROJECT_TOKEN, CI_PIPELINE_ID
# Optional env:
#   CI_PROJECT_ID, CI_SERVER_URL, CI_JOB_ID, CI_JOB_NAME, FAIL_PIPELINE_PATH

require 'fileutils'
require 'gitlab'
require_relative 'lib/pipeline_diagnostics'

module FixPipeline
  class FailedPipelineFetcher
    IN_PROGRESS = %w[created pending waiting preparing running scheduled manual].freeze
    SUCCESS_STATUSES = %w[success warning].freeze

    Result = Struct.new(:code, :message, keyword_init: true)

    def run
      validate_env!
      configure_api!

      pipeline = fetch_pipeline
      print_pipeline_header(pipeline)

      if SUCCESS_STATUSES.include?(pipeline.fetch('status'))
        return result_ok("pipeline 为 #{pipeline.fetch('status')}，无需修复")
      end

      failed_jobs = fetch_failed_jobs(pipeline.fetch('pipeline_id'))
      puts "\nFailed jobs (excluding self): #{failed_jobs.length}"

      return handle_empty_failed_jobs(pipeline.fetch('status')) if failed_jobs.empty?

      write_artifacts(pipeline, failed_jobs)
    end

    private

    def validate_env!
      abort_error('请设置环境变量 JH_FIX_PIPELINE_PROJECT_TOKEN') if token.to_s.strip.empty?
      abort_error('请设置环境变量 CI_PIPELINE_ID') if pipeline_id_env.to_s.strip.empty?
    end

    def configure_api!
      Gitlab.configure do |config|
        config.endpoint = api_endpoint
        config.private_token = token
      end
    end

    def fetch_pipeline
      pipeline = Gitlab.pipeline(project_id, pipeline_id_env)
      pipeline_id = resource_value(pipeline, :id)

      {
        'pipeline_id' => pipeline_id,
        'status' => resource_value(pipeline, :status),
        'sha' => resource_value(pipeline, :sha),
        'ref' => resource_value(pipeline, :ref),
        'created_at' => resource_value(pipeline, :created_at),
        'updated_at' => resource_value(pipeline, :updated_at),
        'url' => resource_value(pipeline, :web_url) || "#{base_url}/-/pipelines/#{pipeline_id}"
      }
    rescue Gitlab::Error::Error => e
      abort_error("获取 pipeline #{pipeline_id_env} 失败: #{e.message}")
    end

    def fetch_failed_jobs(pipeline_id)
      Gitlab.pipeline_jobs(
        project_id,
        pipeline_id,
        { scope: 'failed', per_page: 100 }
      ).auto_paginate.reject { |job| self_job?(job) }
    rescue Gitlab::Error::Error => e
      abort_error("获取失败 job 列表失败: #{e.message}")
    end

    def handle_empty_failed_jobs(status)
      if IN_PROGRESS.include?(status)
        result_skip("pipeline 状态为 #{status}，且尚无失败 job，暂不修复")
      else
        result_ok('无其他失败 job（已排除 fix-pipeline 自身）')
      end
    end

    def write_artifacts(pipeline, failed_jobs)
      pipeline_id = pipeline.fetch('pipeline_id')
      puts "Pipeline status is #{pipeline.fetch('status')}; " \
        "proceeding with #{failed_jobs.length} failed job(s)."

      pipeline_dir = File.join(fail_pipeline_path, pipeline_id.to_s)
      FileUtils.mkdir_p(pipeline_dir)

      rows = failed_jobs.each_with_index.map do |job, index|
        download_and_diagnose_job(job, pipeline_dir, index, failed_jobs.length)
      end

      summary_path = File.join(pipeline_dir, 'pipeline_summary.md')
      diagnostics_path = File.join(pipeline_dir, 'pipeline_diagnostics.json')

      File.write(summary_path, PipelineDiagnostics.render_markdown(pipeline, rows))
      File.write(diagnostics_path, PipelineDiagnostics.render_json(pipeline, rows))

      puts "\nRESULT: FAILED"
      puts "Summary: #{summary_path}"
      puts "Diagnostics: #{diagnostics_path}"
      puts "Logs dir: #{pipeline_dir}"
      puts "\n后续请直接读取 Summary，按需用 tail 查看各 job 日志末尾，勿再手动 curl API。"

      Result.new(code: :failed, message: summary_path)
    end

    def download_and_diagnose_job(job, pipeline_dir, index, total)
      job_id = resource_value(job, :id)
      job_name = resource_value(job, :name)
      stage = resource_value(job, :stage)
      job_status = resource_value(job, :status)
      failure_reason = resource_value(job, :failure_reason).to_s
      job_url = resource_value(job, :web_url) || "#{base_url}/-/jobs/#{job_id}"

      job_dir = File.join(pipeline_dir, 'jobs', job_id.to_s)
      FileUtils.mkdir_p(job_dir)
      log_path = File.join(job_dir, 'log.log')
      log_download_status = 'ok'

      print "  [#{index + 1}/#{total}] 下载 job #{job_id} (#{job_name})... "
      begin
        trace = Gitlab.job_trace(project_id, job_id).to_s
        File.write(log_path, trace)
        puts "OK (#{trace.bytesize} bytes)"
      rescue StandardError => e
        log_download_status = 'failed'
        File.write(log_path, "[ERROR] 下载日志失败: #{e.message}\n")
        puts "FAILED: #{e.message}"
      end

      log_text = File.read(log_path, encoding: 'UTF-8', invalid: :replace, replace: '')
      diagnostic_failure_reason = log_download_status == 'failed' ? 'api_failure' : failure_reason

      {
        'job_id' => job_id,
        'job_name' => job_name,
        'stage' => stage,
        'status' => job_status,
        'job_url' => job_url,
        'failure_reason' => failure_reason,
        'log_path' => log_path,
        'log_download_status' => log_download_status,
        'diagnostics' => PipelineDiagnostics.analyze(
          log_text,
          job_name: job_name,
          failure_reason: diagnostic_failure_reason
        )
      }
    end

    def print_pipeline_header(pipeline)
      puts "Pipeline ID: #{pipeline.fetch('pipeline_id')}"
      puts "Status: #{pipeline.fetch('status')}"
      puts "Ref: #{pipeline.fetch('ref')}"
      puts "URL: #{pipeline.fetch('url')}"
      puts "SHA: #{pipeline.fetch('sha')}"
      puts "Created: #{pipeline.fetch('created_at')}"
      puts "Updated: #{pipeline.fetch('updated_at')}"
    end

    def self_job?(job)
      job_id = resource_value(job, :id).to_s
      job_name = resource_value(job, :name).to_s

      (!self_job_id.empty? && job_id == self_job_id) ||
        (!self_job_name.empty? && job_name == self_job_name)
    end

    # gitlab gem ObjectifiedHash supports Hash-style access; avoid public_send.
    def resource_value(obj, key)
      return unless obj.respond_to?(:[])

      value = obj[key]
      return value unless value.nil?

      obj[key.to_s]
    end

    def result_ok(message)
      puts "\nRESULT: OK — #{message}"
      Result.new(code: :ok, message: message)
    end

    def result_skip(message)
      puts "\nRESULT: SKIP — #{message}"
      Result.new(code: :skip, message: message)
    end

    def abort_error(message)
      abort("[ERROR] #{message}")
    end

    def token
      ENV['JH_FIX_PIPELINE_PROJECT_TOKEN']
    end

    def pipeline_id_env
      ENV['CI_PIPELINE_ID']
    end

    def project_id
      ENV.fetch('CI_PROJECT_ID') { ENV.fetch('JIHULAB_PROJECT_ID', '3') }
    end

    def api_endpoint
      ENV.fetch('JIHULAB_API_BASE') do
        server = ENV['CI_SERVER_URL']
        server ? "#{server.chomp('/')}/api/v4" : 'https://jihulab.com/api/v4'
      end
    end

    def base_url
      ENV.fetch('JIHULAB_BASE_URL') { ENV.fetch('CI_SERVER_URL', 'https://jihulab.com') }
    end

    def fail_pipeline_path
      ENV.fetch('FAIL_PIPELINE_PATH') do
        File.join(ENV.fetch('CI_PROJECT_DIR', Dir.pwd), 'tmp', 'failed-pipelines')
      end
    end

    def self_job_id
      ENV['CI_JOB_ID'].to_s
    end

    def self_job_name
      ENV['CI_JOB_NAME'].to_s
    end
  end
end

if $PROGRAM_NAME == __FILE__
  FixPipeline::FailedPipelineFetcher.new.run
  exit 0
end
