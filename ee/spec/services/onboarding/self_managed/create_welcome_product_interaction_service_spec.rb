# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Onboarding::SelfManaged::CreateWelcomeProductInteractionService, feature_category: :onboarding do
  describe '#execute' do
    let_it_be(:user, freeze: false) { create(:user, first_name: 'Jane', last_name: 'Doe') }
    let(:expected_params) do
      {
        lead: {
          first_name: 'Jane',
          last_name: 'Doe',
          email: user.email,
          company_name: 'Acme Corp',
          product_interaction: 'SM Welcome Flow No Trial Contact'
        }
      }
    end

    before_all do
      user.user_detail.update!(
        company: 'Acme Corp',
        onboarding_status: { 'email_opt_in' => true, 'country' => 'US' }
      )
    end

    subject(:execute) { described_class.new(user: user).execute }

    context 'when the submission succeeds' do
      before do
        allow(Gitlab::SubscriptionPortal::Client)
          .to receive(:create_self_managed_welcome_contact)
          .with(expected_params)
          .and_return({ success: true })
      end

      it 'returns success' do
        expect(execute).to be_success
      end

      it 'calls create_self_managed_welcome_contact with the expected params' do
        execute

        expect(Gitlab::SubscriptionPortal::Client)
          .to have_received(:create_self_managed_welcome_contact).with(expected_params)
      end

      it 'sends the correct product_interaction value' do
        execute

        expect(Gitlab::SubscriptionPortal::Client).to have_received(:create_self_managed_welcome_contact)
          .with(lead: hash_including(product_interaction: 'SM Welcome Flow No Trial Contact'))
      end

      context 'when user has an unconfirmed email' do
        let(:unconfirmed_email) { 'new-email@example.com' }
        let(:expected_params) { { lead: super()[:lead].merge(email: unconfirmed_email) } }

        before do
          allow(user).to receive(:unconfirmed_email).and_return(unconfirmed_email)
        end

        it 'uses the unconfirmed email address' do
          execute

          expect(Gitlab::SubscriptionPortal::Client).to have_received(:create_self_managed_welcome_contact)
            .with(lead: hash_including(email: unconfirmed_email))
        end
      end
    end

    context 'when the submission fails with an error message' do
      before do
        allow(Gitlab::SubscriptionPortal::Client)
          .to receive(:create_self_managed_welcome_contact)
          .and_return({ success: false, data: { errors: 'email is invalid' } })
      end

      it 'returns the error' do
        result = execute

        expect(result).to be_error
        expect(result.message).to eq('email is invalid')
        expect(result.reason).to eq(:submission_failed)
      end
    end

    context 'when the submission fails without an error message' do
      before do
        allow(Gitlab::SubscriptionPortal::Client)
          .to receive(:create_self_managed_welcome_contact)
          .and_return({ success: false })
      end

      it 'returns a default error message' do
        result = execute

        expect(result).to be_error
        expect(result.message).to eq('Submission failed')
        expect(result.reason).to eq(:submission_failed)
      end
    end
  end
end
