#!/usr/bin/env ruby
# frozen_string_literal: true

# Create (or comment on) a fix-pipeline Merge Request after commit/push.
# Requires the `gitlab` gem via Bundler: bundle exec ruby ... (from repo root).
#
# Usage:
#   bundle exec ruby jh/scripts/fix-pipeline/create-merge-request.rb [description_file]
#
# Required env:
#   JH_FIX_PIPELINE_PROJECT_TOKEN, CI_PIPELINE_ID, CI_PROJECT_ID
# Optional env:
#   ALLOW_AUTO_PUSH (default: true; set to true / 1 / yes to enable)
#   CI_SERVER_URL, CI_JOB_ID, CI_JOB_URL,
#   CI_PIPELINE_URL, FIX_PIPELINE_DIR, MR_SOURCE_BRANCH, MR_TARGET_BRANCH,
#   MR_TITLE, MR_LABELS, GITLAB_USER_ID (assignee; default 259179)

require 'gitlab'
require 'time'
require_relative 'lib/fix_pipeline_naming'

module FixPipeline
  class CreateMergeRequest
    AUTO_PUSH_ENABLED = %w[true 1 yes].freeze
    DEFAULT_LABELS = 'pipeline-fix,pipeline:run-all-rspec,pipeline-fix::pre-main-jh-attempt-1'
    DEFAULT_TARGET = 'pre-main-jh'
    DEFAULT_ASSIGNEE_ID = 259_179

    def initialize(description_file = nil)
      @description_file = description_file
    end

    def run
      validate!
      configure_api!

      description = build_description
      existing = find_existing_mr

      if existing
        note_existing_mr!(existing, description)
      else
        create_mr!(description)
      end
    end

    private

    def validate!
      abort_error('ALLOW_AUTO_PUSH 未启用（需设为 true / 1 / yes，或手动触发 fix-pipeline job）') unless allow_auto_push?
      abort_error('请设置环境变量 JH_FIX_PIPELINE_PROJECT_TOKEN') if token.to_s.strip.empty?
      abort_error('请设置环境变量 CI_PIPELINE_ID') if pipeline_id.to_s.strip.empty?
      abort_error('请设置环境变量 CI_PROJECT_ID') if project_id.to_s.strip.empty?
      abort_error("变更说明文件不存在: #{resolved_description_file}") unless File.file?(resolved_description_file)
    end

    def configure_api!
      Gitlab.configure do |config|
        config.endpoint = api_endpoint
        config.private_token = token
      end
    end

    def build_description
      notes = File.read(resolved_description_file)
      sections = []
      sections << <<~MD.strip
        ## 自动化修复说明

        | 字段 | 值 |
        |------|-----|
        | Pipeline | #{pipeline_link} |
        | Job | #{job_link} |
        | Source branch | `#{source_branch}` |
        | Target branch | `#{target_branch}` |
        | Generated at | #{Time.now.utc.iso8601} |
      MD

      sections << <<~MD.strip
        #{notes.strip}
      MD

      "#{sections.join("\n\n")}\n"
    end

    def find_existing_mr
      mrs = Gitlab.merge_requests(
        project_id,
        {
          state: 'opened',
          source_branch: source_branch,
          target_branch: target_branch
        }
      )
      Array(mrs).first
    rescue StandardError => e
      abort_error("查询已有 MR 失败: #{e.message}")
    end

    def create_mr!(description)
      mr = Gitlab.create_merge_request(
        project_id,
        title,
        source_branch: source_branch,
        target_branch: target_branch,
        description: description,
        labels: labels,
        remove_source_branch: true,
        assignee_ids: assignee_ids
      )
      url = resource_value(mr, :web_url)
      iid = resource_value(mr, :iid)
      puts "RESULT: CREATED MR !#{iid} — #{url}"
      mr
    rescue StandardError => e
      abort_error("创建 MR 失败: #{e.message}")
    end

    def note_existing_mr!(mr, description)
      iid = resource_value(mr, :iid)
      url = resource_value(mr, :web_url)
      body = <<~MD
        同名修复分支已有打开的 MR，追加本次变更说明（不重复创建 MR）。

        ---

        #{description}
      MD
      Gitlab.create_merge_request_note(project_id, iid, body)
      puts "RESULT: COMMENTED existing MR !#{iid} — #{url}"
      mr
    rescue StandardError => e
      abort_error("向已有 MR 追加说明失败: #{e.message}")
    end

    def resolved_description_file
      @resolved_description_file ||= begin
        explicit = @description_file.to_s.strip
        if explicit.empty?
          latest = Dir.glob(File.join(logs_dir, '*_agent_change_notes.md')).max_by { |path| File.mtime(path) }
          abort_error("未提供 description_file，且 #{logs_dir} 下没有 *_agent_change_notes.md") unless latest
          latest
        else
          File.expand_path(explicit)
        end
      end
    end

    def allow_auto_push?
      AUTO_PUSH_ENABLED.include?(ENV.fetch('ALLOW_AUTO_PUSH', 'false').to_s.downcase)
    end

    def pipeline_link
      url = ENV['CI_PIPELINE_URL'].to_s.strip
      return "[##{pipeline_id}](#{url})" unless url.empty?

      "##{pipeline_id}"
    end

    def job_link
      url = ENV['CI_JOB_URL'].to_s.strip
      job_id = ENV['CI_JOB_ID'].to_s
      return "[##{job_id}](#{url})" if !url.empty? && !job_id.empty?
      return "##{job_id}" unless job_id.empty?

      '（未知）'
    end

    def title
      FixPipelineNaming.mr_title
    end

    def source_branch
      FixPipelineNaming.branch_name
    end

    def target_branch
      ENV.fetch('MR_TARGET_BRANCH', DEFAULT_TARGET)
    end

    def labels
      ENV.fetch('MR_LABELS', DEFAULT_LABELS)
    end

    def assignee_ids
      user_id = ENV['GITLAB_USER_ID'].to_s.strip
      id = user_id.empty? ? DEFAULT_ASSIGNEE_ID : user_id.to_i
      id = DEFAULT_ASSIGNEE_ID if id == 0

      [id]
    end

    def token
      ENV['JH_FIX_PIPELINE_PROJECT_TOKEN']
    end

    def pipeline_id
      ENV['CI_PIPELINE_ID']
    end

    def project_id
      ENV.fetch('CI_PROJECT_ID')
    end

    def api_endpoint
      ENV.fetch('JIHULAB_API_BASE') do
        server = ENV['CI_SERVER_URL']
        server ? "#{server.chomp('/')}/api/v4" : 'https://jihulab.com/api/v4'
      end
    end

    def fix_pipeline_dir
      ENV.fetch('FIX_PIPELINE_DIR') { File.expand_path(__dir__) }
    end

    def logs_dir
      File.join(fix_pipeline_dir, 'logs')
    end

    def resource_value(resource, key)
      if resource.respond_to?(key) # rubocop:disable Style/SafeNavigation
        resource.public_send(key) # rubocop:disable GitlabSecurity/PublicSend
      elsif resource.respond_to?(:[]) # rubocop:disable Style/SafeNavigation
        resource[key] || resource[key.to_s]
      end
    end

    def abort_error(message)
      abort("[ERROR] #{message}")
    end
  end
end

if $PROGRAM_NAME == __FILE__
  FixPipeline::CreateMergeRequest.new(ARGV[0]).run
  exit 0
end
