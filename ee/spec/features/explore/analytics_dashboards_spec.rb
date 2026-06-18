# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Explore > Analytics dashboards', :js, :with_current_organization,
  feature_category: :custom_dashboards_foundation do
  let_it_be(:user) { create(:user) }

  before do
    stub_licensed_features(product_analytics: true)

    sign_in(user)
  end

  context 'when the explore_analytics_dashboards feature flag is disabled' do
    before do
      stub_feature_flags(explore_analytics_dashboards: false)
      visit explore_analytics_dashboards_path
    end

    it 'renders a 404 page' do
      expect(page).to have_content _('Page not found')
    end
  end

  describe 'dashboards list' do
    context 'with no custom dashboards in the current organization' do
      before do
        visit explore_analytics_dashboards_path
      end

      it 'renders the page heading and description', :aggregate_failures do
        expect(page).to have_content _('Analytics dashboards')
        expect(page).to have_content(
          s_('AnalyticsDashboards|Keep your teams aligned around the metrics that matter most.')
        )
      end

      it 'renders the three dashboard scope tabs', :aggregate_failures do
        within('.gl-tabs') do
          expect(page).to have_link s_('AnalyticsDashboards|All')
          expect(page).to have_link s_('AnalyticsDashboards|Created by me')
          expect(page).to have_link s_('AnalyticsDashboards|Created by GitLab')
        end
      end

      it 'renders the default system dashboard in the list' do
        system_dashboard = Analytics::CustomDashboards::SystemDashboardsLoader.all.first

        expect(page).to have_link system_dashboard.name
      end
    end

    context 'with a custom dashboard in the current organization' do
      let_it_be(:dashboard_config) do
        {
          version: '2',
          title: 'Engineering dashboard',
          description: 'Engineering health metrics',
          panels: [
            {
              title: 'Total commits',
              visualization: { type: 'SingleStat', data: { type: 'cube_analytics' } },
              gridAttributes: { width: 4, height: 2, xPos: 0, yPos: 0 }
            },
            {
              title: 'Open MRs',
              visualization: { type: 'SingleStat', data: { type: 'cube_analytics' } },
              gridAttributes: { width: 4, height: 2, xPos: 4, yPos: 0 }
            }
          ]
        }
      end

      let_it_be(:dashboard) do
        create(:dashboard, :organization_scoped,
          name: 'Engineering metrics',
          organization: current_organization,
          created_by: user,
          config: dashboard_config)
      end

      before do
        visit explore_analytics_dashboards_path
      end

      it 'renders the dashboard row and hides the empty state', :aggregate_failures do
        expect(page).to have_link dashboard.name

        # Once the link is confirmed, you safely verify the empty state is gone.
        expect(page).not_to have_content(s_('AnalyticsDashboards|No dashboards found'), wait: 0)
      end

      context 'when the user selects the dashboard' do
        before do
          click_link dashboard.name
        end

        it 'navigates to the dashboard detail view' do
          expect(page).to have_current_path("#{explore_analytics_dashboards_path}/#{dashboard.id}", ignore_query: true)
        end

        it 'renders the dashboard title from its config' do
          expect(page).to have_content dashboard_config[:title]
        end

        it 'renders the dashboard filters bar with all three filters', :aggregate_failures do
          within_testid('dashboard-filters') do
            expect(page).to have_content s_('AnalyticsDashboards|Groups')
            expect(page).to have_content s_('AnalyticsDashboards|Projects')
            expect(page).to have_content s_('AnalyticsDashboards|Date range')
          end
        end

        it 'renders a panel for each entry in the dashboard config', :aggregate_failures do
          dashboard_config[:panels].each do |panel|
            expect(page).to have_content(panel[:title])
          end
        end
      end
    end
  end
end
