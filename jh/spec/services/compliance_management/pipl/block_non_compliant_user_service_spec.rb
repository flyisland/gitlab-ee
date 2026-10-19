# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::Pipl::BlockNonCompliantUserService,
  :saas,
  feature_category: :compliance_management do
  let(:pipl_user) { create(:pipl_user, initial_email_sent_at: 60.days.ago) }
  let(:blocking_user) { create(:user, :admin) }

  subject(:execute) { described_class.new(pipl_user: pipl_user, current_user: blocking_user).execute }

  before do
    stub_ee_application_setting(enforce_pipl_compliance: true)
  end

  it 'rejects through the real JH SaaS feature filter without changing the user', :aggregate_failures do
    result = execute

    expect(result.error?).to be(true)
    expect(result.message).to eq('Pipl Compliance is not available on this instance')
    expect(pipl_user.user.reload.blocked?).to be(false)
    expect(pipl_user.user.note).to be_nil
  end
end
