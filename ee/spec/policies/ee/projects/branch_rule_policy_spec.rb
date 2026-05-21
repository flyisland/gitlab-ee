# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::BranchRulePolicy, feature_category: :source_code_management do
  let_it_be(:protected_branch) { create(:protected_branch) }
  let_it_be(:user) { create(:user, maintainer_of: protected_branch.project) }

  let(:branch_rule) { Projects::BranchRule.new(protected_branch.project, protected_branch) }

  subject(:policy) { described_class.new(user, branch_rule) }

  shared_examples 'allows squash option crud' do
    it { expect_allowed(:create_squash_option) }
    it { expect_allowed(:update_squash_option) }
    it { expect_allowed(:destroy_squash_option) }
  end

  shared_examples 'disallows squash option changes' do
    it { expect_disallowed(:create_squash_option) }
    it { expect_disallowed(:update_squash_option) }
    it { expect_disallowed(:destroy_squash_option) }
  end

  describe 'Abilities' do
    using RSpec::Parameterized::TableSyntax

    where(
      :unprotect_restrictions_enabled, :can_unprotect, :branch_rule_behavior, :squash_option_behavior
    ) do
      true  | true  | 'allows branch rule crud' | 'allows squash option crud'
      true  | false | 'disallows branch rule changes' | 'disallows squash option changes'
      false | false | 'allows branch rule crud'     | 'allows squash option crud'
      false | true  | 'allows branch rule crud'     | 'allows squash option crud'
    end

    it_behaves_like 'allows branch rule crud'
    it_behaves_like 'allows squash option crud'

    with_them do
      before do
        stub_licensed_features(unprotection_restrictions: unprotect_restrictions_enabled)

        allow(protected_branch)
          .to receive(:can_unprotect?).with(user)
          .and_return(can_unprotect)
      end

      it_behaves_like params[:branch_rule_behavior]
      it_behaves_like params[:squash_option_behavior]
    end
  end

  context 'as a guest with admin_protected_branch custom role' do
    let_it_be(:group) { create(:group) }
    let_it_be(:project) { create(:project, group: group) }
    let_it_be(:protected_branch) { create(:protected_branch, project: project) }
    let_it_be(:user) { create(:user) }
    let_it_be(:project_member) { create(:project_member, :guest, user: user, project: project) }

    let(:branch_rule) { Projects::BranchRule.new(project, protected_branch) }

    before do
      stub_licensed_features(custom_roles: true)
      create(:member_role, :guest, admin_protected_branch: true, namespace: group, members: [project_member])
    end

    it { expect_allowed(:read_branch_rule) }
  end
end
