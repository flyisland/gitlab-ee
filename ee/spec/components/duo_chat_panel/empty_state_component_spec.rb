# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DuoChatPanel::EmptyStateComponent, :aggregate_failures, feature_category: :duo_chat do
  let(:user_namespace) { build_stubbed(:namespace) }
  let(:user) { build_stubbed(:user, namespace: user_namespace) }
  let(:source) { nil }

  let(:helpers_double) do
    double('helpers') # rubocop:disable RSpec/VerifiedDoubles -- ViewComponent helpers proxy
  end

  subject(:component) { render_inline(described_class.new(source: source, user: user)) && page }

  before do
    allow(helpers_double).to receive_messages(new_trial_path: '/trial',
      new_self_managed_trials_path: '/self-managed-trial')
    allow_next_instance_of(described_class) do |instance|
      allow(instance).to receive(:helpers).and_return(helpers_double)
    end
    allow(Ability).to receive(:allowed?).and_call_original
  end

  describe 'rendering' do
    before do
      allow_next_instance_of(described_class) do |instance|
        allow(instance).to receive(:data).and_return({ new_trial_path: '/trial' })
      end
    end

    it 'renders the #duo-chat-panel-empty-state element' do
      is_expected.to have_selector('#duo-chat-panel-empty-state')
    end

    it 'has the duo-chat-panel class' do
      is_expected.to have_selector('.duo-chat-panel')
    end

    it 'renders the new_trial_path data attribute on the element' do
      is_expected.to have_css('#duo-chat-panel-empty-state[data-new-trial-path="/trial"]')
    end
  end

  describe '#data' do
    describe 'auto_expand field' do
      before do
        # Stub to prevent route helper errors in data method
        allow_next_instance_of(described_class) do |instance|
          allow(instance).to receive(:data).and_return({
            auto_expand: auto_expand_value,
            can_start_trial: 'false'
          })
        end
      end

      context 'when user is not signed in' do
        let(:user) { nil }
        let(:auto_expand_value) { 'false' }

        it 'is "false"' do
          is_expected.to have_css('#duo-chat-panel-empty-state[data-auto-expand="false"]')
        end
      end

      context 'when user has not dismissed the callout' do
        let(:auto_expand_value) { 'true' }

        it 'is "true"' do
          is_expected.to have_css('#duo-chat-panel-empty-state[data-auto-expand="true"]')
        end
      end

      context 'when user has dismissed the callout' do
        let(:user) do
          build_stubbed(:user, callouts: [
            build_stubbed(:callout, feature_name: 'duo_panel_empty_state_auto_expanded')
          ])
        end

        let(:auto_expand_value) { 'false' }

        it 'is "false"' do
          is_expected.to have_css('#duo-chat-panel-empty-state[data-auto-expand="false"]')
        end
      end
    end

    context 'on .com', :saas_gitlab_com_subscriptions do
      let_it_be(:group) { create(:group) } # rubocop:disable RSpec/FactoryBot/AvoidCreate -- needed to test group persistence

      before do
        allow(group).to receive(:has_free_or_no_subscription?).and_return(has_free_or_no_subscription?)
        allow(Ability).to receive(:allowed?).with(user, :admin_namespace, group).and_return(can_admin_namespace?)
      end

      context 'when user cannot start a trial due to lack of permissions in the namespace' do
        let(:can_admin_namespace?) { false }
        let(:has_free_or_no_subscription?) { true }
        let(:source) { group }

        it 'returns can_start_trial as false' do
          is_expected.to have_css('#duo-chat-panel-empty-state[data-can-start-trial="false"]')
          is_expected.to have_css('#duo-chat-panel-empty-state[data-namespace-type="Group"]')
          is_expected.not_to have_css('#duo-chat-panel-empty-state[data-new-trial-path]')
        end
      end

      context 'when user cannot start a trial due to existing subscription' do
        let(:can_admin_namespace?) { true }
        let(:has_free_or_no_subscription?) { false }
        let(:source) { group }

        it 'returns can_start_trial as false' do
          is_expected.to have_css('#duo-chat-panel-empty-state[data-can-start-trial="false"]')
          is_expected.to have_css('#duo-chat-panel-empty-state[data-namespace-type="Group"]')
        end
      end

      context 'when user can start a trial' do
        let(:can_admin_namespace?) { true }
        let(:has_free_or_no_subscription?) { true }

        context 'when there is no namespace' do
          it 'returns can_start_trial as true with trial path' do
            is_expected.to have_css('#duo-chat-panel-empty-state[data-can-start-trial="true"]')
            is_expected.to have_css('#duo-chat-panel-empty-state[data-trial-duration="30"]')
          end
        end

        context 'when within a project owned by a user' do
          let(:source) { build(:project, namespace: user_namespace) }

          it 'returns can_start_trial as true' do
            is_expected.to have_css('#duo-chat-panel-empty-state[data-can-start-trial="true"]')
            is_expected.to have_css('#duo-chat-panel-empty-state[data-trial-duration="30"]')
          end
        end

        context 'when within a project owned by a group' do
          let(:source) { build(:project, namespace: group) }

          it 'returns can_start_trial as true' do
            is_expected.to have_css('#duo-chat-panel-empty-state[data-can-start-trial="true"]')
            is_expected.to have_css('#duo-chat-panel-empty-state[data-trial-duration="30"]')
          end
        end

        context 'when within a group' do
          let(:source) { group }

          it 'returns can_start_trial as true with namespace_type' do
            is_expected.to have_css('#duo-chat-panel-empty-state[data-can-start-trial="true"]')
            is_expected.to have_css('#duo-chat-panel-empty-state[data-trial-duration="30"]')
            is_expected.to have_css('#duo-chat-panel-empty-state[data-namespace-type="Group"]')
          end
        end

        context 'when the root ancestor is not persisted' do
          let(:source) { group }

          before do
            allow(group).to receive(:persisted?).and_return(false)
          end

          it 'does not include trial path and duration' do
            is_expected.to have_css('#duo-chat-panel-empty-state[data-can-start-trial="false"]')
            is_expected.to have_css('#duo-chat-panel-empty-state[data-namespace-type="Group"]')
          end
        end

        context 'when the root ancestor is nil' do
          let(:source) { group }

          before do
            allow(group).to receive(:root_ancestor).and_return(nil)
          end

          it 'returns can_start_trial as false' do
            is_expected.to have_css('#duo-chat-panel-empty-state[data-can-start-trial="false"]')
          end
        end

        context 'when the trial duration is not the default' do
          before do
            stub_saas_features(subscriptions_trials: true)
            allow_next_instance_of(GitlabSubscriptions::TrialDurationService) do |service|
              allow(service).to receive(:execute).and_return(20)
            end
          end

          it 'returns the custom trial duration' do
            is_expected.to have_css('#duo-chat-panel-empty-state[data-can-start-trial="true"]')
            is_expected.to have_css('#duo-chat-panel-empty-state[data-trial-duration="20"]')
          end
        end
      end
    end

    context 'on Self-Managed' do
      let_it_be(:group) { create(:group) } # rubocop:disable RSpec/FactoryBot/AvoidCreate -- needed for persistence
      let(:source) { group }

      context 'when user cannot start a trial' do
        before do
          allow(Ability).to receive(:allowed?).with(user, :update_gitlab_subscription).and_return(false)
        end

        it 'returns can_start_trial as false' do
          is_expected.to have_css('#duo-chat-panel-empty-state[data-can-start-trial="false"]')
          is_expected.to have_css('#duo-chat-panel-empty-state[data-namespace-type="Group"]')
        end
      end

      context 'when user can start a trial' do
        before do
          allow(Ability).to receive(:allowed?).with(user, :update_gitlab_subscription).and_return(true)
        end

        it 'returns can_start_trial as true with trial duration' do
          is_expected.to have_css('#duo-chat-panel-empty-state[data-can-start-trial="true"]')
          is_expected.to have_css('#duo-chat-panel-empty-state[data-trial-duration="30"]')
          is_expected.to have_css('#duo-chat-panel-empty-state[data-namespace-type="Group"]')
        end
      end
    end
  end
end
