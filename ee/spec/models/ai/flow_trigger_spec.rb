# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::FlowTrigger, feature_category: :duo_agent_platform do
  let_it_be(:project) { create(:project, :in_group) }
  let_it_be(:user) { create(:service_account) }

  subject(:flow_trigger) { build(:ai_flow_trigger, project: project) }

  # We will allow nil user when we fully support accessing service accounts through the item consumer
  # Until then, we must skip the validations, and manually save the associations
  def save_trigger_and_associations(trigger)
    trigger.ai_catalog_item_consumer.parent_item_consumer.service_account.save!
    trigger.ai_catalog_item_consumer.parent_item_consumer.save!
    trigger.ai_catalog_item_consumer.save!(validate: false)
    trigger.save!(validate: false)
  end

  describe 'associations' do
    it { is_expected.to belong_to(:project).required }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:ai_catalog_item_consumer).class_name('Ai::Catalog::ItemConsumer').optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:event_types) }
    it { is_expected.to validate_presence_of(:description) }

    it { is_expected.to validate_length_of(:description).is_at_most(255) }
    it { is_expected.to validate_length_of(:config_path).is_at_most(255) }

    describe 'filter' do
      it 'validates json_schema when filter changes' do
        flow_trigger.filter = { 'pipeline_hooks' => { 'unexpected' => true } }

        expect(flow_trigger).not_to be_valid
        expect(flow_trigger.errors[:filter]).to be_present
      end

      it 'validates size limit when filter changes' do
        flow_trigger.filter = {
          'pipeline_hooks' => { 'rules' => [{ 'field' => 'a', 'operator' => 'eq', 'value' => 'b' * 9000 }] }
        }

        expect(flow_trigger).not_to be_valid
        expect(flow_trigger.errors[:filter]).to be_present
      end
    end

    describe 'event_types_are_valid' do
      it 'rejects empty event_types array' do
        flow_trigger = build(:ai_flow_trigger, project: project, event_types: [])

        expect(flow_trigger).not_to be_valid
        expect(flow_trigger.errors[:event_types]).to include("can't be blank")
      end

      it 'rejects nil event_types' do
        flow_trigger = build(:ai_flow_trigger, project: project, event_types: nil)

        expect(flow_trigger).not_to be_valid
        expect(flow_trigger.errors[:event_types]).to include("can't be blank")
      end

      it 'allows valid event_types array' do
        flow_trigger = build(:ai_flow_trigger, project: project, event_types: [0])

        expect(flow_trigger).to be_valid
      end
    end

    describe 'user_is_service_account' do
      it 'rejects regular user' do
        regular_user = create(:user)
        flow_trigger = build(:ai_flow_trigger, project: project, user: regular_user)

        expect(flow_trigger).not_to be_valid
        expect(flow_trigger.errors[:user]).to include('user must be a service account')
      end
    end

    describe 'exactly_one_config_source' do
      let_it_be(:item_consumer) do
        create(:ai_catalog_item_consumer, :child_item_consumer, project: project, item: create(:ai_catalog_flow))
      end

      context 'when using config_path only' do
        it 'is valid' do
          flow_trigger = build(:ai_flow_trigger, project: project, config_path: 'path/to/config.yml')

          expect(flow_trigger).to be_valid
        end
      end

      context 'when using ai_catalog_item_consumer only' do
        it 'is valid' do
          flow_trigger =
            build(:ai_flow_trigger, project: project, ai_catalog_item_consumer: item_consumer, config_path: nil)

          expect(flow_trigger).to be_valid
        end
      end

      context 'when using both config_path and ai_catalog_item_consumer' do
        it 'is invalid' do
          error_message = 'Exactly one of config_path, ai_catalog_item_consumer must be present'
          flow_trigger = build(:ai_flow_trigger,
            project: project,
            config_path: 'path/to/config.yml',
            ai_catalog_item_consumer: item_consumer)

          expect(flow_trigger).not_to be_valid
          expect(flow_trigger.errors[:base]).to include(error_message)
        end
      end

      context 'when using neither config_path nor ai_catalog_item_consumer' do
        it 'is invalid' do
          error_message = 'Exactly one of config_path, ai_catalog_item_consumer must be present'
          flow_trigger = build(:ai_flow_trigger, config_path: nil)

          expect(flow_trigger).not_to be_valid
          expect(flow_trigger.errors[:base]).to include(error_message)
        end
      end
    end

    describe 'supported_events_match_foundational_flow' do
      let(:item) { create(:ai_catalog_flow, foundational_flow_reference: 'fix_pipeline/v1') }
      let(:item_consumer) { create(:ai_catalog_item_consumer, :child_item_consumer, project: project, item: item) }

      context 'when event types and filter keys match supported events' do
        it 'is valid' do
          flow_trigger = build(:ai_flow_trigger,
            project: project,
            config_path: nil,
            ai_catalog_item_consumer: item_consumer,
            event_types: [::Ai::FlowTrigger::EVENT_TYPES[:pipeline_hooks]],
            filter: { 'pipeline_hooks' => { 'match' => 'all', 'rules' => [] } })

          expect(flow_trigger).to be_valid
        end
      end

      context 'when event types are not supported by the foundational flow' do
        it 'is invalid' do
          flow_trigger = build(:ai_flow_trigger,
            project: project,
            config_path: nil,
            ai_catalog_item_consumer: item_consumer,
            event_types: [::Ai::FlowTrigger::EVENT_TYPES[:mention]])

          expect(flow_trigger).not_to be_valid
          expect(flow_trigger.errors[:event_types]).to include(
            'contains event types not supported by this foundational flow'
          )
        end
      end

      context 'when filter contains unsupported event type keys' do
        it 'is invalid' do
          flow_trigger = build(:ai_flow_trigger,
            project: project,
            config_path: nil,
            ai_catalog_item_consumer: item_consumer,
            event_types: [::Ai::FlowTrigger::EVENT_TYPES[:pipeline_hooks]],
            filter: { 'mention' => { 'match' => 'all', 'rules' => [] } })

          expect(flow_trigger).not_to be_valid
          expect(flow_trigger.errors[:filter]).to include(
            'contains filters for unsupported event types: mention'
          )
        end
      end

      context 'when the foundational flow has no supported_events' do
        let(:item) { create(:ai_catalog_flow, foundational_flow_reference: 'code_review/v1') }

        it 'allows any event types and filter keys' do
          flow_trigger = build(:ai_flow_trigger,
            project: project,
            config_path: nil,
            ai_catalog_item_consumer: item_consumer,
            event_types: [::Ai::FlowTrigger::EVENT_TYPES[:mention]],
            filter: { 'mention' => { 'match' => 'all', 'rules' => [] } })

          expect(flow_trigger).to be_valid
        end
      end

      context 'when the foundational flow reference does not match a defined flow' do
        let(:item) { create(:ai_catalog_flow, foundational_flow_reference: 'unknown/v1') }

        it 'allows any event types' do
          flow_trigger = build(:ai_flow_trigger,
            project: project,
            config_path: nil,
            ai_catalog_item_consumer: item_consumer,
            event_types: [::Ai::FlowTrigger::EVENT_TYPES[:mention]])

          expect(flow_trigger).to be_valid
        end
      end

      context 'when the item is not a foundational flow' do
        let(:item) { create(:ai_catalog_flow) }

        it 'allows any event types and filter keys' do
          flow_trigger = build(:ai_flow_trigger,
            project: project,
            config_path: nil,
            ai_catalog_item_consumer: item_consumer,
            event_types: [::Ai::FlowTrigger::EVENT_TYPES[:mention]])

          expect(flow_trigger).to be_valid
        end
      end
    end

    describe 'catalog_item_valid' do
      let(:item_consumer) { create(:ai_catalog_item_consumer, project: project, item: item) }

      let(:item) { create(:ai_catalog_flow) }

      context 'when item consumer project does not match the project' do
        let(:project) { create(:project) }

        it 'is invalid' do
          error_message = 'Exactly one of config_path, ai_catalog_item_consumer must be present'
          flow_trigger = build(:ai_flow_trigger, project: project, ai_catalog_item_consumer: item_consumer)

          expect(flow_trigger).not_to be_valid
          expect(flow_trigger.errors[:base]).to include(error_message)
        end
      end

      context 'when item is not a flow' do
        let(:item) { create(:ai_catalog_agent) }

        it 'is invalid' do
          flow_trigger = build(:ai_flow_trigger, project: project, ai_catalog_item_consumer: item_consumer)

          expect(flow_trigger).not_to be_valid
          expect(flow_trigger.errors[:base]).to include('ai_catalog_item_consumer is not a flow')
        end
      end
    end

    context 'when ai_catalog_item_consumer is present' do
      let_it_be(:ai_catalog_item_consumer) { create(:ai_catalog_item_consumer, :child_item_consumer, project: project) }

      subject(:flow_trigger) do
        build(:ai_flow_trigger, config_path: nil, project: project, ai_catalog_item_consumer: ai_catalog_item_consumer)
      end

      it { is_expected.to be_valid }

      context 'when ai_catalog_item_consumer does not have an active service account' do
        let_it_be(:ai_catalog_item_consumer) { create(:ai_catalog_item_consumer, project:) }

        it 'is invalid' do
          expect(flow_trigger).not_to be_valid
          expect(flow_trigger.errors[:ai_catalog_item_consumer_id]).to include('must have an active service account')
        end
      end
    end
  end

  describe 'database constraints' do
    it 'has correct table name' do
      expect(described_class.table_name).to eq('ai_flow_triggers')
    end

    context 'when using loose foreign key on users.id' do
      it_behaves_like 'cleanup by a loose foreign key' do
        let!(:model) { create(:ai_flow_trigger, project: project) }
        let!(:parent) { model.user }
      end
    end

    context 'when using loose foreign key on projects.id' do
      it_behaves_like 'cleanup by a loose foreign key' do
        let!(:model) { create(:ai_flow_trigger, project: project) }
        let!(:parent) { model.project }
      end
    end
  end

  describe 'factory' do
    it 'creates a valid flow trigger' do
      flow_trigger = build(:ai_flow_trigger,
        project: project,
        user: user,
        description: 'Test flow trigger',
        event_types: [0])

      expect(flow_trigger).to be_valid
    end

    it 'can be created and persisted' do
      expect do
        create(:ai_flow_trigger,
          project: project,
          user: user,
          description: 'Test flow trigger',
          event_types: [0])
      end.to change { described_class.count }.by(1)
    end
  end

  describe 'event_types_are_valid validation' do
    it 'allows multiple valid event types' do
      valid_types = Ai::FlowTrigger::EVENT_TYPES.values
      flow_trigger = build(:ai_flow_trigger, project: project, event_types: valid_types)

      expect(flow_trigger).to be_valid
    end

    it 'rejects invalid event types' do
      flow_trigger = build(:ai_flow_trigger, project: project, event_types: [99])

      expect(flow_trigger).not_to be_valid
      expect(flow_trigger.errors[:event_types]).to include('contains invalid event types: 99')
    end

    it 'rejects mixed valid and invalid event types' do
      flow_trigger = build(:ai_flow_trigger, project: project, event_types: [0, 99, 100])

      expect(flow_trigger).not_to be_valid
      expect(flow_trigger.errors[:event_types]).to include('contains invalid event types: 99, 100')
    end
  end

  describe 'timestamps' do
    it 'sets created_at and updated_at on creation' do
      flow_trigger = create(:ai_flow_trigger,
        project: project,
        user: user,
        description: 'Test flow trigger')

      expect(flow_trigger.created_at).to be_present
      expect(flow_trigger.updated_at).to be_present
    end

    it 'updates updated_at on modification' do
      flow_trigger = create(:ai_flow_trigger,
        project: project,
        user: user,
        description: 'Test flow trigger')

      original_updated_at = flow_trigger.updated_at

      travel_to(1.minute.from_now) do
        flow_trigger.update!(description: 'Updated description')

        expect(flow_trigger.updated_at).to be > original_updated_at
      end
    end
  end

  describe 'scopes' do
    describe 'with_ids' do
      it 'filters triggers by id' do
        triggers = create_list(:ai_flow_trigger, 3, project: project)

        expect(project.ai_flow_triggers.with_ids([triggers[0].id, triggers[1].id])).to contain_exactly(
          triggers[0], triggers[1]
        )
      end
    end

    describe '.by_item_consumer_ids' do
      let_it_be(:item_consumer1) { create(:ai_catalog_item_consumer, :child_item_consumer, :for_flow, project:) }
      let_it_be(:item_consumer2) { create(:ai_catalog_item_consumer, :child_item_consumer, :for_flow, project:) }
      let_it_be(:item_consumer3) { create(:ai_catalog_item_consumer, :child_item_consumer, :for_flow, project:) }

      let_it_be(:trigger1) do
        build(:ai_flow_trigger, :for_catalog_consumer, project: project, ai_catalog_item_consumer: item_consumer1)
          .tap { |trigger| save_trigger_and_associations(trigger) }
      end

      let_it_be(:trigger2) do
        build(:ai_flow_trigger, :for_catalog_consumer, project: project, ai_catalog_item_consumer: item_consumer2)
          .tap { |trigger| save_trigger_and_associations(trigger) }
      end

      let_it_be(:trigger3) do
        build(:ai_flow_trigger, :for_catalog_consumer, project: project, ai_catalog_item_consumer: item_consumer3)
          .tap { |trigger| save_trigger_and_associations(trigger) }
      end

      let_it_be(:trigger_not_for_consumer) do
        create(:ai_flow_trigger, project: project, ai_catalog_item_consumer: nil, config_path: 'bla')
      end

      it 'returns triggers filtered by item_consumer_ids' do
        expect(described_class.by_item_consumer_ids([item_consumer1.id, item_consumer2.id]))
          .to contain_exactly(trigger1, trigger2)

        expect(described_class.by_item_consumer_ids([item_consumer1.id])).to contain_exactly(trigger1)
        expect(described_class.by_item_consumer_ids([])).to be_empty
        expect(described_class.by_item_consumer_ids(nil)).to contain_exactly(trigger_not_for_consumer)
      end
    end

    describe '.by_service_accounts' do
      subject(:by_service_accounts) do
        described_class.by_service_accounts(
          [
            trigger_for_consumer_with_included_service_account.service_account,
            trigger_for_included_service_account.user
          ]
        )
      end

      let_it_be(:trigger_for_included_service_account) do
        create(:ai_flow_trigger, project: project)
      end

      let_it_be(:trigger_for_excluded_service_account) do
        create(:ai_flow_trigger, project: project)
      end

      let_it_be(:trigger_for_consumer_with_included_service_account) do
        build(:ai_flow_trigger, :for_catalog_consumer, project: project).tap do |trigger|
          save_trigger_and_associations(trigger)
        end
      end

      let_it_be(:trigger_for_consumer_with_excluded_service_account) do
        build(:ai_flow_trigger, :for_catalog_consumer, project: project).tap do |trigger|
          save_trigger_and_associations(trigger)
        end
      end

      it 'returns the triggers filtered by service_account' do
        expect(by_service_accounts).to contain_exactly(
          trigger_for_included_service_account, trigger_for_consumer_with_included_service_account
        )
      end

      it 'does not use a subquery' do
        expect(by_service_accounts.to_sql).not_to include('IN (SELECT "users"."id" FROM "users"')
      end

      context 'when querying for nil as well' do
        subject(:by_service_accounts) do
          described_class.by_service_accounts(
            [
              trigger_for_consumer_with_included_service_account.service_account,
              nil
            ]
          )
        end

        it 'filters out the nils' do
          expect(by_service_accounts).to contain_exactly(trigger_for_consumer_with_included_service_account)
        end
      end

      context 'when passing in a relation' do
        subject(:by_service_accounts) do
          described_class.by_service_accounts(
            User.where(id: [trigger_for_consumer_with_included_service_account.service_account.id])
          )
        end

        it 'uses a subquery to get the results' do
          expect(by_service_accounts.to_sql).to include('IN (SELECT "users"."id" FROM "users"')
          expect(by_service_accounts).to contain_exactly(trigger_for_consumer_with_included_service_account)
        end
      end
    end
  end

  describe '.triggered_on' do
    before do
      stub_const("#{described_class}::EVENT_TYPES", {
        mention: 0,
        comment: 1,
        issue_created: 2
      })
    end

    context 'when filtering by mention event type' do
      let!(:mention_trigger) do
        create(:ai_flow_trigger,
          project: project,
          user: user,
          event_types: [0],
          description: 'Mention trigger')
      end

      let!(:multiple_types_trigger) do
        create(:ai_flow_trigger,
          project: project,
          user: user,
          event_types: [0, 1],
          description: 'Multiple types trigger')
      end

      let!(:other_type_trigger) do
        create(:ai_flow_trigger,
          project: project,
          user: user,
          event_types: [1, 2],
          description: 'Other type trigger')
      end

      it 'returns triggers that contain the mention event type' do
        result = described_class.triggered_on(:mention)

        expect(result).to contain_exactly(mention_trigger, multiple_types_trigger)
      end

      it 'returns triggers that contain the comment event type' do
        result = described_class.triggered_on(:comment)

        expect(result).to contain_exactly(multiple_types_trigger, other_type_trigger)
      end
    end
  end

  describe '#service_account' do
    subject(:service_account) { flow_trigger.service_account }

    context 'when user is set' do
      let(:flow_trigger) { build(:ai_flow_trigger) }

      it { is_expected.to eq(flow_trigger.user).and(be_a_kind_of(User)) }
    end

    context 'when ai_catalog_item_consumer is set' do
      let(:flow_trigger) { build(:ai_flow_trigger, :for_catalog_consumer, project: project) }

      it { is_expected.to eq(flow_trigger.ai_catalog_item_consumer.active_service_account).and(be_a_kind_of(User)) }
    end

    context 'when ai_catalog_item_consumer has no parent_item_consumer' do
      let_it_be(:consumer_with_no_parent) do
        create(:ai_catalog_item_consumer, :for_flow, project: project, parent_item_consumer: nil)
      end

      let_it_be(:flow_trigger) do
        build(
          :ai_flow_trigger, :for_catalog_consumer,
          project: project, ai_catalog_item_consumer: consumer_with_no_parent
        )
      end

      it { is_expected.to be_nil }
    end
  end
end
