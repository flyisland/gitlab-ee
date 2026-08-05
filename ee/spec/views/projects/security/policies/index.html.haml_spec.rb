# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "projects/security/policies/index", feature_category: :security_policy_management, type: :view do
  let(:user) { project.first_owner }
  let(:project) { create(:project) }

  before do
    sign_in(user)
  end

  context 'when security_policies_v2 is disabled' do
    before do
      stub_feature_flags(security_policies_v2: false)
      render template: 'projects/security/policies/index', locals: { project: project }
    end

    it 'renders security policies list root' do
      expect(rendered).to have_selector('#js-security-policies-list')
    end

    it 'does not render the security policies experimental v2 root' do
      expect(rendered).not_to have_selector('#js-security-policies-v2')
    end
  end

  context 'when security_policies_v2 is enabled' do
    before do
      stub_feature_flags(security_policies_v2: true)
      render template: 'projects/security/policies/index', locals: { project: project }
    end

    it 'renders the security policies experimental v2 root' do
      expect(rendered).to have_selector('#js-security-policies-v2')
    end

    it 'does not render security policies list root' do
      expect(rendered).not_to have_selector('#js-security-policies-list')
    end

    it 'passes namespace path as data attribute' do
      expect(rendered).to have_selector(
        "#js-security-policies-v2[data-namespace-path='#{project.full_path}']"
      )
    end
  end
end
