# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::Pipl::SendInitialComplianceEmailService,
  :saas,
  feature_category: :compliance_management do
  let_it_be_with_reload(:user) { create(:user) }
  let_it_be_with_reload(:pipl_user) { create(:pipl_user, user: user) }

  subject(:send_email) { described_class.new(user: user).execute }

  before do
    stub_ee_application_setting(enforce_pipl_compliance: true)
  end

  it 'still records the initial email timestamp' do
    expect { send_email }
      .to change { pipl_user.reload.initial_email_sent_at }.from(nil)
  end

  it 'enqueues the notification but delivers nothing when the job runs', :aggregate_failures do
    expect { send_email }.to have_enqueued_mail(Notify, :pipl_compliance_notification)

    expect do
      perform_enqueued_jobs
    end.not_to change { ActionMailer::Base.deliveries.count }
  end
end
