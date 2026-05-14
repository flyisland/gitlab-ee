# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query.ciCatalogResource.projectComponentUsages', feature_category: :pipeline_composition do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:catalog_resource_project) { create(:project, :public) }
  let_it_be(:catalog_resource) { create(:ci_catalog_resource, :published, project: catalog_resource_project) }
  let_it_be(:version) { create(:ci_catalog_resource_version, catalog_resource: catalog_resource) }
  let_it_be(:component) { create(:ci_catalog_resource_component, catalog_resource: catalog_resource, version: version) }

  let_it_be(:using_project) { create(:project, :public) }

  let_it_be(:usage) do
    create(:catalog_resource_component_last_usage,
      component: component,
      catalog_resource: catalog_resource,
      used_by_project_id: using_project.id
    )
  end

  let(:query) do
    <<~GQL
      query {
        ciCatalogResource(fullPath: "#{catalog_resource_project.full_path}") {
          projectComponentUsages {
            nodes {
              project {
                id
                fullPath
              }
              componentsUsed {
                component {
                  id
                  name
                }
                version {
                  id
                  name
                }
                lastUsedDate
                outdated
              }
            }
          }
        }
      }
    GQL
  end

  context 'when licensed' do
    before do
      stub_licensed_features(ci_component_usages_in_projects: true)
    end

    context 'when on SaaS' do
      before do
        stub_saas_features(ci_component_usages_in_projects: true)
      end

      context 'when user is a maintainer of the catalog resource project' do
        before_all do
          catalog_resource_project.add_maintainer(current_user)
        end

        it 'returns component usages grouped by project' do
          post_graphql(query, current_user: current_user)

          usages_data = graphql_data_at(:ci_catalog_resource, :project_component_usages, :nodes)

          expect(usages_data).to be_present
          expect(usages_data.size).to eq(1)

          project_usage = usages_data.first
          expect(project_usage['project']['fullPath']).to eq(using_project.full_path)

          components_used = project_usage['componentsUsed']
          expect(components_used.size).to eq(1)
          expect(components_used.first['component']['name']).to eq(component.name)
          expect(components_used.first['lastUsedDate']).to eq(usage.last_used_date.iso8601)
          expect(components_used.first['outdated']).to be(false)
        end

        context 'when a project uses an outdated component version' do
          let_it_be(:latest_version) do
            create(:ci_catalog_resource_version, semver: '2.0.0', catalog_resource: catalog_resource)
          end

          let_it_be(:old_component) do
            create(:ci_catalog_resource_component, catalog_resource: catalog_resource, version: version)
          end

          let_it_be(:outdated_project) { create(:project, :public) }
          let_it_be(:outdated_usage) do
            create(:catalog_resource_component_last_usage,
              component: old_component,
              catalog_resource: catalog_resource,
              used_by_project_id: outdated_project.id
            )
          end

          it 'returns outdated as true for the old version' do
            post_graphql(query, current_user: current_user)

            usages_data = graphql_data_at(:ci_catalog_resource, :project_component_usages, :nodes)
            outdated_project_usage = usages_data.find { |u| u['project']['fullPath'] == outdated_project.full_path }
            outdated_component = outdated_project_usage['componentsUsed'].find do |c|
              c['component']['id'] == old_component.to_global_id.to_s
            end

            expect(outdated_component['outdated']).to be(true)
          end
        end

        it 'does not produce N+1 queries' do
          control = ActiveRecord::QueryRecorder.new(skip_cached: true) do
            post_graphql(query, current_user: current_user)
          end

          using_project_2 = create(:project, :public)
          create(:catalog_resource_component_last_usage,
            component: component,
            catalog_resource: catalog_resource,
            used_by_project_id: using_project_2.id
          )

          expect { post_graphql(query, current_user: current_user) }.not_to exceed_query_limit(control)
        end
      end

      context 'when user is a developer of the catalog resource project' do
        before_all do
          catalog_resource_project.add_developer(current_user)
        end

        it 'returns null for projectComponentUsages' do
          post_graphql(query, current_user: current_user)

          expect(graphql_data_at(:ci_catalog_resource, :project_component_usages, :nodes)).to be_nil
        end
      end
    end
  end

  context 'when querying multiple catalog resources' do
    let_it_be(:second_project) { create(:project, :public) }
    let_it_be(:second_resource) { create(:ci_catalog_resource, :published, project: second_project) }
    let_it_be(:second_version) { create(:ci_catalog_resource_version, catalog_resource: second_resource) }
    let_it_be(:second_component) do
      create(:ci_catalog_resource_component, catalog_resource: second_resource, version: second_version)
    end

    let_it_be(:second_usage) do
      create(:catalog_resource_component_last_usage,
        component: second_component,
        catalog_resource: second_resource,
        used_by_project_id: create(:project, :public).id
      )
    end

    let(:multi_resource_query) do
      <<~GQL
        query {
          ciCatalogResources {
            nodes {
              projectComponentUsages {
                nodes {
                  project { id }
                }
              }
            }
          }
        }
      GQL
    end

    before do
      stub_licensed_features(ci_component_usages_in_projects: true)
      stub_saas_features(ci_component_usages_in_projects: true)
    end

    before_all do
      catalog_resource_project.add_maintainer(current_user)
      second_project.add_maintainer(current_user)
    end

    it 'returns an error when field call count limit is exceeded' do
      post_graphql(multi_resource_query, current_user: current_user)

      expect_graphql_errors_to_include(
        '"projectComponentUsages" field can be requested only for 1 CiCatalogResource(s) at a time.'
      )
    end
  end

  context 'when not licensed' do
    before do
      stub_licensed_features(ci_component_usages_in_projects: false)
      stub_saas_features(ci_component_usages_in_projects: false)
    end

    context 'when user is a maintainer' do
      before_all do
        catalog_resource_project.add_maintainer(current_user)
      end

      it 'returns null for componentUsages' do
        post_graphql(query, current_user: current_user)

        expect(graphql_data_at(:ci_catalog_resource, :project_component_usages)).to be_nil
      end
    end
  end
end
