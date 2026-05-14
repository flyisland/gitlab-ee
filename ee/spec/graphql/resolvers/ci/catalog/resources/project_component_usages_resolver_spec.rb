# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Ci::Catalog::Resources::ProjectComponentUsagesResolver, feature_category: :pipeline_composition do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:catalog_resource_project) { create(:project) }
  let_it_be(:catalog_resource) { create(:ci_catalog_resource, project: catalog_resource_project) }
  let_it_be(:version) { create(:ci_catalog_resource_version, catalog_resource: catalog_resource) }
  let_it_be(:component) { create(:ci_catalog_resource_component, catalog_resource: catalog_resource, version: version) }

  let_it_be(:using_project_1) { create(:project, :public) }
  let_it_be(:using_project_2) { create(:project, :public) }
  let_it_be(:private_project) { create(:project, :private) }

  let_it_be(:usage_1) do
    create(:catalog_resource_component_last_usage,
      component: component,
      catalog_resource: catalog_resource,
      used_by_project_id: using_project_1.id
    )
  end

  let_it_be(:usage_2) do
    create(:catalog_resource_component_last_usage,
      component: component,
      catalog_resource: catalog_resource,
      used_by_project_id: using_project_2.id
    )
  end

  let_it_be(:private_usage) do
    create(:catalog_resource_component_last_usage,
      component: component,
      catalog_resource: catalog_resource,
      used_by_project_id: private_project.id
    )
  end

  describe '#resolve' do
    let(:resolve_component_usages) do
      resolve(described_class, obj: catalog_resource, ctx: { current_user: current_user })
    end

    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(ci_component_analytics: false)
      end

      context 'when user is a maintainer' do
        before_all do
          catalog_resource_project.add_maintainer(current_user)
        end

        it 'raises a resource not available error' do
          expect_graphql_error_to_be_created(Gitlab::Graphql::Errors::ResourceNotAvailable) do
            resolve_component_usages
          end
        end
      end
    end

    context 'when feature flag is enabled' do
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

            context 'when there are no usages' do
              let_it_be(:empty_resource) { create(:ci_catalog_resource, project: create(:project)) }

              before_all do
                empty_resource.project.add_maintainer(current_user)
              end

              it 'returns empty array' do
                result = resolve(described_class, obj: empty_resource, ctx: { current_user: current_user })

                expect(result).to eq([])
              end
            end

            context 'when all using projects are private and not visible to the user' do
              let_it_be(:private_only_resource) { create(:ci_catalog_resource, project: create(:project)) }
              let_it_be(:private_only_version) do
                create(:ci_catalog_resource_version, catalog_resource: private_only_resource)
              end

              let_it_be(:private_only_component) do
                create(:ci_catalog_resource_component,
                  catalog_resource: private_only_resource, version: private_only_version)
              end

              let_it_be(:private_only_usage) do
                create(:catalog_resource_component_last_usage,
                  component: private_only_component,
                  catalog_resource: private_only_resource,
                  used_by_project_id: create(:project, :private).id
                )
              end

              before_all do
                private_only_resource.project.add_maintainer(current_user)
              end

              it 'returns empty array' do
                result = resolve(described_class, obj: private_only_resource, ctx: { current_user: current_user })

                expect(result).to eq([])
              end
            end

            it 'returns usages for visible projects only' do
              result = resolve_component_usages

              expect(result.size).to eq(2)
              project_ids = result.map { |r| r[:project].id }
              expect(project_ids).to contain_exactly(using_project_1.id, using_project_2.id)
            end

            context 'when user also has access to private project' do
              before_all do
                private_project.add_developer(current_user)
              end

              it 'includes the private project usage' do
                result = resolve_component_usages

                expect(result.size).to eq(3)
                project_ids = result.map { |r| r[:project].id }
                expect(project_ids).to contain_exactly(using_project_1.id, using_project_2.id, private_project.id)
              end
            end
          end

          context 'when user is not a maintainer of the catalog resource project' do
            let_it_be(:non_maintainer) { create(:user) }

            let(:resolve_component_usages) do
              resolve(described_class, obj: catalog_resource, ctx: { current_user: non_maintainer })
            end

            it 'returns nil' do
              expect(resolve_component_usages).to be_nil
            end

            context 'when user is a developer' do
              before_all do
                catalog_resource_project.add_developer(non_maintainer)
              end

              it 'returns nil' do
                expect(resolve_component_usages).to be_nil
              end
            end
          end

          context 'when there is no current user' do
            let(:resolve_component_usages) do
              resolve(described_class, obj: catalog_resource, ctx: { current_user: nil })
            end

            it 'returns nil' do
              expect(resolve_component_usages).to be_nil
            end
          end
        end

        context 'when user is an admin', :enable_admin_mode do
          let_it_be(:current_user) { create(:admin) }

          it 'returns usages for all visible projects' do
            result = resolve_component_usages

            expect(result.size).to eq(3)
            project_ids = result.map { |r| r[:project].id }
            expect(project_ids).to contain_exactly(using_project_1.id, using_project_2.id, private_project.id)
          end
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

          it 'raises a resource not available error' do
            expect_graphql_error_to_be_created(Gitlab::Graphql::Errors::ResourceNotAvailable) do
              resolve_component_usages
            end
          end
        end
      end
    end
  end
end
