# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WorkItems::Decisions::UpdateService, feature_category: :team_planning do
  let_it_be(:project) { create(:project) }
  let_it_be(:reporter) { create(:user, reporter_of: project) }
  let_it_be(:guest) { create(:user, guest_of: project) }
  let_it_be(:work_item) { create(:work_item, project: project) }

  let_it_be(:original_discussion_id) { SecureRandom.hex(20) }
  let_it_be_with_reload(:decision) do
    create(
      :work_item_decision,
      work_item: work_item,
      description: 'Original context',
      resolution_rationale: 'Original rationale',
      discussion_id: original_discussion_id,
      source_link: 'https://example.com/original'
    )
  end

  let(:current_user) { reporter }
  let(:discussion_id) { SecureRandom.hex(20) }
  let(:params) do
    {
      title: 'Which cache should we use?',
      description: 'The current cache is slow',
      resolution_rationale: 'Redis is already in the stack',
      discussion_id: discussion_id,
      source_link: 'https://docs.google.com/document/d/abc123'
    }
  end

  subject(:response) do
    described_class.new(decision: decision, current_user: current_user, params: params).execute
  end

  before do
    stub_licensed_features(ai_workflows: true)
  end

  it 'updates the decision' do
    expect(response).to be_success

    expect(decision.reload).to have_attributes(
      title: 'Which cache should we use?',
      description: 'The current cache is slow',
      resolution_rationale: 'Redis is already in the stack',
      discussion_id: discussion_id,
      source_link: 'https://docs.google.com/document/d/abc123'
    )
  end

  context 'when the decision is resolved' do
    let_it_be_with_reload(:decision) { create(:work_item_decision, :resolved, work_item: work_item) }

    it 'updates the decision without touching the resolution' do
      expect { response }.not_to change { decision.reload.slice(:resolved_at, :resolved_by_id) }

      expect(response).to be_success
      expect(decision).to have_attributes(
        title: 'Which cache should we use?',
        resolution_rationale: 'Redis is already in the stack'
      )
    end
  end

  context 'when only some attributes are provided' do
    let(:params) { { title: 'Which cache should we use?' } }

    it 'leaves the other attributes untouched' do
      expect(response).to be_success

      expect(decision.reload).to have_attributes(
        title: 'Which cache should we use?',
        description: 'Original context',
        resolution_rationale: 'Original rationale',
        discussion_id: original_discussion_id,
        source_link: 'https://example.com/original'
      )
    end
  end

  context 'when params include attributes outside the allowlist' do
    let(:params) { { title: 'Which cache should we use?', resolved_at: Time.current } }

    it 'applies the allowed attributes and never writes the others' do
      expect { response }.not_to change { decision.reload.resolved_at }.from(nil)

      expect(response).to be_success
      expect(decision).to have_attributes(
        title: 'Which cache should we use?',
        description: 'Original context'
      )
    end
  end

  context 'when no updatable attribute is provided' do
    using RSpec::Parameterized::TableSyntax

    where(:params) do
      [
        [{}],
        [{ resolved_at: Time.current }]
      ]
    end

    with_them do
      it 'returns an error without writing to the decision' do
        expect { response }.not_to change { decision.reload.updated_at }

        expect(response).to be_error
        expect(response.errors).to include('No attributes to update')
      end
    end
  end

  context 'when a provided attribute is blank' do
    using RSpec::Parameterized::TableSyntax

    where(:attribute, :value) do
      :title                | nil
      :title                | ''
      :title                | '   '
      :description          | nil
      :description          | ''
      :resolution_rationale | "\n"
      :discussion_id        | nil
      :source_link          | ''
    end

    with_them do
      let(:params) { { attribute => value } }

      it 'returns an error and does not update the decision' do
        expect(response).to be_error
        expect(response.errors).to include("#{attribute.to_s.humanize} can't be blank")
        expect(decision.reload).to have_attributes(title: 'Which storage backend should we use?')
      end
    end
  end

  context 'when several provided attributes are blank' do
    let(:params) { { title: '', description: nil } }

    it 'names every blank attribute' do
      expect(response).to be_error
      expect(response.errors).to include("Title and Description can't be blank")
    end
  end

  context 'when the source link is not a valid URL' do
    let(:params) { { source_link: 'not a url' } }

    it 'returns the model error and does not update the decision' do
      expect(response).to be_error
      expect(response.errors).to include('Source link is blocked: Only allowed schemes are http, https')
      expect(decision.reload.source_link).to eq('https://example.com/original')
    end
  end

  context 'when the title is too long' do
    let(:params) { { title: 'a' * (WorkItems::Decision::TITLE_LENGTH_MAX + 1) } }

    it 'returns the model error' do
      expect(response).to be_error
      expect(response.errors).to include(
        "Title is too long (maximum is #{WorkItems::Decision::TITLE_LENGTH_MAX} characters)"
      )
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
