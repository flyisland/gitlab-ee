# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'user/registrations_identity_verification/show', feature_category: :instance_resiliency do
  let_it_be(:template) { 'users/registrations_identity_verification/show' }
  let_it_be(:user) { create_default(:user) }
  let(:trial_registration) { false }

  before do
    assign(:user, user)
    allow(view).to receive(:trial_registration?).and_return(trial_registration)
  end

  it_behaves_like 'page with unconfirmed user deletion information'

  context 'with trials' do
    let(:onboarding_status_presenter) do
      instance_double(
        ::Onboarding::StatusPresenter,
        tracking_label: 'trial_registration',
        unification_enabled?: false
      )
    end

    let(:trial_registration) { true }

    before do
      allow(view).to receive(:onboarding_status_presenter).and_return(onboarding_status_presenter)
    end

    it 'sets content_for hide_empty_navbar to true' do
      render(template: template)

      expect(view.content_for(:hide_empty_navbar)).to be_truthy
    end
  end

  context 'when subscription_sm_unification feature flag is disabled' do
    let(:onboarding_status_presenter) do
      instance_double(
        ::Onboarding::StatusPresenter,
        tracking_label: 'free_registration',
        unification_enabled?: false
      )
    end

    before do
      allow(view).to receive(:onboarding_status_presenter).and_return(onboarding_status_presenter)
    end

    it 'passes unified_registration: false to the identity verification data' do
      expect(view).to receive(:signup_identity_verification_data)
        .with(user, unified_registration: false).and_call_original

      render(template: template)
    end
  end

  context 'with unified registration' do
    let(:onboarding_status_presenter) do
      instance_double(
        ::Onboarding::StatusPresenter,
        tracking_label: 'subscription_sm_registration',
        unification_enabled?: true
      )
    end

    before do
      allow(view).to receive(:onboarding_status_presenter).and_return(onboarding_status_presenter)
    end

    it 'passes unified_registration: true to the identity verification data' do
      expect(view).to receive(:signup_identity_verification_data)
        .with(user, unified_registration: true).and_call_original

      render(template: template)
    end

    it 'sets the contextual marketing-panel image and heading' do
      render(template: template)

      expect(view.content_for(:registration_marketing_panel_image)).to eq('subscription/pipeline')
      expect(view.content_for(:registration_marketing_panel_heading)).to include('Ship software faster')
    end
  end
end
