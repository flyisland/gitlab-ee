# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApprovalRules::ApprovalGroupRulePolicy, feature_category: :source_code_management do
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:user) { create(:user, owner_of: group) }
  let_it_be(:approval_rule) { create(:approval_group_rule, group: group) }

  def permissions(user, approval_rule)
    described_class.new(user, approval_rule)
  end

  context 'when user is a group owner' do
    it { expect(permissions(user, approval_rule)).to be_allowed(:create_approval_rule) }
    it { expect(permissions(user, approval_rule)).to be_allowed(:update_approval_rule) }
    it { expect(permissions(user, approval_rule)).to be_allowed(:delete_approval_rule) }
    it { expect(permissions(user, approval_rule)).to be_allowed(:read_approval_rule) }
  end

  context 'when user is an auditor' do
    let_it_be(:auditor) { create(:user, :auditor) }

    it { expect(permissions(auditor, approval_rule)).to be_allowed(:read_approval_rule) }
    it { expect(permissions(auditor, approval_rule)).to be_disallowed(:create_approval_rule) }
    it { expect(permissions(auditor, approval_rule)).to be_disallowed(:update_approval_rule) }
    it { expect(permissions(auditor, approval_rule)).to be_disallowed(:delete_approval_rule) }
  end

  context 'when user is not a group member' do
    let_it_be(:non_member) { create(:user) }

    it { expect(permissions(non_member, approval_rule)).to be_disallowed(:create_approval_rule) }
    it { expect(permissions(non_member, approval_rule)).to be_disallowed(:update_approval_rule) }
    it { expect(permissions(non_member, approval_rule)).to be_disallowed(:delete_approval_rule) }
    it { expect(permissions(non_member, approval_rule)).to be_disallowed(:read_approval_rule) }
  end
end
