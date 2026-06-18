# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoWorkflows::SessionArtifactsFinder, feature_category: :duo_agent_platform do
  let_it_be(:group) { create(:group) }
  let_it_be(:owner) { create(:user) }

  before_all { group.add_owner(owner) }

  before do
    stub_licensed_features(group_level_compliance_dashboard: true)
  end

  subject(:results) do
    described_class.new(current_user: owner, namespace: group, params: {}).execute
  end

  describe '#execute' do
    context 'when ClickHouse is globally enabled for analytics' do
      before do
        allow(::Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(true)
      end

      it 'dispatches to ClickHouseFinder' do
        ch_result = instance_double(::ClickHouse::Client::QueryBuilder)
        expect(::Ai::DuoWorkflows::SessionArtifacts::ClickHouseFinder)
          .to receive(:new).with(namespace: group, params: {}).and_return(
            instance_double(::Ai::DuoWorkflows::SessionArtifacts::ClickHouseFinder, execute: ch_result)
          )

        expect(results).to be(ch_result)
      end
    end

    context 'when ClickHouse is not globally enabled for analytics' do
      before do
        allow(::Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(false)
      end

      it 'dispatches to PostgresqlFinder' do
        pg_result = instance_double(ActiveRecord::Relation)
        expect(::Ai::DuoWorkflows::SessionArtifacts::PostgresqlFinder)
          .to receive(:new).with(namespace: group, params: {}).and_return(
            instance_double(::Ai::DuoWorkflows::SessionArtifacts::PostgresqlFinder, execute: pg_result)
          )

        expect(results).to be(pg_result)
      end
    end

    context 'when the user lacks read_compliance_dashboard permission' do
      let(:non_member) { create(:user) }

      it 'returns no results without dispatching' do
        expect(::Ai::DuoWorkflows::SessionArtifacts::PostgresqlFinder).not_to receive(:new)
        expect(::Ai::DuoWorkflows::SessionArtifacts::ClickHouseFinder).not_to receive(:new)

        results = described_class.new(current_user: non_member, namespace: group, params: {}).execute

        expect(results).to be_empty
      end
    end

    context 'when group_level_compliance_dashboard is not licensed' do
      before do
        stub_licensed_features(group_level_compliance_dashboard: false)
      end

      it 'returns no results' do
        expect(results).to be_empty
      end
    end
  end
end
