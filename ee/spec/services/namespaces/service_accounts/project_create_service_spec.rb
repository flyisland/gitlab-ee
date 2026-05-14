# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Namespaces::ServiceAccounts::ProjectCreateService, feature_category: :user_management do
  shared_examples 'service account creation failure for project' do
    it 'produces an error', :aggregate_failures do
      expect(result.status).to eq(:error)
      expect(result.message).to eq(
        s_('ServiceAccount|User does not have permission to create a service account in this project.')
      )
    end
  end

  let_it_be(:organization) { create(:organization) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }

  let(:project_id) { project.id }

  subject(:service) do
    described_class.new(current_user, { organization_id: organization.id, project_id: project_id })
  end

  context 'when self-managed' do
    let(:license) { create(:license, plan: License::ULTIMATE_PLAN) }

    before do
      allow(License).to receive(:current).and_return(license)
    end

    context 'when current user is an admin', :enable_admin_mode do
      let_it_be(:current_user) { create(:admin) }

      it_behaves_like 'service account creation success' do
        let(:username_prefix) { "service_account_project_#{project.id}" }
      end
    end

    # Use project maintainer (least-privileged role with :create_service_account) as the primary
    # positive test to exercise the real authorization path -admin bypasses policy checks entirely.
    context 'when current user is a project maintainer' do
      let_it_be(:current_user) { create(:user, maintainer_of: project) }

      before do
        stub_ee_application_setting(allow_top_level_group_owners_to_create_service_accounts: true)
      end

      it_behaves_like 'service account creation success' do
        let(:username_prefix) { "service_account_project_#{project.id}" }
      end

      it 'sets provisioned by project' do
        expect(result.payload[:user].provisioned_by_project_id).to eq(project.id)
      end

      it 'does not set provisioned by group' do
        expect(result.payload[:user].provisioned_by_group_id).to be_nil
      end

      context 'when the project is invalid' do
        let(:project_id) { non_existing_record_id }

        it_behaves_like 'service account creation failure for project'
      end
    end

    context 'when current user is a group owner' do
      let_it_be(:current_user) { create(:user, owner_of: group) }

      before do
        stub_ee_application_setting(allow_top_level_group_owners_to_create_service_accounts: true)
      end

      it_behaves_like 'service account creation success' do
        let(:username_prefix) { "service_account_project_#{project.id}" }
      end
    end

    context 'when current user is a project developer' do
      let_it_be(:current_user) { create(:user, developer_of: project) }

      before do
        stub_ee_application_setting(allow_top_level_group_owners_to_create_service_accounts: true)
      end

      it_behaves_like 'service account creation failure for project'
    end

    context 'when skip_owner_check params are passed' do
      let_it_be(:current_user) { create(:user, developer_of: project) }

      before do
        stub_ee_application_setting(allow_top_level_group_owners_to_create_service_accounts: true)
      end

      subject(:service) do
        described_class.new(current_user, {
          organization_id: organization.id, project_id: project_id,
          skip_owner_check: true, composite_identity_enforced: true
        })
      end

      it 'does not bypass permission checks for project-level service accounts' do
        expect(result.status).to eq(:error)
        expect(result.message).to eq(
          s_('ServiceAccount|User does not have permission to create a service account in this project.')
        )
      end
    end
  end

  context 'when SaaS', :saas do
    before do
      stub_saas_features(gitlab_com_subscriptions: true)
    end

    # Use group owner (not admin) to exercise the real authorization path on SaaS,
    # where subscription-based seat limits are enforced.
    context 'when current user is a group owner' do
      let_it_be(:group_with_ultimate) { create(:group) }
      let_it_be(:project_in_ultimate) { create(:project, group: group_with_ultimate) }
      let_it_be(:current_user) { create(:user, owner_of: group_with_ultimate) }
      let(:project_id) { project_in_ultimate.id }

      before do
        create(:gitlab_subscription, :ultimate, namespace: group_with_ultimate, seats: 10)
        stub_ee_application_setting(allow_top_level_group_owners_to_create_service_accounts: true)
      end

      it_behaves_like 'service account creation success' do
        let(:username_prefix) { "service_account_project_#{project_in_ultimate.id}" }
      end

      it 'sets provisioned by project' do
        expect(result.payload[:user].provisioned_by_project_id).to eq(project_in_ultimate.id)
      end

      context 'when the project is invalid' do
        let(:project_id) { non_existing_record_id }

        it_behaves_like 'service account creation failure for project'
      end

      context 'when project_id does not exist' do
        let(:project_id) { non_existing_record_id }

        it 'returns nil for root_namespace' do
          expect(service.send(:resource)).to be_nil
          expect(service.send(:root_namespace)).to be_nil
        end
      end
    end

    context 'when subscription is on trial with limit' do
      let_it_be(:group_with_trial) { create(:group) }
      let_it_be(:project_in_trial) { create(:project, group: group_with_trial) }
      let_it_be(:current_user) { create(:user, owner_of: group_with_trial) }
      let(:project_id) { project_in_trial.id }

      before do
        create(:gitlab_subscription, :active_trial, namespace: group_with_trial, hosted_plan: create(:ultimate_plan))
        stub_ee_application_setting(allow_top_level_group_owners_to_create_service_accounts: true)
        stub_feature_flags(allow_unlimited_service_account_for_trials: false)
        stub_const('Authn::ServiceAccounts::LIMIT_FOR_TRIAL', 2)
      end

      context 'when limit is reached with both group and project level service accounts' do
        before do
          create(:user, :service_account, provisioned_by_group_id: group_with_trial.id)
          create(:user, :service_account, provisioned_by_project_id: project_in_trial.id)
        end

        it 'produces an error' do
          expect(result.status).to eq(:error)
          expect(result.message).to include('No more seats are available to create Service Account User')
        end
      end

      context 'when under limit counting both group and project level service accounts' do
        before do
          create(:user, :service_account, provisioned_by_group_id: group_with_trial.id)
        end

        it_behaves_like 'service account creation success' do
          let(:username_prefix) { "service_account_project_#{project_in_trial.id}" }
        end
      end
    end
  end

  def result
    service.execute
  end
end
