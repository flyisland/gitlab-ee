# frozen_string_literal: true

module Import
  module Sync
    module Repositories
      # Updates two domains: "inventory" (the repository's GitHub identity) and "source" (its branches and tags).
      # Fetched refs never go through post-receive, so they start no pipelines or hooks
      # (https://gitlab.com/gitlab-org/gitlab/-/issues/628597).
      class ReconcileSourceService < BaseReconcileService
        DOMAINS = %w[inventory source].freeze
        # The negative refspec keeps the github/fork/* branches PullRequestImporter creates in
        # GitLab only; they are absent on GitHub, so pruning would delete them.
        PROVIDER_REFMAP = [:heads, :tags, '^refs/heads/github/fork/*'].freeze
        FAILURE_CODE = 'github_update_failed'
        FAILURE_MESSAGE = 'GitHub update failed'
        FAILURE_LOG_MESSAGE = 'GitHub source reconciliation failed'

        private

        def reconcile_under_lease(lease_context)
          targets = prepare_targets
          return result([], false) if targets.empty?

          remote_repository = fetch_provider_repository
          lease_context.renew!
          verify_application_fence!(lease_context)
          apply_provider_identity(remote_repository)
          fetch_source(lease_context) if targets.key?('source')

          apply_success(targets, lease_context)
        end

        def prepare_targets
          repository.with_lock do
            next {} unless application_current?

            locked_states.filter_map do |domain, state|
              next unless state.lagging?

              state.update!(state: :running, last_sync_started_at: now.call)
              [domain, state.desired_generation]
            end.to_h
          end
        end

        def fetch_provider_repository
          provider_client.repository(repository.provider_repository_xid)
        end

        def apply_provider_identity(remote_repository)
          provider_id = remote_repository[:id].to_i
          full_name = remote_repository[:full_name].to_s
          node_id = remote_repository[:node_id].to_s
          default_branch = remote_repository[:default_branch].presence

          unless provider_id == repository.provider_repository_xid && Authentication.valid_full_name?(full_name) &&
              node_id.present?
            raise Errors::ProviderIdentityError, 'GitHub repository identity did not match the synced repository'
          end

          if repository.provider_repository_node_id.present? && repository.provider_repository_node_id != node_id
            raise Errors::ProviderIdentityError, 'GitHub repository identity did not match the synced repository'
          end

          repository.update!(
            provider_full_name: full_name,
            provider_repository_node_id: node_id,
            provider_default_branch: default_branch
          )
        end

        def fetch_source(lease_context)
          verify_application_fence!(lease_context)

          project.repository.fetch_as_mirror(
            authentication.repository_url,
            refmap: PROVIDER_REFMAP,
            forced: true,
            no_tags: true,
            prune: true,
            http_authorization_header: authentication.http_authorization_header,
            resolved_address: authentication.resolved_address
          )
          # Refs changed in Gitaly even if the fence below raises, and change_head reads the cached
          # branch list when ref_existence_check_gitaly is off.
          project.repository.expire_all_method_caches
          lease_context.renew!
          verify_application_fence!(lease_context)

          project.repository.change_head(repository.provider_default_branch) if repository.provider_default_branch
          project.touch(:last_repository_updated_at)
          ProjectCacheWorker.perform_async(project.id, [], %w[repository_size commit_count])
        end

        def apply_success(targets, lease_context)
          follow_up = false
          lease_context.verify!

          repository.with_lock do
            unless application_current?
              raise Errors::StaleApplicationError, 'GitHub updates changed while provider state was being applied'
            end

            states = repository.sync_states_for_update(targets.keys)
            completed_at = now.call

            targets.each do |domain, target_generation|
              state = states.fetch(domain)
              state.synced_generation = [state.synced_generation, target_generation].max
              state.state = state.lagging? ? :pending : :current
              state.last_successful_sync_at = completed_at
              state.last_error_code = nil
              state.last_error_message = nil
              state.save!
              follow_up ||= state.lagging?
            end
          end

          result(targets.keys, follow_up)
        end

        def record_failure!
          repository.with_lock do
            locked_states.each_value do |state|
              mark_failed!(state) if state.running?
            end
          end
        end

        def locked_states
          repository.sync_states_for_update(DOMAINS)
        end
      end
    end
  end
end
