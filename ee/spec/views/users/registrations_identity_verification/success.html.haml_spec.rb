# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'users/registrations_identity_verification/success.html.haml', feature_category: :onboarding do
  let(:user) { build(:user) }
  let(:redirect_url) { '/some/path' }

  before do
    assign(:redirect_url, redirect_url)
    allow(view).to receive(:current_user).and_return(user)
  end

  it 'hides the empty navbar' do
    render

    expect(view.content_for(:hide_empty_navbar)).to be_truthy
  end

  it 'renders a meta refresh tag with the redirect url' do
    render

    expect(view.content_for(:meta_tags))
      .to have_css("meta[http-equiv='refresh'][content='3; url=#{redirect_url}']", visible: :hidden)
  end

  it 'renders the secure illustration' do
    render

    expect(rendered).to have_css('.svg-content img')
  end

  it 'renders the verification successful heading and paragraph with link' do
    render

    expect(rendered).to have_content('Verification successful')
    expect(rendered).to have_link('', href: redirect_url)
    expect(rendered).to have_content("You'll be redirected to your account in just a moment.")
  end
end
