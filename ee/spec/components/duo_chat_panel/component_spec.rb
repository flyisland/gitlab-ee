# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DuoChatPanel::Component, :aggregate_failures, feature_category: :duo_chat do
  let(:user) { build_stubbed(:user) }
  let(:project) { nil }
  let(:group) { nil }
  let(:controller_name) { nil }

  let(:tanuki_bot_instance) { instance_double(::Gitlab::Llm::TanukiBot, show_duo_entry_point?: false) }
  let(:instance) do
    described_class.new(user: user, project: project, group: group, controller_name: controller_name)
  end

  before do
    allow(::Gitlab::Llm::TanukiBot).to receive(:new).with(user: user).and_return(tanuki_bot_instance)
    allow(::Gitlab::CurrentSettings).to receive(:duo_never_on?).and_return(false)
  end

  subject(:component_instance) { instance.send(:component_instance) }

  context 'when show_chat? is true' do
    before do
      allow(tanuki_bot_instance).to receive(:show_duo_entry_point?).and_return(true)
    end

    it 'returns a ChatComponent instance' do
      is_expected.to be_a(DuoChatPanel::ChatComponent)
    end
  end

  context 'when both show_chat? and show_empty_state? are true' do
    before do
      allow(tanuki_bot_instance).to receive(:show_duo_entry_point?).and_return(true)
    end

    it 'returns a ChatComponent, not an EmptyStateComponent' do
      is_expected.to be_a(DuoChatPanel::ChatComponent)
    end
  end

  context 'when show_trial_expired? is true' do
    let(:group) { build_stubbed(:group) }

    before do
      allow(group).to receive(:root_ancestor).and_return(group)
      allow(GitlabSubscriptions::Trials).to receive(:free_plan_expired?).with(group).and_return(true)
    end

    it 'returns a TrialExpiredComponent instance' do
      is_expected.to be_a(DuoChatPanel::TrialExpiredComponent)
    end
  end

  context 'when both show_chat? and show_trial_expired? are true' do
    let(:group) { build_stubbed(:group) }

    before do
      allow(tanuki_bot_instance).to receive(:show_duo_entry_point?).and_return(true)
      allow(group).to receive(:root_ancestor).and_return(group)
      allow(GitlabSubscriptions::Trials).to receive(:free_plan_expired?).with(group).and_return(true)
    end

    it 'returns a ChatComponent, not a TrialExpiredComponent' do
      is_expected.to be_a(DuoChatPanel::ChatComponent)
    end
  end

  context 'when show_empty_state? is true' do
    it 'returns an EmptyStateComponent instance' do
      is_expected.to be_a(DuoChatPanel::EmptyStateComponent)
    end
  end

  context 'when user is nil' do
    let(:user) { nil }

    it 'returns nil' do
      is_expected.to be_nil
    end
  end

  describe 'show_trial_expired?' do
    context 'when source is nil' do
      it 'does not return a TrialExpiredComponent' do
        is_expected.not_to be_a(DuoChatPanel::TrialExpiredComponent)
      end
    end

    context 'when source is a group' do
      let(:group) { build_stubbed(:group) }

      before do
        allow(group).to receive(:root_ancestor).and_return(group)
      end

      context 'when namespace has free plan and trial is expired' do
        before do
          allow(GitlabSubscriptions::Trials).to receive(:free_plan_expired?).with(group).and_return(true)
        end

        it 'returns a TrialExpiredComponent instance' do
          is_expected.to be_a(DuoChatPanel::TrialExpiredComponent)
        end
      end

      context 'when namespace does not have free plan with expired trial' do
        before do
          allow(GitlabSubscriptions::Trials).to receive(:free_plan_expired?).with(group).and_return(false)
        end

        it 'does not return a TrialExpiredComponent' do
          is_expected.not_to be_a(DuoChatPanel::TrialExpiredComponent)
        end
      end
    end

    context 'when source is a project' do
      let(:project) { build_stubbed(:project) }
      let(:root_group) { build_stubbed(:group) }

      before do
        allow(project).to receive(:root_ancestor).and_return(root_group)
      end

      context 'when namespace has free plan and trial is expired' do
        before do
          allow(GitlabSubscriptions::Trials).to receive(:free_plan_expired?).with(root_group).and_return(true)
        end

        it 'returns a TrialExpiredComponent instance' do
          is_expected.to be_a(DuoChatPanel::TrialExpiredComponent)
        end
      end

      context 'when namespace does not have free plan with expired trial' do
        before do
          allow(GitlabSubscriptions::Trials).to receive(:free_plan_expired?).with(root_group).and_return(false)
        end

        it 'does not return a TrialExpiredComponent' do
          is_expected.not_to be_a(DuoChatPanel::TrialExpiredComponent)
        end
      end
    end
  end
end
