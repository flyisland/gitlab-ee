# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WorkItems::Callbacks::AgentPlan, feature_category: :team_planning do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, reporters: user) }
  let_it_be_with_reload(:work_item) { create(:work_item, project: project, author: user) }

  let(:current_user) { user }
  let(:params) { {} }
  let(:callback) { described_class.new(issuable: work_item, current_user: current_user, params: params) }

  shared_examples 'agent plan is unchanged' do
    it 'does not change agent plan' do
      expect { subject }.not_to change { work_item.reload.agent_plan&.content }
    end
  end

  describe '#before_create' do
    subject(:before_create_callback) { callback.before_create }

    context 'when content param is present' do
      let(:params) { { content: 'New plan content' } }

      it 'builds an agent plan' do
        before_create_callback

        expect(work_item.agent_plan).to be_present
        expect(work_item.agent_plan.content).to eq('New plan content')
        expect(work_item.agent_plan.namespace).to eq(work_item.namespace)
      end

      context 'when widget does not exist in type' do
        before do
          allow(callback).to receive(:excluded_in_new_type?).and_return(true)
        end

        it 'does not build an agent plan' do
          before_create_callback

          expect(work_item.agent_plan).to be_nil
        end
      end
    end

    context 'when content param is not present' do
      let(:params) { {} }

      it_behaves_like 'agent plan is unchanged'
    end

    context 'when user does not have permission' do
      let_it_be(:guest) { create(:user) }

      let(:current_user) { guest }
      let(:params) { { content: 'New plan content' } }

      it_behaves_like 'agent plan is unchanged'
    end
  end

  describe '#before_update' do
    subject(:before_update_callback) { callback.before_update }

    let_it_be(:agent_plan) { create(:work_item_agent_plan, work_item: work_item, content: 'Original content') }

    context 'when content param is present' do
      let(:params) { { content: 'Updated content' } }

      it 'updates the agent plan content' do
        before_update_callback

        expect(work_item.agent_plan.content).to eq('Updated content')
      end
    end

    context 'when content param is not present' do
      let(:params) { {} }

      it 'does not change agent plan content' do
        before_update_callback

        expect(work_item.agent_plan.content).to eq('Original content')
      end

      context 'when widget does not exist in type' do
        before do
          allow(callback).to receive(:excluded_in_new_type?).and_return(true)
        end

        it 'destroys the existing agent plan' do
          before_update_callback

          expect(work_item.reload.agent_plan).to be_nil
        end
      end
    end

    context 'when content exceeds maximum length' do
      let(:params) { { content: 'x' * (WorkItems::AgentPlan::CONTENT_LENGTH_MAX + 1) } }

      it 'raises a callback error' do
        expect { before_update_callback }.to raise_error(
          ::Issuable::Callbacks::Base::Error, /is too long/
        )
      end
    end

    context 'when user does not have permission' do
      let_it_be(:guest) { create(:user) }

      let(:current_user) { guest }
      let(:params) { { content: 'Updated content' } }

      it_behaves_like 'agent plan is unchanged'
    end
  end
end
