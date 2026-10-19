# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::DependencyFirewall::PreventedStats::DataCollector,
  feature_category: :dependency_firewall do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }

  let(:from) { 7.days.ago }

  def collect(container)
    described_class.new(container: container, from: from).counts
  end

  it 'reads a project through the PostgreSQL collector' do
    instance = instance_double(Security::DependencyFirewall::PreventedStats::PostgresqlCollector, counts: :stubbed)
    allow(Security::DependencyFirewall::PreventedStats::PostgresqlCollector)
      .to receive(:new).with(container: project, from: from).and_return(instance)

    expect(collect(project)).to eq(:stubbed)
  end

  it 'returns nil for a group without reading the ledger' do
    expect(Security::DependencyFirewall::PreventedStats::PostgresqlCollector).not_to receive(:new)

    expect(collect(group)).to be_nil
  end
end
