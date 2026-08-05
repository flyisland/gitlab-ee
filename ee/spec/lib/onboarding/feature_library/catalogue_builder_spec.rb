# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Onboarding::FeatureLibrary::CatalogueBuilder, feature_category: :activation do
  let_it_be(:user) { build(:user) }
  let_it_be(:project) { build(:project, :repository, developers: user) }
  let_it_be(:group) { build(:group, developers: user) }

  subject(:catalogue) { described_class.new(panel: panel, user: user, resource: resource).execute }

  shared_examples 'a feature catalogue' do
    it 'returns entries built from sidebar menu items that opt into the Feature Library' do
      expect(catalogue).to be_an(Array)
      expect(catalogue).to be_present
      expect(catalogue).to all(include(:id, :description))
    end

    it 'only includes items that carry a description' do
      expect(catalogue).to all(satisfy { |entry| entry[:description].present? })
    end

    it 'deduplicates by id' do
      ids = catalogue.map { |entry| entry[:id] }

      expect(ids).to eq(ids.uniq)
    end
  end

  context 'with a project panel' do
    let(:resource) { project }
    let(:panel) { 'project' }

    it_behaves_like 'a feature catalogue'
  end

  context 'with a group panel' do
    let(:resource) { group }
    let(:panel) { 'group' }

    it_behaves_like 'a feature catalogue'
  end

  context 'with an unsupported panel' do
    let(:resource) { project }
    let(:panel) { 'admin' }

    it { is_expected.to eq([]) }
  end

  context 'without a container' do
    let(:resource) { nil }
    let(:panel) { 'project' }

    it { is_expected.to eq([]) }
  end

  context 'when building the panel raises' do
    let(:resource) { project }
    let(:panel) { 'project' }

    before do
      allow(Sidebars::Projects::SuperSidebarPanel).to receive(:new).and_raise(StandardError)
    end

    it 'tracks the error and degrades to []', :aggregate_failures do
      expect(Gitlab::ErrorTracking).to receive(:track_exception)
      expect(catalogue).to eq([])
    end
  end
end
