# frozen_string_literal: true

module Ai
  module Catalog
    module ItemConsumers
      class SyncProjectServiceAccountsWorker
        include ApplicationWorker

        feature_category :ai_catalog_curation
        data_consistency :delayed
        urgency :low
        idempotent!
        concurrency_limit -> { 10 }

        defer_on_database_health_signal :gitlab_main, %i[members project_authorizations], 10.minutes

        def perform(user_id, project_ids, _params = {})
          user = User.find_by_id(user_id)
          return unless user

          projects = ::Project.id_in(project_ids)

          AddInheritedServiceAccountsService.new(projects: projects, current_user: user).execute
        end
      end
    end
  end
end
