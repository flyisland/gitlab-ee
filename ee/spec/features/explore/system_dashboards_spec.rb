# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Explore > Analytics dashboards > System dashboards', :js, :with_current_organization,
  feature_category: :custom_dashboards_foundation do
  include ListboxHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, developers: user) }

  before do
    stub_licensed_features(product_analytics: true)

    sign_in(user)
  end

  def select_group(group)
    find_button(s_('AnalyticsDashboards|Select a group or project')).click
    select_listbox_item(group.name)
  end

  describe 'GitLab Duo and SDLC trends' do
    # `let`, not `let_it_be`, for the dashboards in this file: no records are created, and
    # `let_it_be` freezes its subject, which here is an object the loader memoizes for the
    # lifetime of the RSpec process.
    let(:duo_dashboard) do
      Analytics::CustomDashboards::SystemDashboardsLoader.find_by_slug('duo_and_sdlc_trends')
    end

    let(:dashboard_title) { duo_dashboard.config['title'] }

    # Titles carrying `%{namespaceName}`-style placeholders are interpolated at render
    # time, so only the literal ones can be matched against the page.
    let(:panel_titles) { duo_dashboard.config['panels'].pluck('title').grep_v(/%\{/) }

    before do
      visit explore_analytics_dashboards_path
      click_link duo_dashboard.name
    end

    it 'routes to the dashboard by slug' do
      expect(page).to have_current_path(
        "#{explore_analytics_dashboards_path}/#{duo_dashboard.slug}",
        ignore_query: true
      )
    end

    it 'prompts for a namespace before rendering any panel', :aggregate_failures do
      expect(page).to have_content s_('AnalyticsDashboards|Select a group or project')
      expect(page).to have_no_content panel_titles.first
    end

    context 'when a group is selected' do
      before do
        select_group(group)
      end

      it_behaves_like 'a rendered analytics dashboard'

      # One example rather than several: the before hook mounts every panel,
      # which dominates the runtime, and each example would repeat it.
      it 'replaces the empty state with the dashboard panels', :aggregate_failures do
        expect(page).to have_no_testid('no-namespace-empty-state')
        expect(page).to have_content dashboard_title
        expect(page).to have_content s_('Analytics|No results match your query or filter.')
      end
    end
  end

  describe 'DAP Impact' do
    let(:dap_dashboard) do
      Analytics::CustomDashboards::SystemDashboardsLoader.find_by_slug('dap_impact')
    end

    let(:view_titles) { dap_dashboard.config['views'].pluck('title') }
    let(:overview_panel_title) { dap_dashboard.config['views'].first['panels'].first['title'] }
    let(:adoption_view) { dap_dashboard.config['views'].second }
    let(:adoption_sections) { adoption_view['panels'].select { |panel| panel.key?('section') }.pluck('section') }

    before do
      visit explore_analytics_dashboards_path
      click_link dap_dashboard.name
    end

    it 'routes to the dashboard by slug' do
      expect(page).to have_current_path(
        "#{explore_analytics_dashboards_path}/#{dap_dashboard.slug}",
        ignore_query: true
      )
    end

    it 'renders a tab per view, in order' do
      within_testid('dashboard-views') do
        expect(page.all('a', minimum: view_titles.size).map(&:text)).to eq(view_titles)
      end
    end

    it 'prompts for a namespace before rendering any panel', :aggregate_failures do
      expect(page).to have_content s_('AnalyticsDashboards|Select a group or project')
      expect(page).to have_no_content overview_panel_title
    end

    # The 30 here is hardcoded, not read from the config, so a changed YAML default breaks this
    # test and forces a deliberate decision, rather than the test silently following the config.
    it 'renders the date range filter, defaulting to the last 30 days', :aggregate_failures do
      expect(page).to have_content s_('AnalyticsDashboards|Date range')
      expect(find_by_testid('dashboard-filters-date-range'))
        .to have_text format(_('Last %{days} days'), days: 30)
    end

    context 'when a group is selected' do
      before do
        select_group(group)
      end

      # Only the panel chrome is asserted. The panel queries ClickHouse through a licensed
      # feature, so whether it settles on a value, an empty state or an error is environmental.
      it 'renders the Overview panel', :aggregate_failures do
        expect(page).to have_no_testid('no-namespace-empty-state')
        expect(page).to have_content overview_panel_title
      end

      it 'shows only the selected view, with its section headings, when switching tabs',
        :aggregate_failures do
        within_testid('dashboard-views') { click_link view_titles.second }

        expect(page).to have_no_content overview_panel_title
        expect(page).to have_current_path(/view=1/)

        adoption_sections.each do |section|
          within_testid("section-#{section['title'].downcase.tr(' ', '-')}") do
            expect(page).to have_text(section['title'])
            expect(page).to have_text(section['description'])
          end
        end
      end

      # `:click_house` routes this to the clickhouse25 system job. The plain rspec-ee system job
      # runs with `--tag ~click_house` and has no ClickHouse, so every GLQL panel errors there.
      context 'and the Adoption tab is selected', :click_house do
        # Sections carry no visualization, so only the real panels take part in the GLQL checks.
        let(:adoption_panels) { adoption_view['panels'].reject { |panel| panel.key?('section') } }
        let(:adoption_panel_titles) { adoption_panels.pluck('title') }

        let(:glql_configs) do
          adoption_panels.map { |panel| YAML.safe_load(panel.dig('visualization', 'data', 'query', 'glql')) }
        end

        let(:stat_descriptions) do
          glql_configs
            .select { |config| config['display'] == 'stat' }
            .map { |config| config.dig('displayConfig', 'description') }
        end

        let(:dimensioned_panel_count) { glql_configs.count { |config| config.key?('dimensions') } }

        before do
          # The panel queries need `read_pro_ai_analytics`, which the group policy prevents without it.
          stub_licensed_features(product_analytics: true, ai_analytics: true)

          within_testid('dashboard-views') { click_link view_titles.second }
        end

        # Settled state first, absence second: have_no_content returns immediately when the text is
        # absent, so checked too early it passes while a panel's query is still compiling (async, in
        # WASM) or its GraphQL request is still in flight, and the error text has not appeared yet.
        it 'renders every panel without a GLQL error', :aggregate_failures do
          adoption_panel_titles.each { |title| expect(page).to have_content(title) }

          stat_descriptions.each { |description| expect(page).to have_content(description) }
          expect(page).to have_content(
            s_('Analytics|No results match your query or filter.'), count: dimensioned_panel_count
          )
          expect(page).to have_no_content(s_('Analytics|Something went wrong.'))
        end
      end
    end
  end
end
