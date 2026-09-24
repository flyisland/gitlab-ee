# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'devise/registrations/new', feature_category: :system_access do
  let(:resource) { Users::RegistrationsBuildService.new(nil, {}).execute }

  before do
    allow(view).to receive_messages(
      resource: resource,
      resource_name: :user,
      unified_registration?: false,
      signup_box_template: 'devise/registrations/signup_box_form',
      preregistration_tracking_label: 'free_registration',
      onboarding_status_presenter: ::Onboarding::StatusPresenter.new({}, nil, resource),
      # The sign-in list. The view is expected to narrow it down itself.
      enabled_button_based_providers: %w[github wecom]
    )
    allow(view).to receive(:omniauth_authorize_path) { |_scope, provider, *| "/users/auth/#{provider}" }

    stub_template 'devise/registrations/_signup_box_form.html.haml' => ''
    stub_template 'devise/shared/_sign_in_link.html.haml' => ''
    stub_template 'devise/shared/_omniauth_provider_button.html.haml' => '= provider'

    # Deliberately narrow, and github is not in it: the JH page is expected to
    # ignore this list, exactly as it did before WeCom existed.
    stub_omniauth_setting(enabled: true, allow_single_sign_on: %w[gitlab])
  end

  # WeCom hands back no trustworthy email address, so it cannot create an
  # account, and a button leading nowhere is worse than no button.
  it 'leaves WeCom out' do
    render

    expect(rendered).not_to have_content('wecom')
  end

  it 'still offers the other providers' do
    render

    expect(rendered).to have_content('github')
  end
end
