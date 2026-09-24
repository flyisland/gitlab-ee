# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::Pipl::SendRecurringComplianceEmailService,
  :saas,
  feature_category: :compliance_management do
  let_it_be_with_reload(:pipl_user) { create(:pipl_user, :notified) }

  subject(:send_email) { described_class.new(user: pipl_user.user).execute }

  before do
    stub_ee_application_setting(enforce_pipl_compliance: true)
  end

  it 'rejects through the real JH SaaS feature filter and enqueues nothing', :aggregate_failures do
    expect { send_email }.not_to have_enqueued_mail(Notify, :pipl_compliance_notification)
    expect(send_email.message).to eq('Pipl Compliance is not available on this instance')
  end
end
