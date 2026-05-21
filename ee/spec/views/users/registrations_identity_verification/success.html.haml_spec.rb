# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'users/registrations_identity_verification/success.html.haml', feature_category: :onboarding do
  let(:user) { build(:user) }
  let(:redirect_url) { '/some/path' }
  let(:onboarding_status_presenter) do
    instance_double(::Onboarding::StatusPresenter, unification_enabled?: unified_registration)
  end

  before do
    assign(:redirect_url, redirect_url)
    allow(view).to receive_messages(
      current_user: user,
      onboarding_status_presenter: onboarding_status_presenter
    )
  end

  shared_examples 'common verification successful content' do
    it 'hides the empty navbar' do
      render

      expect(view.content_for(:hide_empty_navbar)).to be_truthy
    end

    it 'sets the contextual marketing-panel image and heading' do
      render

      expect(view.content_for(:registration_marketing_panel_image)).to eq('subscription/collab')
      expect(view.content_for(:registration_marketing_panel_heading)).to include('Collaborate and accelerate')
    end

    it 'renders a meta refresh tag with the redirect url' do
      render

      expect(view.content_for(:meta_tags))
        .to have_css("meta[http-equiv='refresh'][content='3; url=#{redirect_url}']", visible: :hidden)
    end

    it 'renders the verification successful heading and a link to the redirect url' do
      render

      expect(rendered).to have_content('Verification successful')
      expect(rendered).to have_link('', href: redirect_url)
    end
  end

  context 'with unified registration' do
    let(:unified_registration) { true }

    it_behaves_like 'common verification successful content'

    it 'renders the unified-registration template copy' do
      render

      expect(rendered).to have_content("You'll be redirected in just a moment.")
      expect(rendered).to have_css('h1.gl-heading-1')
    end
  end

  context 'when subscription_sm_unification feature flag is disabled' do
    let(:unified_registration) { false }

    it_behaves_like 'common verification successful content'

    it 'renders the legacy template copy' do
      render

      expect(rendered).to have_content("You'll be redirected to your account in just a moment.")
      expect(rendered).to have_css('.svg-content')
    end
  end
end
