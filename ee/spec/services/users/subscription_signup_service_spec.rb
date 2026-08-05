# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::SubscriptionSignupService, feature_category: :acquisition do
  let_it_be_with_reload(:user) do
    create(
      :user, onboarding_in_progress: true, onboarding_status_setup_for_company: true,
      onboarding_status_registration_type: 'subscription'
    )
  end

  let(:params) { {} }
  let(:update_params) { { onboarding_status_role: 0 }.merge(params) }

  describe '#execute' do
    let(:updated_user) { execute[:user].reset }

    subject(:execute) { described_class.new(user, params: update_params).execute }

    context 'when updating onboarding_status_role' do
      let(:params) { { onboarding_status_role: 1 } }

      it 'updates the onboarding_status_role attribute' do
        expect(execute).to be_success
        expect(updated_user.onboarding_status_role_name).to eq('development_team_lead')
      end

      context 'when onboarding_status_role is missing' do
        let(:params) { { onboarding_status_role: nil } }

        it 'returns an error result' do
          expect(execute).to be_error
          expect(execute.message).to include("Onboarding status role can't be blank")
        end
      end
    end

    context 'when updating setup_for_company' do
      it 'updates the setup_for_company attribute' do
        expect(execute).to be_success
        expect(updated_user.onboarding_status_setup_for_company).to be(true)
      end

      context 'when onboarding_status_setup_for_company is missing' do
        let(:params) { { onboarding_status_setup_for_company: '' } }

        it 'returns a successful result and sets onboarding_status_setup_for_company to false' do
          expect(execute).to be_success
          expect(updated_user.onboarding_status_setup_for_company).to be false
        end
      end
    end

    context 'when updating onboarding_status_joining_project' do
      let(:params) { { onboarding_status_joining_project: true } }

      it 'updates the attribute' do
        expect(execute).to be_success
        expect(updated_user.onboarding_status_joining_project).to be true
      end
    end

    context 'when updating onboarding_status_registration_objective' do
      let(:params) { { onboarding_status_registration_objective: 2 } }

      it 'updates the attribute' do
        expect(execute).to be_success
        expect(updated_user.onboarding_status_registration_objective).to eq(2)
      end
    end

    context 'when param contains an unsupported attribute' do
      let(:params) { { name: 'New Name' } }

      it 'does not update the attribute' do
        expect(execute).to be_success
        expect(updated_user.name).not_to eq('New Name')
      end
    end

    context 'for onboarding redirect troubleshooting' do
      it 'writes onboarding_in_progress to cache', :use_clean_rails_memory_store_caching do
        expect do
          execute
        end.to change { Rails.cache.read("user_onboarding_in_progress:#{user.id}") }.from(nil).to(false)
      end
    end

    context 'with onboarding concerns', :saas_onboarding do
      it 'ends onboarding' do
        expect { execute }.to change { user.onboarding_in_progress }.from(true).to(false)
      end
    end
  end
end
