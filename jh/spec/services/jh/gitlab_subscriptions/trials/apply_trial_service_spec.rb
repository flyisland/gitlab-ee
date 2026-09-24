# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::Trials::ApplyTrialService, :saas, feature_category: :acquisition do
  let_it_be(:namespace) { create(:group_with_plan) }
  let_it_be(:user) { create(:user, owner_of: namespace) }

  let(:trial_user_information) { { namespace_id: namespace.id } }
  let(:apply_trial_params) do
    {
      uid: user.id,
      trial_user_information: trial_user_information
    }
  end

  describe '#execute' do
    subject(:execute) { described_class.new(**apply_trial_params).execute }

    context 'when valid to generate a trial' do
      context 'when trial is applied successfully' do
        before do
          allow_trial_creation(namespace, trial_user_information)
        end

        context 'when jh_skip_auto_assign_duo_seat is disabled' do
          before do
            stub_feature_flags(jh_skip_auto_assign_duo_seat: true)
            stub_request(:get, %r{\Ahttps://customers-stg.jihulab.com/api/v1/gitlab/namespaces/trials/eligibility.*\z})
              .to_return(status: 200, body: "", headers: {})
          end

          it 'does not auto-assigns a duo seat' do
            expect { execute }.not_to change { user.assigned_add_ons.count }
          end
        end
      end
    end
  end

  def allow_trial_creation(namespace, trial_user)
    allow(Gitlab::SubscriptionPortal::Client)
      .to receive(:generate_trial) do
      create(
        :gitlab_subscription_add_on_purchase,
        :duo_enterprise,
        :trial,
        expires_on: 60.days.from_now,
        namespace: namespace
      )
    end
      .with(uid: user.id, trial_user: trial_user)
      .and_return(success: true)
  end
end
