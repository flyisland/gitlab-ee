# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Catalog::Flows::SeedFoundationalFlowsService, feature_category: :workflow_catalog do
  let_it_be(:default_organization) { create(:organization) }

  let(:service) { described_class.new(organization: default_organization) }

  describe '#execute' do
    context 'with workflow attributes mapping' do
      it 'seeds all foundational workflows' do
        service.execute

        expect(Ai::Catalog::Item.foundational_flows.count).to eq(Ai::Catalog::FoundationalFlow.all.count)
      end
    end

    it 'seeds flows without reloading their organization' do
      expect { service.execute }.not_to exceed_query_limit(0).for_model(Organizations::Organization)
    end
  end
end
