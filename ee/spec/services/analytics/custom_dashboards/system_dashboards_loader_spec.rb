# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::CustomDashboards::SystemDashboardsLoader, feature_category: :custom_dashboards_foundation do
  describe '.all' do
    before do
      described_class.instance_variable_set(:@all, nil)
    end

    it 'only calls new.all once across multiple invocations' do
      instance = instance_double(described_class, all: [])
      allow(described_class).to receive(:new).and_return(instance)

      2.times { described_class.all }

      expect(instance).to have_received(:all).once
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

      it 'returns only valid dashboards' do
        expect(dashboards.length).to eq(1)
        expect(dashboards.first.slug).to eq('valid')
      end
    end
  end
end
