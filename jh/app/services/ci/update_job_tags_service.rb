# frozen_string_literal: true

module Ci
  class UpdateJobTagsService
    def self.permitted?(job, current_user:)
      job.project.team.max_member_access_for_user(current_user) >= ::Gitlab::Access::MAINTAINER &&
        Ability.allowed?(current_user, :retry_job, job)
    end

    def initialize(job, current_user:, tags:)
      @job = job
      @current_user = current_user
      @tags = tags
    end

    def execute
      return error(s_('JH|Job|You do not have permission to change this job’s tags.'), :forbidden) unless allowed?
      return error(s_('JH|Job|Enter valid job tags.'), :unprocessable_entity) unless valid_tags?

      job.with_lock { update_tags }
    rescue ActiveRecord::StaleObjectError
      error(s_('JH|Job|The job changed while you were editing its tags. Refresh the page and try again.'), :conflict)
    rescue ActiveRecord::RecordInvalid => e
      error(e.record.errors.full_messages.to_sentence, :unprocessable_entity)
    end

    private

    attr_reader :job, :current_user, :tags

    def update_tags
      unless job.pending? && job.runner_id.nil?
        return error(s_('JH|Job|Tags can be changed only while the job is pending and no runner has picked it up.'),
          :conflict)
      end

      unless job.job_definition
        return error(s_('JH|Job|This job’s tags cannot be changed because its job definition is unavailable.'),
          :conflict)
      end

      job.clear_memoization(:tag_list)
      old_tags = job.tag_list.to_a
      job.job_definition_instance.update!(job_definition_id: updated_definition.id)
      job.association(:job_definition).reset
      job.clear_memoization(:tag_list)
      job.clear_memoization(:build_matcher)

      # CommitStatus increments lock_version only when status changes.
      # Increment it here so runners that read the old tags cannot claim this job.
      job.update!(lock_version: job.lock_version + 1)
      Ci::PendingBuild.upsert_from_build!(job)
      notify_after_commit(old_tags)

      ServiceResponse.success(payload: { tags: job.tag_list })
    end

    def updated_definition
      definition = Ci::JobDefinition.fabricate(
        config: job.job_definition.job_attributes.merge(tag_list: tags),
        project_id: job.project_id,
        partition_id: job.partition_id
      )
      definition.validate!

      Gitlab::Ci::JobDefinitions::FindOrCreate.new(job.pipeline, definitions: [definition]).execute.first
    end

    def notify_after_commit(old_tags)
      updated_job = job
      user_id = current_user.id
      new_tags = job.tag_list.to_a
      job.run_after_commit do
        Rails.cache.delete(['has-online-runners', updated_job.id])
        updated_job.expire_etag_cache!
        BuildQueueWorker.perform_async(updated_job.id)
        Gitlab::AppJsonLogger.info(
          event: 'job_tags_updated', job_id: updated_job.id, project_id: updated_job.project_id,
          user_id: user_id, old_tags: old_tags, new_tags: new_tags
        )
      end
    end

    def allowed?
      return false unless self.class.permitted?(job, current_user: current_user)

      ::Users::IdentityVerification::AuthorizeCi.new(user: current_user, project: job.project).authorize_run_jobs!
      true
    rescue ::Users::IdentityVerification::Error
      false
    end

    def valid_tags?
      entry = Gitlab::Ci::Config::Entry::Tags.new(tags)
      entry.valid? && Gitlab::Ci::Tags::Parser.new(tags).parse.all? { |tag| tag.length <= 255 }
    end

    def error(message, status)
      ServiceResponse.error(message: message, reason: status)
    end
  end
end
