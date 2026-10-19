# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::Pipl::DeleteNonCompliantUserService,
  :saas,
  feature_category: :compliance_management do
  let_it_be_with_reload(:pipl_user) { create(:pipl_user, :deletable) }
  let_it_be_with_reload(:user) { pipl_user.user }

  let(:deleting_user) { create(:user, :admin) }

  subject(:execute) { described_class.new(pipl_user: pipl_user, current_user: deleting_user).execute }

  before do
    stub_ee_application_setting(enforce_pipl_compliance: true)
  end

  it 'rejects through the real JH SaaS feature filter without deleting the user', :aggregate_failures do
    result = execute

    expect(result.error?).to be(true)
    expect(result.message).to eq('Pipl Compliance is not available on this instance')
    expect(user.reload.ghost_user_migration).to be_nil
    expect(user.blocked?).to be(true)
  end
end
