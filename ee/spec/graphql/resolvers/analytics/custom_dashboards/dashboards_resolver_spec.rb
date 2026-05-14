# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Analytics::CustomDashboards::DashboardsResolver, feature_category: :custom_dashboards_foundation do
  include GraphqlHelpers

  let_it_be(:organization) { create(:organization) }
  let_it_be(:user) { create(:user) }
  let_it_be(:other_user) { create(:user) }

  let(:namespace) { create(:group, organization: organization) }
  let(:other_namespace) { create(:group, organization: organization) }

  let_it_be(:org_dashboard1) do
    create(:dashboard, organization: organization, namespace: nil, name: 'Sales Dashboard', created_by: user)
  end

  let_it_be(:org_dashboard2) do
    create(:dashboard, organization: organization, namespace: nil, name: 'Marketing Dashboard', created_by: other_user)
  end

  let(:namespace_dashboard) do
    create(:dashboard, organization: organization, namespace: namespace, name: 'Team Dashboard')
  end

  let(:other_namespace_dashboard) do
    create(:dashboard, organization: organization, namespace: other_namespace, name: 'Other Team Dashboard')
  end

  let_it_be(:other_org_dashboard) { create(:dashboard, name: 'External Dashboard') }

  let(:current_user) { user }
  let(:args) { { organization_id: organization.to_global_id } }

  subject(:dashboards) do
    resolve(described_class, args: args, ctx: { current_user: current_user })
  end

  before do
    stub_licensed_features(product_analytics: true)
  end

  describe '#resolve' do
    context 'when user is an organization member' do
      before do
        create(:organization_user, organization: organization, user: user)
      end

      context 'without namespace access' do
        before do
          namespace_dashboard
          other_namespace_dashboard
        end

        it 'returns only organization-scoped dashboards' do
          expect(dashboards.nodes).to contain_exactly(org_dashboard1, org_dashboard2)
        end

        it 'does not return namespace-scoped dashboards without permission' do
          expect(dashboards.nodes).not_to include(namespace_dashboard, other_namespace_dashboard)
        end

        it 'orders by created_at desc' do
          expect(dashboards.nodes.first.created_at).to be >= dashboards.nodes.last.created_at
        end
      end

      context 'with namespace access' do
        before do
          namespace_dashboard
          other_namespace_dashboard
          create(:group_member, :reporter, group: namespace, user: user)
        end

        it 'returns organization-scoped and accessible namespace-scoped dashboards' do
          expect(dashboards.nodes).to contain_exactly(
            org_dashboard1,
            org_dashboard2,
            namespace_dashboard
          )
        end

        it 'does not return namespace-scoped dashboards from inaccessible namespaces' do
          expect(dashboards.nodes).not_to include(other_namespace_dashboard)
        end

        it 'orders by created_at desc' do
          expect(dashboards.nodes.first.created_at).to be >= dashboards.nodes.last.created_at
        end
      end

      context 'with multiple namespace access' do
        before do
          namespace_dashboard
          other_namespace_dashboard
          create(:group_member, :reporter, group: namespace, user: user)
          create(:group_member, :reporter, group: other_namespace, user: user)
        end

        it 'returns all accessible dashboards' do
          expect(dashboards.nodes).to contain_exactly(
            org_dashboard1,
            org_dashboard2,
            namespace_dashboard,
            other_namespace_dashboard
          )
        end
      end

      it 'does not return dashboards from other organizations' do
        expect(dashboards.nodes).not_to include(other_org_dashboard)
      end
    end

    context 'when user is not an organization member' do
      let(:current_user) { create(:user) }

      it 'raises authorization error' do
        expect(dashboards).to be_a(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'when feature is not licensed' do
      before do
        create(:organization_user, organization: organization, user: user)
        stub_licensed_features(product_analytics: false)
      end

      it 'raises authorization error' do
        expect(dashboards).to be_a(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'when feature flag is disabled' do
      before do
        create(:organization_user, organization: organization, user: user)
        stub_feature_flags(custom_dashboard_storage: false)
      end

      it 'raises authorization error' do
        expect(dashboards).to be_a(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'with namespace filter' do
      let(:args) { { organization_id: organization.to_global_id, namespace_id: namespace.to_global_id } }

      before do
        create(:organization_user, organization: organization, user: user)
      end

      context 'when user has namespace access' do
        before do
          namespace_dashboard
          other_namespace_dashboard
          create(:group_member, :reporter, group: namespace, user: user)
        end

        it 'returns only dashboards in the specified namespace' do
          expect(dashboards.nodes).to contain_exactly(namespace_dashboard)
        end

        it 'does not return organization-scoped dashboards' do
          expect(dashboards.nodes).not_to include(org_dashboard1, org_dashboard2)
        end

        it 'does not return dashboards from other namespaces' do
          expect(dashboards.nodes).not_to include(other_namespace_dashboard)
        end
      end

      context 'when user does not have namespace access' do
        before do
          namespace_dashboard
        end

        it 'returns empty result' do
          expect(dashboards.nodes).to be_empty
        end
      end
    end

    context 'with created_by filter' do
      let(:args) { { organization_id: organization.to_global_id, created_by_id: user.to_global_id } }

      before do
        create(:organization_user, organization: organization, user: user)
      end

      it 'returns only dashboards created by the specified user' do
        expect(dashboards.nodes).to contain_exactly(org_dashboard1)
      end
    end

    context 'with combined filters' do
      let(:args) do
        {
          organization_id: organization.to_global_id,
          namespace_id: namespace.to_global_id,
          created_by_id: user.to_global_id
        }
      end

      let(:user_namespace_dashboard) do
        create(:dashboard, organization: organization, namespace: namespace, created_by: user)
      end

      before do
        create(:organization_user, organization: organization, user: user)
        user_namespace_dashboard
        create(:group_member, :reporter, group: namespace, user: user)
      end

      it 'applies all filters correctly' do
        expect(dashboards.nodes).to contain_exactly(user_namespace_dashboard)
      end
    end

    context 'with search filter' do
      let(:args) { { organization_id: organization.to_global_id, search: 'Sales' } }

      before do
        create(:organization_user, organization: organization, user: user)
      end

      it 'returns only dashboards matching the search term' do
        expect(dashboards.nodes).to contain_exactly(org_dashboard1)
      end

      it 'does not return dashboards that do not match the search term' do
        expect(dashboards.nodes).not_to include(org_dashboard2)
      end

      context 'when search term does not match any dashboard' do
        let(:args) { { organization_id: organization.to_global_id, search: 'Nonexistent' } }

        it 'returns empty result' do
          expect(dashboards.nodes).to be_empty
        end
      end
    end

    context 'with combined search and created_by filter' do
      let(:args) do
        {
          organization_id: organization.to_global_id,
          search: 'Sales',
          created_by_id: user.to_global_id
        }
      end

      before do
        create(:organization_user, organization: organization, user: user)
      end

      it 'applies both filters correctly' do
        expect(dashboards.nodes).to contain_exactly(org_dashboard1)
      end
    end
  end
end
