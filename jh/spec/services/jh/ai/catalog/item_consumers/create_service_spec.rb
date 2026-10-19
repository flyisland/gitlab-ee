# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Catalog::ItemConsumers::CreateService, feature_category: :workflow_catalog do
  let(:group) { build_stubbed(:group, name: 'Test Group') }
  let(:current_user) { build_stubbed(:user) }
  let(:item) do
    build_stubbed(
      :ai_catalog_flow,
      name: item_name,
      foundational_flow_reference: foundational_flow_reference
    )
  end

  let(:service) do
    described_class.new(
      container: group,
      current_user: current_user,
      params: { item: item }
    )
  end

  subject(:service_account_identity) do
    {
      name: service.send(:service_account_name),
      username: service.send(:service_account_username)
    }
  end

  context 'for the JH advanced code review flow' do
    let(:item_name) { 'JH Advanced Code Review' }
    let(:foundational_flow_reference) { 'jh_advanced_code_review/v1' }

    it 'uses the dedicated JihuLab Duo service account identity' do
      expect(service_account_identity).to eq(
        name: 'JihuLab Duo',
        username: 'JihuLabDuo'
      )
    end
  end

  context 'for another foundational flow' do
    let(:item_name) { 'Developer' }
    let(:foundational_flow_reference) { 'developer/v1' }

    it 'keeps the upstream service account naming behavior' do
      expect(service_account_identity).to eq(
        name: 'Duo Developer',
        username: 'duo-developer-test-group'
      )
    end
  end
end
