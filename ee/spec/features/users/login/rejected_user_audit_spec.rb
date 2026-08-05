# frozen_string_literal: true

require 'spec_helper'

# Audit-event behavior for rejected sign-in attempts: invalid
# password, invalid OAuth uid, invalid one-time code. Parallels
# CE's rejected_user_spec.rb, but scoped to the EE-only audit
# events that fire on a failed login. The success paths are
# covered in the CE regular_user / two_factor specs.
#
# Add tests here when the precondition is "a sign-in attempt is
# rejected and we expect a security audit event to be recorded".

RSpec.describe 'Login', feature_category: :system_access do
  include LdapHelpers
  include UserLoginHelper
  include DeviseHelpers

  before do
    stub_licensed_features(extended_audit_events: true)
  end

  it 'creates a security event for an invalid password login', :js do
    user = create(:user)

    expect do
      submit_sign_in_form_for(user, password: 'incorrect-password')

      expect(page).to have_content('Invalid login or password')
    end.to change { AuditEvent.count }.by(1)
  end

  it 'creates a security event for an invalid OAuth login', :with_current_organization do
    stub_omniauth_saml_config(
      enabled: true,
      auto_link_saml_user: false,
      allow_single_sign_on: ['saml'],
      providers: [mock_saml_config]
    )

    user = create(:omniauth_user, :two_factor, extern_uid: 'my-uid', provider: 'saml')

    expect { gitlab_sign_in_via('saml', user, 'wrong-uid') }
      .to change { AuditEvent.where(entity_id: -1).count }.from(0).to(1)
  end

  it 'creates a security event for an invalid one-time code', :js do
    user = create(:user, :two_factor)
    submit_sign_in_form_for(user)

    expect do
      fill_in 'user_otp_attempt', with: 'invalid_code'
      click_button 'Verify code'
      expect(page).to have_content 'Invalid two-factor code.'
    end.to change { AuditEvent.count }.by(1)
  end
end
