# frozen_string_literal: true

module Resolvers
  module Ci
    module Catalog
      module Resources
        class ProjectComponentUsagesResolver < BaseResolver
          include Gitlab::Graphql::Authorize::AuthorizeResource

          type [::Types::Ci::Catalog::Resources::ProjectUsageType], null: true

          alias_method :catalog_resource, :object

          def resolve
            raise_resource_not_available_error! unless feature_available?
            return unless authorized?

            usages = fetch_usages
            return [] if usages.empty?

            visible_projects = fetch_visible_projects(usages)
            return [] if visible_projects.empty?

            build_project_usages(usages, visible_projects)
          end

          private

          def authorized?
            return true if current_user&.can_admin_all_resources?

            current_user&.can?(:maintainer_access, catalog_resource.project) # rubocop:disable Gitlab/Authz/PermissionCheck -- intentional maintainer role check
          end

          def feature_available?
            return false unless Feature.enabled?(:ci_component_analytics, catalog_resource.project)

            License.feature_available?(:ci_component_usages_in_projects) ||
              ::Gitlab::Saas.feature_available?(:ci_component_usages_in_projects)
          end

          def fetch_usages
            ::Ci::Catalog::Resources::Components::LastUsage
              .for_catalog_resource_with_component_versions(catalog_resource.id)
              .to_a
          end

          def fetch_visible_projects(usages)
            project_ids = usages.map(&:used_by_project_id).uniq

            Project
              .id_in(project_ids)
              .public_or_visible_to_user(current_user)
              .non_archived
              .index_by(&:id)
          end

          def build_project_usages(usages, visible_projects)
            usages_by_project = usages
              .select { |u| visible_projects.key?(u.used_by_project_id) }
              .group_by(&:used_by_project_id)

            usages_by_project.map do |project_id, project_usages|
              build_project_usage(visible_projects[project_id], project_usages)
            end
          end

          def build_project_usage(project, project_usages)
            components_used = project_usages.map do |usage|
              {
                component: usage.component,
                version: usage.component.version,
                last_used_date: usage.last_used_date,
                outdated: older_than_latest?(usage.component.version)
              }
            end

            {
              project: project,
              components_used: components_used
            }
          end

          def older_than_latest?(version)
            return false unless version&.semver && latest_version&.semver

            version.semver < latest_version.semver
          end

          def latest_version
            @latest_version ||= catalog_resource.versions.latest
          end
        end
      end
    end
  end
end
