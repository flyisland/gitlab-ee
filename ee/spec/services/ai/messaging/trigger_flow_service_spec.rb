# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Messaging::TriggerFlowService, feature_category: :duo_agent_platform do
  subject(:result) { service.execute }

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, group: group, path: 'duo-workspace') }
  let_it_be(:current_user) { create(:user, developer_of: group) }
  let_it_be(:service_account) do
    create(:user, :service_account) do |user|
      create(:user_detail, user: user, provisioned_by_group: group)
    end
  end

  # Create the catalog item that FoundationalFlow['developer/v1'].catalog_item resolves to
  let_it_be(:catalog_item) do
    create(:ai_catalog_item, :public, :flow, foundational_flow_reference: 'developer/v1')
  end

  let(:goal) { 'Fix the CI pipeline for the main branch' }
  let(:callback_context) { { 'adapter' => 'slack', 'channel_id' => 'C123', 'thread_ts' => '1234.5678' } }

  let(:service) do
    described_class.new(current_user: current_user, goal: goal, callback_context: callback_context)
  end

  before do
    allow(current_user).to receive(:default_duo_namespace).and_return(group)
  end

  describe '#execute' do
    context 'when user has no default duo namespace' do
      before do
        allow(current_user).to receive(:default_duo_namespace).and_return(nil)
      end

      it 'returns namespace_not_configured error', :aggregate_failures do
        expect(result).to be_error
        expect(result.reason).to eq(:namespace_not_configured)
        expect(result.message).to include('No default Duo namespace configured')
      end
    end

    context 'when user default namespace is a nested group' do
      let_it_be(:subgroup) { create(:group, parent: group) }

      before do
        allow(current_user).to receive(:default_duo_namespace).and_return(subgroup)
        allow(group).to receive_messages(
          duo_foundational_flows_enabled: true,
          enabled_flow_catalog_item_ids: [catalog_item.id]
        )
      end

      it 'resolves to the root ancestor namespace' do
        expect(Ai::Messaging::WorkspaceProjectService).to receive(:new)
          .with(hash_including(namespace: group))
          .and_return(instance_double(Ai::Messaging::WorkspaceProjectService,
            execute: ServiceResponse.error(message: 'stop here')))

        result
      end
    end

    context 'when workflow definition has no catalog item' do
      before do
        allow(Ai::Catalog::FoundationalFlow).to receive(:[]).with('developer/v1').and_return(nil)
      end

      it 'returns flow_not_enabled error', :aggregate_failures do
        expect(result).to be_error
        expect(result.reason).to eq(:flow_not_enabled)
      end
    end

    context 'when developer/v1 flow is not enabled for namespace' do
      before do
        allow(group).to receive(:duo_foundational_flows_enabled).and_return(false)
      end

      it 'returns flow_not_enabled error', :aggregate_failures do
        expect(result).to be_error
        expect(result.reason).to eq(:flow_not_enabled)
        expect(result.message).to include('developer/v1 flow is not enabled')
      end
    end

    context 'when developer/v1 flow is enabled' do
      let(:workflow) do
        build(:duo_workflows_workflow, user: current_user, project: project,
          service_account: service_account, messaging_callback_context: callback_context)
      end

      before do
        allow(group).to receive_messages(
          duo_foundational_flows_enabled: true,
          enabled_flow_catalog_item_ids: [catalog_item.id]
        )
      end

      context 'when workspace project creation fails' do
        before do
          allow_next_instance_of(Ai::Messaging::WorkspaceProjectService) do |svc|
            allow(svc).to receive(:execute)
              .and_return(ServiceResponse.error(message: 'Permission denied'))
          end
        end

        it 'returns the workspace project error', :aggregate_failures do
          expect(result).to be_error
          expect(result.message).to include('Permission denied')
        end
      end

      context 'when service account cannot be resolved' do
        before do
          allow_next_instance_of(Ai::Messaging::WorkspaceProjectService) do |svc|
            allow(svc).to receive(:execute)
              .and_return(ServiceResponse.success(payload: { project: project }))
          end
          allow_next_instance_of(Ai::Catalog::ItemConsumers::ResolveServiceAccountService) do |svc|
            allow(svc).to receive(:execute)
              .and_return(ServiceResponse.error(message: 'No item consumer found'))
          end
        end

        it 'returns service_account_error', :aggregate_failures do
          expect(result).to be_error
          expect(result.reason).to eq(:service_account_error)
        end
      end

      context 'when workflow definition has no catalog item for service account resolution' do
        before do
          allow_next_instance_of(Ai::Messaging::WorkspaceProjectService) do |svc|
            allow(svc).to receive(:execute)
              .and_return(ServiceResponse.success(payload: { project: project }))
          end
        end

        it 'returns nil' do
          flow_definition = instance_double(Ai::Catalog::FoundationalFlow, catalog_item: nil)
          allow(service).to receive(:workflow_definition).and_return(flow_definition)

          expect(service.send(:resolve_service_account, group)).to be_nil
        end
      end

      context 'when service account access grant fails' do
        before do
          allow_next_instance_of(Ai::Messaging::WorkspaceProjectService) do |svc|
            allow(svc).to receive(:execute)
              .and_return(ServiceResponse.success(payload: { project: project }))
          end
          allow_next_instance_of(Ai::Catalog::ItemConsumers::ResolveServiceAccountService) do |svc|
            allow(svc).to receive(:execute)
              .and_return(ServiceResponse.success(payload: { service_account: service_account }))
          end
          allow_next_instance_of(Ai::ServiceAccountMemberAddService) do |svc|
            allow(svc).to receive(:execute)
              .and_return(ServiceResponse.error(message: 'Failed to add'))
          end
        end

        it 'returns service_account_error', :aggregate_failures do
          expect(result).to be_error
          expect(result.reason).to eq(:service_account_error)
          expect(result.message).to include('Could not grant service account access')
        end
      end

      context 'when all dependencies resolve successfully' do
        let(:execute_workflow_result) do
          ServiceResponse.success(payload: { workflow: workflow, workload_id: 42, flow_config: nil })
        end

        before do
          allow_next_instance_of(Ai::Messaging::WorkspaceProjectService) do |svc|
            allow(svc).to receive(:execute)
              .and_return(ServiceResponse.success(payload: { project: project }))
          end

          allow_next_instance_of(Ai::Catalog::ItemConsumers::ResolveServiceAccountService) do |svc|
            allow(svc).to receive(:execute)
              .and_return(ServiceResponse.success(payload: { service_account: service_account }))
          end

          allow_next_instance_of(Ai::ServiceAccountMemberAddService) do |svc|
            allow(svc).to receive(:execute).and_return(ServiceResponse.success)
          end

          allow_next_instance_of(Ai::Catalog::ExecuteWorkflowService) do |svc|
            allow(svc).to receive(:execute).and_return(execute_workflow_result)
          end
        end

        context 'when ExecuteWorkflowService fails' do
          let(:execute_workflow_result) do
            ServiceResponse.error(message: 'Quota exceeded')
          end

          it 'returns execute_workflow_failed error', :aggregate_failures do
            expect(result).to be_error
            expect(result.reason).to eq(:execute_workflow_failed)
            expect(result.message).to include('Quota exceeded')
          end
        end

        context 'when everything succeeds' do
          before do
            workflow.save!
          end

          it 'returns success with workflow and workload_id', :aggregate_failures do
            expect(result).to be_success
            expect(result.payload[:workflow]).to eq(workflow)
            expect(result.payload[:workload_id]).to eq(42)
          end

          it 'delegates to ExecuteWorkflowService with correct params' do
            expect(Ai::Catalog::ExecuteWorkflowService).to receive(:new).with(
              current_user,
              hash_including(
                container: project,
                goal: goal,
                service_account: service_account,
                flow_definition: 'developer/v1',
                source_branch: project.default_branch_or_main,
                messaging_callback_context: callback_context
              )
            ).and_return(instance_double(
              Ai::Catalog::ExecuteWorkflowService,
              execute: execute_workflow_result
            ))

            result
          end
        end
      end
    end
  end
end
