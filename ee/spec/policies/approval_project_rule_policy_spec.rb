# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApprovalProjectRulePolicy, feature_category: :code_review_workflow do
  let(:project) { create(:project) }
  let!(:approval_rule) { create(:approval_project_rule, project: project) }

  def permissions(user, approval_rule)
    described_class.new(user, approval_rule)
  end

  context 'when user can admin project' do
    it 'allows updating approval rule' do
      expect(permissions(project.creator, approval_rule)).to be_allowed(:edit_approval_rule)
    end
  end

  context 'when user cannot admin project' do
    let(:user) { create(:user) }

    before do
      project.add_developer(user)
    end

    it 'disallow updating approval rule' do
      expect(permissions(user, approval_rule)).to be_disallowed(:edit_approval_rule)
    end
  end

  context 'when instance-level approval rule lock is enabled' do
    let_it_be(:maintainer) { create(:user) }
    let(:user) { maintainer }

    subject { described_class.new(user, approval_rule) }

    before do
      project.add_maintainer(maintainer)
    end

    context 'with admin_merge_request_approvers_rules license' do
      before do
        stub_licensed_features(admin_merge_request_approvers_rules: true)
        stub_application_setting(disable_overriding_approvers_per_merge_request: true)
      end

      it 'disallows maintainer from editing approval rule' do
        expect_disallowed(:edit_approval_rule)
      end

      context 'when user is admin', :enable_admin_mode do
        let(:user) { create(:admin) }

        it 'allows admin to edit approval rule' do
          expect_allowed(:edit_approval_rule)
        end
      end
    end

    context 'without admin_merge_request_approvers_rules license' do
      before do
        stub_licensed_features(admin_merge_request_approvers_rules: false)
        stub_application_setting(disable_overriding_approvers_per_merge_request: true)
      end

      it 'allows maintainer to edit approval rule when license is unavailable' do
        expect_allowed(:edit_approval_rule)
      end
    end
  end
end
