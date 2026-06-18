# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Ai::Catalog::ItemConsumer::BulkCreate, feature_category: :workflow_catalog do
  include Ai::Catalog::TestHelpers
  include GraphqlHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, owners: user) }
  let_it_be(:project_1) { create(:project, group: group, maintainers: user) }
  let_it_be(:project_2) { create(:project, group: group, maintainers: user) }
  let_it_be(:item) { create(:ai_catalog_agent, :with_released_version, public: true) }

  let(:current_user) { user }
  let(:params) do
    {
      item_id: item.to_global_id.to_s,
      project_ids: [project_1.to_global_id.to_s, project_2.to_global_id.to_s]
    }
  end

  let(:mutation) { graphql_mutation(:ai_catalog_item_consumer_bulk_create, params, 'errors') }

  subject(:execute) { post_graphql_mutation(mutation, current_user: current_user) }

  before do
    enable_ai_catalog
  end

  context 'when feature flag is disabled' do
    before do
      stub_feature_flags(ai_catalog_bulk_item_consumer_create: false)
    end

    it_behaves_like 'a mutation that returns a top-level access error'
  end

  it 'enqueues the worker and returns success' do
    expect(::Ai::Catalog::ItemConsumers::BulkCreateWorker).to receive(:perform_async).with(
      user.id,
      item.id,
      contain_exactly(project_1.id, project_2.id),
      {}
    )

    execute

    expect(graphql_data_at(:ai_catalog_item_consumer_bulk_create, :errors)).to be_empty
    expect(graphql_errors).to be_nil
  end

  context 'when trigger_types and trigger_filter are provided' do
    let_it_be(:item) { create(:ai_catalog_flow, :with_released_version, public: true) }

    let(:trigger_filter) do
      {
        'pipeline_hooks' => {
          'rules' => [
            { 'field' => 'object_attributes.status', 'operator' => 'in', 'value' => %w[success failed] }
          ]
        }
      }
    end

    # We can't reuse the shared `mutation`/`params` helpers here. The `graphql_mutation` helper camelizes keys inside
    # the JSON-typed `triggerFilter` (e.g. `pipeline_hooks` becomes `pipelineHooks`).
    let(:query) do
      <<~MUTATION
        mutation($input: AiCatalogItemConsumerBulkCreateInput!) {
          aiCatalogItemConsumerBulkCreate(input: $input) {
            errors
          }
        }
      MUTATION
    end

    let(:input) do
      {
        itemId: item.to_global_id.to_s,
        projectIds: [project_1.to_global_id.to_s, project_2.to_global_id.to_s],
        triggerTypes: %w[pipeline_hooks],
        triggerFilter: trigger_filter
      }
    end

    subject(:execute) { post_graphql(query, current_user: current_user, variables: { input: input }.to_json) }

    it 'enqueues the worker with the trigger filter', :aggregate_failures do
      expect(::Ai::Catalog::ItemConsumers::BulkCreateWorker).to receive(:perform_async).with(
        user.id,
        item.id,
        contain_exactly(project_1.id, project_2.id),
        { 'trigger_types' => %w[pipeline_hooks], 'trigger_filter' => trigger_filter }
      )

      execute

      expect(graphql_data_at(:ai_catalog_item_consumer_bulk_create, :errors)).to be_empty
      expect(graphql_errors).to be_nil
    end
  end

  context 'when too many project_ids are passed' do
    let(:params) do
      {
        item_id: item.to_global_id.to_s,
        project_ids: Array.new(described_class::MAX_PROJECTS + 1) { "gid://gitlab/Project/1" }
      }
    end

    it_behaves_like 'a mutation that returns top-level errors',
      errors: ["projectIds is too long (maximum is 100)"]
  end

  context 'when user cannot read the item' do
    let_it_be(:private_item) { create(:ai_catalog_agent, public: false) }

    let(:current_user) { create(:user) }
    let(:params) do
      {
        item_id: private_item.to_global_id.to_s,
        project_ids: [project_1.to_global_id.to_s]
      }
    end

    it_behaves_like 'a mutation that returns a top-level access error', errors: [
      "The resource that you are attempting to access does not exist or " \
        "you don't have permission to perform this action"
    ]
  end

  context 'when the enqueue service returns an error' do
    let_it_be(:other_group) { create(:group) }
    let_it_be(:unauthorized_project) { create(:project, group: other_group) }

    let(:params) do
      {
        item_id: item.to_global_id.to_s,
        project_ids: [project_1.to_global_id.to_s, unauthorized_project.to_global_id.to_s]
      }
    end

    it 'returns an error and does not enqueue the worker' do
      expect(::Ai::Catalog::ItemConsumers::BulkCreateWorker).not_to receive(:perform_async)

      execute

      expect(graphql_data_at(:ai_catalog_item_consumer_bulk_create, :errors)).to include(
        'One or more projects not found, or you do not have permission to enable this item in the project.'
      )
    end
  end
end
