# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::CustomDashboards::SystemDashboardsLoader, feature_category: :custom_dashboards_foundation do
  describe '.all' do
    # Derived from the directory rather than hardcoded: `#all` drops a dashboard that fails schema
    # validation, so asserting against a fixed list would let an invalid new file pass unnoticed.
    # Scoped to this block because `#all` below stubs `Dir.glob`.
    let(:shipped_slugs) do
      Dir.glob(described_class::PATH.join('*.yaml')).map { |file| File.basename(file, '.yaml') }
    end

    it 'returns SystemDashboard instances for every shipped yaml file', :aggregate_failures do
      # This repeats the implementation's own glob, so an empty result would otherwise pass green.
      expect(shipped_slugs).not_to be_empty

      expect(described_class.all).to all(be_a(Analytics::CustomDashboards::SystemDashboard))
      expect(described_class.all.map(&:slug)).to match_array(shipped_slugs)
    end

    it 'memoizes the result across invocations' do
      first_call = described_class.all
      second_call = described_class.all

      expect(second_call).to be(first_call)
    end

    # Pins the grid layout so a trimmed row cannot quietly leave two panels overlapping.
    it 'tiles every shipped dashboard without overlapping panels', :aggregate_failures do
      dashboards = described_class.all

      dashboards.each do |dashboard|
        # The page only treats a dashboard as having views when the list is not empty.
        groups = dashboard.config['views'].presence&.map { |view| view['panels'] } || [dashboard.config['panels']]

        groups.each do |panels|
          occupied = Set.new

          panels.to_a.each do |panel|
            grid = panel['gridAttributes']
            rows = grid['yPos']...(grid['yPos'] + grid['height'])
            cols = grid.fetch('xPos', 0)...(grid.fetch('xPos', 0) + grid.fetch('width', 12))

            cells = rows.flat_map { |row| cols.map { |col| [row, col] } }
            overlap = cells.find { |cell| occupied.include?(cell) }
            occupied.merge(cells)

            expect(overlap).to be_nil,
              "#{dashboard.slug}: panel '#{panel['title']}' overlaps another at row #{overlap&.first}, " \
                "column #{overlap&.last}"
          end
        end
      end
    end

    context 'in development' do
      before do
        stub_rails_env('development')
      end

      it 'reloads the yaml on every invocation' do
        first_call = described_class.all
        second_call = described_class.all

        expect(second_call).not_to be(first_call)
      end
    end
  end

  describe '.find_by_slug' do
    it 'returns the dashboard whose slug matches', :aggregate_failures do
      dashboard = described_class.find_by_slug('duo_and_sdlc_trends')

      expect(dashboard).to be_a(Analytics::CustomDashboards::SystemDashboard)
      expect(dashboard.slug).to eq('duo_and_sdlc_trends')
    end

    it 'returns nil when no dashboard matches the slug' do
      expect(described_class.find_by_slug('missing')).to be_nil
    end
  end

  describe '.by_slug' do
    it 'returns dashboards indexed by slug', :aggregate_failures do
      indexed = described_class.by_slug

      expect(indexed.keys).to include('duo_and_sdlc_trends')
      expect(indexed['duo_and_sdlc_trends']).to be_a(Analytics::CustomDashboards::SystemDashboard)
    end

    it 'memoizes the result across invocations' do
      first_call = described_class.by_slug
      second_call = described_class.by_slug

      expect(second_call).to be(first_call)
    end

    context 'in development' do
      before do
        stub_rails_env('development')
      end

      it 'reloads the yaml on every invocation' do
        first_call = described_class.by_slug
        second_call = described_class.by_slug

        expect(second_call).not_to be(first_call)
      end
    end
  end

  describe '#all' do
    let(:loader) { described_class.new }

    subject(:dashboards) { loader.all }

    context 'when valid YAML files exist' do
      let(:valid_config) do
        {
          'title' => 'Test Dashboard',
          'version' => '2',
          'panels' => []
        }
      end

      before do
        allow(Dir).to receive(:glob).and_return(['/fake/path/test_dashboard.yaml'])
        allow(File).to receive(:read).with('/fake/path/test_dashboard.yaml').and_return(valid_config.to_yaml)
        allow(loader).to receive(:schema_errors_for).and_return(nil)
      end

      it 'returns an array of SystemDashboard objects' do
        expect(dashboards).to all(be_a(Analytics::CustomDashboards::SystemDashboard))
      end

      it 'sets the slug from the filename' do
        expect(dashboards.first.slug).to eq('test_dashboard')
      end

      it 'sets the config from the YAML content' do
        expect(dashboards.first.config).to include('title' => 'Test Dashboard')
      end
    end

    context 'when no YAML files exist' do
      before do
        allow(Dir).to receive(:glob).and_return([])
      end

      it { is_expected.to be_empty }
    end

    context 'when YAML file fails schema validation' do
      let(:invalid_config) { { 'invalid' => 'config' } }

      before do
        allow(Dir).to receive(:glob).and_return(['/fake/path/invalid.yaml'])
        allow(File).to receive(:read).with('/fake/path/invalid.yaml').and_return(invalid_config.to_yaml)
        allow(loader).to receive(:schema_errors_for).and_return(['title is required'])
      end

      it { is_expected.to be_empty }

      it 'tracks the exception' do
        expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
          an_instance_of(StandardError).and(have_attributes(message: include('Invalid system dashboard YAML')))
        )

        dashboards
      end
    end

    context 'when YAML file raises an error' do
      before do
        allow(Dir).to receive(:glob).and_return(['/fake/path/broken.yaml'])
        allow(File).to receive(:read).with('/fake/path/broken.yaml').and_raise(StandardError, 'file read error')
      end

      it { is_expected.to be_empty }

      it 'tracks the exception' do
        expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
          an_instance_of(StandardError).and(have_attributes(message: 'file read error'))
        )

        dashboards
      end
    end

    context 'when multiple YAML files exist' do
      let(:config) { { 'title' => 'Dashboard', 'version' => '2', 'panels' => [] } }

      before do
        allow(Dir).to receive(:glob).and_return([
          '/fake/path/dashboard_one.yaml',
          '/fake/path/dashboard_two.yaml'
        ])
        allow(File).to receive(:read).and_return(config.to_yaml)
        allow(loader).to receive(:schema_errors_for).and_return(nil)
      end

      it 'returns a dashboard for each valid file' do
        expect(dashboards.length).to eq(2)
      end

      it 'sets correct slugs for each dashboard' do
        expect(dashboards.map(&:slug)).to contain_exactly('dashboard_one', 'dashboard_two')
      end
    end

    context 'when some files are valid and some are invalid' do
      let(:valid_config) { { 'title' => 'Valid', 'version' => '2', 'panels' => [] } }

      before do
        allow(Dir).to receive(:glob).and_return([
          '/fake/path/valid.yaml',
          '/fake/path/invalid.yaml'
        ])
        allow(File).to receive(:read).with('/fake/path/valid.yaml').and_return(valid_config.to_yaml)
        allow(File).to receive(:read).with('/fake/path/invalid.yaml').and_raise(StandardError, 'bad file')
        allow(loader).to receive(:schema_errors_for).and_return(nil)
        allow(Gitlab::ErrorTracking).to receive(:track_exception)
      end

      it 'returns only valid dashboards', :aggregate_failures do
        expect(dashboards.length).to eq(1)
        expect(dashboards.first.slug).to eq('valid')
      end
    end
  end
end
