# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WorkItems::Decisions::ResolveService, feature_category: :team_planning do
  let_it_be(:project) { create(:project) }
  let_it_be(:reporter) { create(:user, reporter_of: project) }
  let_it_be(:guest) { create(:user, guest_of: project) }
  let_it_be(:work_item) { create(:work_item, project: project) }
  let_it_be(:note) { create(:note, noteable: work_item, project: project) }

  let_it_be_with_reload(:decision) { create(:work_item_decision, work_item: work_item) }
  let_it_be_with_reload(:option) { create(:work_item_decision_option, decision: decision) }

  let(:current_user) { reporter }
  let(:params) do
    {
      resolution_rationale: 'Chosen for consistency',
      selected_option_ids: [option.id],
      resolving_note: note
    }
  end

  subject(:response) do
    described_class.new(decision: decision, current_user: current_user, params: params).execute
  end

  before do
    stub_licensed_features(ai_workflows: true)
  end

  it 'resolves the decision and selects the options' do
    expect(response).to be_success

    expect(decision.reload).to have_attributes(
      resolution_rationale: 'Chosen for consistency',
      resolved_by: current_user,
      resolving_note: note
    )
    expect(decision.resolved_at).to be_present
    expect(option.reload.selected).to be(true)
  end

  context 'when resolving without any selected option (rejecting all options)' do
    let(:params) { { resolution_rationale: 'None of these work' } }

    it 'resolves the decision and selects nothing' do
      expect(response).to be_success
      expect(decision.reload.resolved_at).to be_present
      expect(option.reload.selected).to be(false)
    end

    context 'without a resolution rationale' do
      let(:params) { {} }

      it 'returns an error and does not resolve the decision' do
        expect(response).to be_error
        expect(response.errors).to include('Resolution rationale is required when rejecting all options')
        expect(decision.reload.resolved_at).to be_nil
      end
    end
  end

  context 'when the decision has no options' do
    let(:decision) { create(:work_item_decision, work_item: work_item) }
    let(:params) { {} }

    it 'resolves without a rationale' do
      expect(response).to be_success
      expect(decision.reload.resolved_at).to be_present
    end
  end

  context 'when resolving with selected option content' do
    let(:params) { { selected_option_content: 'Use SQLite' } }

    it 'resolves the decision with the content as the only selected option' do
      expect { response }.to change { decision.options.count }.by(1)

      expect(response).to be_success
      expect(decision.reload).to have_attributes(resolved_by: current_user, resolution_rationale: nil)
      expect(decision.resolved_at).to be_present
      expect(decision.options.map { |option| option.slice(:content, :selected) }).to match_array([
        { 'content' => 'Use PostgreSQL', 'selected' => false },
        { 'content' => 'Use SQLite', 'selected' => true }
      ])
    end

    it 'returns the decision with its current options' do
      expect(response.payload[:decision].options.map(&:content)).to contain_exactly('Use PostgreSQL', 'Use SQLite')
    end

    context 'with a resolution rationale' do
      let(:params) { super().merge(resolution_rationale: 'Simpler for the prototype') }

      it 'persists the rationale' do
        expect(response).to be_success
        expect(decision.reload.resolution_rationale).to eq('Simpler for the prototype')
      end
    end

    context 'when the decision has no options' do
      let(:decision) { create(:work_item_decision, work_item: work_item) }

      it 'resolves the decision with the content as its only option' do
        expect { response }.to change { decision.options.count }.from(0).to(1)

        expect(response).to be_success
        expect(decision.reload.resolved_at).to be_present
        expect(decision.options.first).to have_attributes(content: 'Use SQLite', selected: true)
      end
    end

    context 'when selected options are provided as well' do
      let(:params) { super().merge(selected_option_ids: [option.id]) }

      it 'returns an error and does not resolve the decision' do
        expect { response }.not_to change { decision.options.count }

        expect(response).to be_error
        expect(response.errors).to include('Selected options and selected option content cannot be provided together')
        expect(decision.reload.resolved_at).to be_nil
        expect(option.reload.selected).to be(false)
      end
    end

    context 'when the decision is at the options limit' do
      before do
        stub_const('WorkItems::Decision::MAX_OPTIONS_PER_DECISION', 1)
        stub_const('WorkItems::Decision::MAX_OPTIONS_WITH_WRITE_IN', 2)
      end

      it 'adds the option past the limit' do
        expect { response }.to change { decision.options.count }.from(1).to(2)

        expect(response).to be_success
      end
    end

    context 'when the content is too long' do
      let(:params) { { selected_option_content: 'a' * (WorkItems::DecisionOption::CONTENT_LENGTH_MAX + 1) } }

      it 'returns the model error and does not resolve the decision' do
        expect { response }.not_to change { decision.reload.resolved_at }.from(nil)

        expect(response).to be_error
        expect(response.errors).to include(
          "Content is too long (maximum is #{WorkItems::DecisionOption::CONTENT_LENGTH_MAX} characters)"
        )
      end
    end

    context 'when the content is blank' do
      let(:params) { { selected_option_content: ' ' } }

      it 'returns an error and does not resolve the decision' do
        expect { response }.not_to change { decision.reload.resolved_at }.from(nil)

        expect(response).to be_error
        expect(response.errors).to include("Selected option content can't be blank")
      end
    end
  end

  context 'when the decision is already resolved' do
    before do
      decision.update!(resolved_at: Time.current, resolved_by: reporter)
    end

    it 'returns an error' do
      expect(response).to be_error
      expect(response.errors).to include('Decision is already resolved')
    end
  end

  context 'when the note belongs to another noteable' do
    let_it_be(:other_note) { create(:note) }

    let(:params) { { resolving_note: other_note } }

    it 'returns an error' do
      expect(response).to be_error
      expect(response.errors).to include('Note cannot resolve this decision')
    end
  end

  context 'when the note is a system note' do
    let_it_be(:system_note) { create(:note, :system, noteable: work_item, project: project) }

    let(:params) { { resolving_note: system_note } }

    it 'returns an error' do
      expect(response).to be_error
      expect(response.errors).to include('Note cannot resolve this decision')
    end
  end

  context 'when the user cannot read the note' do
    let_it_be(:authored_work_item) { create(:work_item, project: project, author: guest) }
    let_it_be(:internal_note) { create(:note, :confidential, noteable: authored_work_item, project: project) }
    let_it_be_with_reload(:decision) { create(:work_item_decision, work_item: authored_work_item) }

    let(:current_user) { guest }
    let(:params) { { resolving_note: internal_note } }

    it 'returns an error and does not resolve the decision' do
      expect { response }.not_to change { decision.reload.resolved_at }.from(nil)

      expect(response).to be_error
      expect(response.errors).to include('Note cannot resolve this decision')
    end
  end

  context 'when a selected option belongs to another decision' do
    let_it_be(:other_option) { create(:work_item_decision_option) }

    let(:params) { { selected_option_ids: [other_option.id] } }

    it 'returns an error' do
      expect(response).to be_error
      expect(response.errors).to include('Selected options must belong to the decision')
    end
  end

  context 'when user cannot update the work item' do
    let(:current_user) { guest }

    it 'returns an error' do
      expect(response).to be_error
      expect(response.errors).to include('Operation not allowed')
    end
  end

  context 'when ai_workflows is not licensed' do
    before do
      stub_licensed_features(ai_workflows: false)
    end

    it 'returns an error' do
      expect(response).to be_error
      expect(response.errors).to include('Operation not allowed')
    end
  end

  context 'when the work item type does not have the widget' do
    let_it_be(:incident_work_item) { create(:work_item, :incident, project: project) }

    let(:decision) { create(:work_item_decision, work_item: incident_work_item) }

    it 'returns an error' do
      expect(response).to be_error
      expect(response.errors).to include('Operation not allowed')
    end
  end

  context 'when decision_log is disabled' do
    before do
      stub_feature_flags(decision_log: false)
    end

    it 'returns an error' do
      expect(response).to be_error
      expect(response.errors).to include('Operation not allowed')
    end
  end
end
