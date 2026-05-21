# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::Ascp::ScanPolicy, feature_category: :static_application_security_testing do
  include PolicyHelpers

  let_it_be(:project) { create(:project, :private) }
  let_it_be(:scan) { create(:security_ascp_scan, project: project) }

  subject { described_class.new(user, scan) }

  before do
    stub_licensed_features(security_dashboard: true)
  end

  context 'when user is a developer' do
    let_it_be(:user) { create(:user, developer_of: project) }

    it { expect_allowed(:read_ascp_scan) }
    it { expect_disallowed(:create_ascp_scan) }
  end

  context 'when user is a maintainer' do
    let_it_be(:user) { create(:user, maintainer_of: project) }

    it { expect_allowed(:read_ascp_scan) }
    it { expect_allowed(:create_ascp_scan) }
  end

  context 'when user is a guest' do
    let_it_be(:user) { create(:user, guest_of: project) }

    it { expect_disallowed(:read_ascp_scan) }
    it { expect_disallowed(:create_ascp_scan) }
  end

  context 'when user is an owner' do
    let_it_be(:user) { create(:user, owner_of: project) }

    it { expect_allowed(:read_ascp_scan) }
    it { expect_allowed(:create_ascp_scan) }
  end

  context 'when user is not a member' do
    let_it_be(:user) { create(:user) }

    it { expect_disallowed(:read_ascp_scan) }
    it { expect_disallowed(:create_ascp_scan) }
  end

  context 'when user is nil' do
    let(:user) { nil }

    it { expect_disallowed(:read_ascp_scan) }
    it { expect_disallowed(:create_ascp_scan) }
  end

  context 'when user is an admin with admin mode enabled', :enable_admin_mode do
    let_it_be(:user) { create(:admin) }

    it { expect_allowed(:read_ascp_scan) }
    it { expect_allowed(:create_ascp_scan) }
  end

  context 'when security_dashboard feature is not available' do
    let_it_be(:user) { create(:user, maintainer_of: project) }

    before do
      stub_licensed_features(security_dashboard: false)
    end

    it { expect_disallowed(:read_ascp_scan) }
    it { expect_disallowed(:create_ascp_scan) }
  end
end
