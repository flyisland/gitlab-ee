# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WorkItems::Decision, feature_category: :team_planning do
  describe 'associations' do
    it { is_expected.to belong_to(:work_item).inverse_of(:decisions) }
    it { is_expected.to belong_to(:namespace) }
    it { is_expected.to belong_to(:author).class_name('User') }
    it { is_expected.to belong_to(:resolved_by).class_name('User').optional }
    it { is_expected.to belong_to(:resolving_note).class_name('Note').optional }
    it { is_expected.to belong_to(:workflow).class_name('Ai::DuoWorkflows::Workflow').optional }

    it 'has many options' do
      is_expected.to have_many(:options)
        .class_name('WorkItems::DecisionOption')
        .with_foreign_key(:work_item_decision_id)
        .inverse_of(:decision)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:work_item) }
    it { is_expected.to validate_presence_of(:namespace) }
    it { is_expected.to validate_presence_of(:author).on(:create) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(described_class::TITLE_LENGTH_MAX) }

    context 'when created as resolved without a title' do
      subject { build(:work_item_decision, :resolved, title: nil) }

      it { is_expected.to be_valid }
    end

    context 'when created as open without a title' do
      subject { build(:work_item_decision, title: nil) }

      it { is_expected.not_to be_valid }
    end

    it 'prevents blanking the title of an open decision on update' do
      decision = create(:work_item_decision)
      decision.title = nil

      expect(decision).not_to be_valid
    end

    it { is_expected.to validate_length_of(:description).is_at_most(described_class::DESCRIPTION_LENGTH_MAX) }

    it 'validates the length of resolution_rationale' do
      is_expected.to validate_length_of(:resolution_rationale)
        .is_at_most(described_class::RESOLUTION_RATIONALE_LENGTH_MAX)
    end

    describe 'source_link' do
      it { is_expected.to validate_length_of(:source_link).is_at_most(described_class::SOURCE_LINK_LENGTH_MAX) }
      it { is_expected.to allow_value(nil).for(:source_link) }
      it { is_expected.to allow_value('https://docs.google.com/document/d/abc123').for(:source_link) }
      it { is_expected.not_to allow_value('not a url').for(:source_link) }
      it { is_expected.not_to allow_value('javascript:alert(1)').for(:source_link) }
    end

    describe 'discussion_id format' do
      it { is_expected.to allow_value(nil).for(:discussion_id) }
      it { is_expected.to allow_value(SecureRandom.hex(20)).for(:discussion_id) }
      it { is_expected.not_to allow_value(SecureRandom.hex(19)).for(:discussion_id) }
      it { is_expected.not_to allow_value(SecureRandom.hex(21)).for(:discussion_id) }
      it { is_expected.not_to allow_value("g#{SecureRandom.hex(20)[1..]}").for(:discussion_id) }
    end

    describe 'resolved_by' do
      it 'is required when resolved_at is set' do
        decision = build(:work_item_decision, resolved_at: Time.current, resolved_by: nil)

        expect(decision).not_to be_valid
        expect(decision.errors[:resolved_by]).to include("can't be blank")
      end

      it 'allows updates after the resolver user was deleted' do
        decision = create(:work_item_decision, :resolved)
        decision.update_column(:resolved_by_id, nil)

        expect(decision.reload.update(title: 'Updated title')).to be(true)
      end

      it 'is not required when resolved_at is nil' do
        decision = build(:work_item_decision, resolved_at: nil, resolved_by: nil)

        expect(decision).to be_valid
      end
    end
  end

  describe '#set_namespace' do
    it 'copies the namespace from the work item' do
      work_item = create(:work_item)
      decision = build(:work_item_decision, work_item: work_item, namespace: nil)

      expect(decision).to be_valid
      expect(decision.namespace).to eq(work_item.namespace)
    end
  end

  describe 'factory' do
    it 'is valid' do
      expect(build(:work_item_decision)).to be_valid
    end

    it 'is valid with the :resolved trait' do
      expect(build(:work_item_decision, :resolved)).to be_valid
    end
  end
end
