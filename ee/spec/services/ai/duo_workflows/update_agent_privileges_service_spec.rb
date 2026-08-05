# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Ai::DuoWorkflows::UpdateAgentPrivilegesService, feature_category: :duo_agent_platform do
  describe '#execute' do
    subject(:result) do
      described_class.new(
        workflow: workflow,
        agent_privileges: agent_privileges,
        pre_approved_agent_privileges: pre_approved_agent_privileges,
        current_user: user
      ).execute
    end

    let_it_be(:project) { create(:project) }
    let_it_be(:user) { create(:user, maintainer_of: project) }

    let(:workflow) { create(:duo_workflows_workflow, project: project, user: user) }
    let(:agent_privileges) { nil }
    let(:pre_approved_agent_privileges) { nil }

    context 'when user does not have permission to update workflow' do
      before do
        allow(user).to receive(:can?).with(:update_duo_workflow, workflow).and_return(false)
      end

      it 'returns unauthorized error', :aggregate_failures do
        expect(result.error?).to be true
        expect(result.message).to eq('Can not update workflow')
        expect(result.reason).to eq(:unauthorized)
      end
    end

    context 'when user has permission to update workflow' do
      before do
        allow(user).to receive(:can?).with(:update_duo_workflow, workflow).and_return(true)
      end

      context 'when agent_privileges is provided' do
        let(:agent_privileges) { [1, 2] }

        it 'updates agent_privileges and returns success', :aggregate_failures do
          expect(result.success?).to be true
          expect(result.message).to eq('Agent privileges updated successfully')
          expect(result.payload[:workflow]).to eq(workflow)
          expect(workflow.reload.agent_privileges).to eq(agent_privileges)
        end
      end

      context 'when pre_approved_agent_privileges is provided' do
        let(:agent_privileges) { [1, 2] }
        let(:pre_approved_agent_privileges) { [1] }

        it 'updates pre_approved_agent_privileges and returns success', :aggregate_failures do
          expect(result.success?).to be true
          expect(result.message).to eq('Agent privileges updated successfully')
          expect(workflow.reload.pre_approved_agent_privileges).to eq(pre_approved_agent_privileges)
        end
      end

      context 'when neither agent_privileges nor pre_approved_agent_privileges is provided' do
        it 'saves the workflow without changes and returns success', :aggregate_failures do
          expect(result.success?).to be true
          expect(result.message).to eq('Agent privileges updated successfully')
        end
      end

      context 'when agent_privileges contains an invalid value' do
        let(:agent_privileges) { [999] }

        it 'returns an error with validation messages', :aggregate_failures do
          expect(result.error?).to be true
          expect(result.message).to include('Failed to update agent privileges')
          expect(result.message).to include('contains an invalid value 999')
        end
      end

      context 'when pre_approved_agent_privileges contains an invalid value' do
        let(:pre_approved_agent_privileges) { [999] }

        it 'returns an error with validation messages', :aggregate_failures do
          expect(result.error?).to be true
          expect(result.message).to include('Failed to update agent privileges')
          expect(result.message).to include('contains an invalid value 999')
        end
      end
    end
  end
end
