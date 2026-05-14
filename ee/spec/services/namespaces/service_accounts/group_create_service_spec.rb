# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Namespaces::ServiceAccounts::GroupCreateService, feature_category: :user_management do
  shared_examples 'service account creation failure' do
    it 'produces an error', :aggregate_failures do
      expect(result.status).to eq(:error)
      expect(result.message).to eq(
        s_('ServiceAccount|User does not have permission to create a service account in this group.')
      )
    end
  end

  shared_examples 'skip_owner_check bypasses permission checks' do
    context 'when skip_owner_check is true' do
      context 'when composite_identity_enforced is true' do
        let(:params) do
          { organization_id: organization.id, namespace_id: namespace_id, skip_owner_check: true,
            composite_identity_enforced: true }
        end

        subject(:service) { described_class.new(current_user, params) }

        it 'creates a service account successfully with composite_identity_enforced', :aggregate_failures do
          result = service.execute

          expect(result.status).to eq(:success)
          expect(result.payload[:user].confirmed?).to be(true)
          expect(result.payload[:user].composite_identity_enforced?).to be(true)
          expect(result.payload[:user].user_type).to eq('service_account')
          expect(result.payload[:user].external).to be(true)
        end

        it 'sets provisioned by group' do
          expect(result.payload[:user].provisioned_by_group_id).to eq(group.id)
        end
      end

      context 'when composite_identity_enforced is false' do
        let(:params) do
          { organization_id: organization.id, namespace_id: namespace_id, skip_owner_check: true,
            composite_identity_enforced: false }
        end

        subject(:service) { described_class.new(current_user, params) }

        it_behaves_like 'service account creation failure'
      end
    end
  end

  let_it_be(:organization) { create(:organization) }
  let_it_be(:group) { create(:group) }
  let_it_be(:subgroup) { create(:group, :private, parent: group) }

  let(:namespace_id) { group.id }

  subject(:service) do
    described_class.new(current_user, { organization_id: organization.id, namespace_id: namespace_id })
  end

  context 'when self-managed' do
    before do
      allow(License).to receive(:current).and_return(license)
    end

    context 'when current user is an admin', :enable_admin_mode do
      let_it_be(:current_user) { create(:admin) }

      context 'when subscription is of starter plan' do
        let(:license) { create(:license, plan: License::STARTER_PLAN) }

        it 'creates a service account successfully (treated as free tier, under seat limit)' do
          expect(result.status).to eq(:success)
        end
      end

      context 'when subscription is ultimate tier' do
        let(:license) { create(:license, plan: License::ULTIMATE_PLAN) }

        it_behaves_like 'service account creation success' do
          let(:username_prefix) { "service_account_group_#{group.id}" }
        end

        describe 'uniquifying the username' do
          let_it_be(:username_param) { 'a-users-username' }

          let(:params) { { organization_id: organization.id, namespace_id: namespace_id, username: username_param } }

          subject(:service) { described_class.new(current_user, params, uniquify_provided_username:) }

          context 'when uniquify_provided_username is true' do
            let(:uniquify_provided_username) { true }

            context 'when a user with the username already exists' do
              let_it_be(:existing_user) { create(:user, username: username_param) }

              it 'uniquifies the username by appending a short random string to the end' do
                username = result.payload[:user].username

                expect(username).to start_with(username_param)
                expect(username.length).to eq(username_param.length + 7)
              end

              it 'does not change the email' do
                email = result.payload[:user].email
                expect(email).to start_with("service_account_group_#{namespace_id}")
              end
            end

            context 'when a namespace with the username already exists' do
              let_it_be(:existing_namespace) { create(:group, path: username_param) }

              it 'uniquifies the username by appending a short random string to the end' do
                username = result.payload[:user].username

                expect(username).to start_with(username_param)
                expect(username.length).to eq(username_param.length + 7)
              end
            end

            context 'when neither a user nor namespace with the username exists' do
              it 'does not uniquify the username' do
                username = result.payload[:user].username

                expect(username).to eq(username_param)
              end
            end
          end

          context 'when uniquify_provided_username is false' do
            let(:uniquify_provided_username) { false }

            context 'when the username already exists' do
              let!(:existing_user) { create(:user, :with_namespace, username: username_param) }

              it 'fails to create the user' do
                expect(result.status).to eq(:error)
                expect(result.message).to eq('Username has already been taken')
              end
            end

            context 'when the username does not exist' do
              it 'creates the username without uniquifying it' do
                expect(result.status).to eq(:success)
                expect(result.payload[:user].username).to eq(username_param)
              end
            end

            context 'when not providing a username parameter' do
              before do
                params.delete(:username)
              end

              it 'appends a long random string to the end' do
                username = result.payload[:user].username
                username_prefix = "service_account_group_#{namespace_id}_"

                expect(username).to start_with(username_prefix)
                expect(username.length).to eq(username_prefix.length + 32)
              end
            end
          end
        end

        it 'sets provisioned by group' do
          expect(result.payload[:user].provisioned_by_group_id).to eq(group.id)
        end

        context 'when the group is invalid' do
          let(:namespace_id) { non_existing_record_id }

          it_behaves_like 'service account creation failure'
        end
      end

      context 'when subscription is of premium tier' do
        let(:license) { create(:license, plan: License::PREMIUM_PLAN) }

        it_behaves_like 'service account creation success' do
          let(:username_prefix) { "service_account_group_#{group.id}" }
        end

        it 'sets provisioned by group' do
          expect(result.payload[:user].provisioned_by_group_id).to eq(group.id)
        end

        context 'when the group is invalid' do
          let(:namespace_id) { non_existing_record_id }

          it_behaves_like 'service account creation failure'
        end
      end

      context 'when namespace_id does not exist' do
        let(:license) { create(:license, plan: License::ULTIMATE_PLAN) }
        let(:namespace_id) { non_existing_record_id }

        it 'returns nil for root_namespace' do
          expect(service.send(:resource)).to be_nil
          expect(service.send(:root_namespace)).to be_nil
        end
      end

      context 'when namespace_id param is nil' do
        let(:license) { create(:license, plan: License::ULTIMATE_PLAN) }

        subject(:service) do
          described_class.new(current_user, { organization_id: organization.id, namespace_id: nil })
        end

        it 'fails to create service account due to nil namespace_id' do
          expect(result.status).to eq(:error)
          expect(result.message).to include('User does not have permission to create a service account')
        end
      end
    end

    context 'when current user is not an admin' do
      let(:license) { create(:license, plan: License::ULTIMATE_PLAN) }

      context "when not a group owner" do
        let_it_be(:current_user) { create(:user, maintainer_of: group) }

        it_behaves_like 'service account creation failure'
        it_behaves_like 'skip_owner_check bypasses permission checks'
      end

      context 'when group owner' do
        let_it_be(:current_user) { create(:user, owner_of: group) }

        context 'when application setting is disabled' do
          before do
            stub_ee_application_setting(allow_top_level_group_owners_to_create_service_accounts: false)
          end

          it_behaves_like 'service account creation failure'

          context 'when gitlab_com_subscriptions saas feature is available' do
            before do
              stub_saas_features(gitlab_com_subscriptions: true)
            end

            it_behaves_like 'service account creation failure'
          end
        end

        context 'when application setting is enabled' do
          before do
            stub_ee_application_setting(allow_top_level_group_owners_to_create_service_accounts: true)
          end

          it_behaves_like 'service account creation success' do
            let(:username_prefix) { "service_account_group_#{group.id}" }
          end

          context 'when gitlab_com_subscriptions saas feature is available', :saas do
            let_it_be(:group) { create(:group_with_plan, plan: :premium_plan, owners: current_user) }

            before do
              stub_saas_features(gitlab_com_subscriptions: true)
            end

            it_behaves_like 'service account creation success' do
              let(:username_prefix) { "service_account_group_#{group.id}" }
            end
          end

          context 'when the group is subgroup' do
            let(:namespace_id) { subgroup.id }

            it_behaves_like 'service account creation success' do
              let(:username_prefix) { "service_account_group_#{namespace_id}" }
            end
          end
        end
      end
    end
  end

  describe '#creation_allowed?', :saas, :enable_admin_mode do
    let_it_be(:current_user) { create(:admin) }
    let_it_be(:group_for_delegation) { create(:group) }
    let(:namespace_id) { group_for_delegation.id }

    before do
      stub_saas_features(gitlab_com_subscriptions: true)
      create(:gitlab_subscription, :ultimate, namespace: group_for_delegation)
    end

    it 'delegates to Authn::ServiceAccounts.creation_allowed_for_saas?' do
      expect(::Authn::ServiceAccounts).to receive(:creation_allowed_for_saas?)
        .with(group_for_delegation, anything)
        .and_call_original

      service.execute
    end
  end

  context 'when SaaS', :saas do
    before do
      stub_saas_features(gitlab_com_subscriptions: true)
    end

    context 'when current user is an admin', :enable_admin_mode do
      let_it_be(:current_user) { create(:admin) }

      context 'when subscription is of gold tier' do
        let_it_be(:group_with_gold) { create(:group) }
        let(:namespace_id) { group_with_gold.id }

        before do
          create(:gitlab_subscription, :gold, namespace: group_with_gold, seats: 0)
        end

        it_behaves_like 'service account creation success' do
          let(:username_prefix) { "service_account_group_#{group_with_gold.id}" }
        end

        it 'sets provisioned by group' do
          expect(result.payload[:user].provisioned_by_group_id).to eq(group_with_gold.id)
        end

        context 'when the group is invalid' do
          let(:namespace_id) { non_existing_record_id }

          it_behaves_like 'service account creation failure'
        end
      end

      context 'when subscription is of ultimate tier' do
        let_it_be(:group_with_ultimate) { create(:group) }
        let(:namespace_id) { group_with_ultimate.id }

        before do
          create(:gitlab_subscription, :ultimate, namespace: group_with_ultimate, seats: 10)
        end

        it_behaves_like 'service account creation success' do
          let(:username_prefix) { "service_account_group_#{group_with_ultimate.id}" }
        end

        it 'sets provisioned by group' do
          expect(result.payload[:user].provisioned_by_group_id).to eq(group_with_ultimate.id)
        end

        context 'when the group is invalid' do
          let(:namespace_id) { non_existing_record_id }

          it_behaves_like 'service account creation failure'
        end
      end

      context 'when subscription is of premium tier' do
        let_it_be(:group_with_premium) { create(:group) }
        let(:namespace_id) { group_with_premium.id }

        before do
          create(:gitlab_subscription, :premium, namespace: group_with_premium)
        end

        it_behaves_like 'service account creation success' do
          let(:username_prefix) { "service_account_group_#{group_with_premium.id}" }
        end

        it 'sets provisioned by group' do
          expect(result.payload[:user].provisioned_by_group_id).to eq(group_with_premium.id)
        end

        context 'when the group is invalid' do
          let(:namespace_id) { non_existing_record_id }

          it_behaves_like 'service account creation failure'
        end
      end

      context 'when namespace_id does not exist' do
        let(:namespace_id) { non_existing_record_id }

        it 'returns an error due to invalid namespace' do
          expect(result.status).to eq(:error)
          expect(service.send(:resource)).to be_nil
          expect(service.send(:root_namespace)).to be_nil
        end
      end

      context 'when namespace_id param is not provided' do
        subject(:service) do
          described_class.new(current_user, { organization_id: organization.id })
        end

        it 'fails due to missing namespace' do
          expect(result.status).to eq(:error)
          expect(result.message).to include('User does not have permission to create a service account')
        end

        it 'returns 0 for service_accounts_provisioned_count when root_namespace is nil' do
          expect(service.send(:root_namespace)).to be_nil
          expect(service.send(:service_accounts_provisioned_count)).to eq(0)
        end
      end
    end

    context 'when current user is a group owner' do
      let_it_be(:group_with_trial) { create(:group) }
      let_it_be(:current_user) { create(:user, owner_of: group_with_trial) }
      let(:namespace_id) { group_with_trial.id }

      before do
        stub_ee_application_setting(allow_top_level_group_owners_to_create_service_accounts: true)
      end

      context 'when subscription of type trial' do
        before do
          create(:gitlab_subscription, :active_trial, namespace: group_with_trial, hosted_plan: create(:ultimate_plan))
        end

        it_behaves_like 'service account creation success' do
          let(:username_prefix) { "service_account_group_#{group_with_trial.id}" }
        end

        it 'sets provisioned by group' do
          expect(result.payload[:user].provisioned_by_group_id).to eq(group_with_trial.id)
        end

        context 'when allow_unlimited_service_account_for_trials feature flag is disabled' do
          before do
            stub_feature_flags(allow_unlimited_service_account_for_trials: false)
          end

          it_behaves_like 'service account creation success' do
            let(:username_prefix) { "service_account_group_#{namespace_id}" }
          end

          context 'when service account limit is reached' do
            let_it_be(:group_with_limited_trial) { create(:group, owners: current_user) }
            let(:namespace_id) { group_with_limited_trial.id }

            before do
              create(:gitlab_subscription, :active_trial, namespace: group_with_limited_trial,
                hosted_plan: create(:ultimate_plan))

              create(:group_member, :owner, group: group_with_limited_trial, user: create(:user))
              stub_const('Authn::ServiceAccounts::LIMIT_FOR_TRIAL', 2)
              create_list(:user, 2, :service_account, provisioned_by_group_id: group_with_limited_trial.id)
            end

            it 'produces an error' do
              expect(result.status).to eq(:error)
              expect(result.message).to include('No more seats are available to create Service Account User')
            end
          end

          context 'when trial namespace has service accounts with composite identity' do
            let_it_be(:group_with_composite_identity) { create(:group, owners: current_user) }
            let(:namespace_id) { group_with_composite_identity.id }

            before do
              create(:gitlab_subscription, :active_trial, namespace: group_with_composite_identity,
                hosted_plan: create(:ultimate_plan))
              stub_const('Authn::ServiceAccounts::LIMIT_FOR_TRIAL', 3)
            end

            context 'when composite identity service accounts exist alongside regular ones below limit' do
              before do
                create_list(:user, 5, :service_account,
                  provisioned_by_group_id: group_with_composite_identity.id,
                  composite_identity_enforced: true)
                create_list(:user, 2, :service_account,
                  provisioned_by_group_id: group_with_composite_identity.id,
                  composite_identity_enforced: false)
              end

              it 'only counts service accounts without composite identity against the limit' do
                result = service.execute

                expect(result.status).to eq(:success)
                expect(result.payload[:user].user_type).to eq('service_account')
              end
            end

            context 'when service accounts without composite identity reach the limit' do
              before do
                create_list(:user, 3, :service_account,
                  provisioned_by_group_id: group_with_composite_identity.id,
                  composite_identity_enforced: false)
                create_list(:user, 2, :service_account,
                  provisioned_by_group_id: group_with_composite_identity.id,
                  composite_identity_enforced: true)
              end

              it 'produces an error' do
                result = service.execute

                expect(result.status).to eq(:error)
                expect(result.message).to include('No more seats are available to create Service Account User')
              end
            end

            context 'when project provisioned service accounts exist' do
              let_it_be(:project) { create(:project, group: group_with_composite_identity) }

              before do
                create_list(:user, 3, :service_account,
                  provisioned_by_project_id: project.id,
                  composite_identity_enforced: false)
                create_list(:user, 2, :service_account,
                  provisioned_by_project_id: project.id,
                  composite_identity_enforced: true)
              end

              it 'still produces an error' do
                result = service.execute

                expect(result.status).to eq(:error)
                expect(result.message).to include('No more seats are available to create Service Account User')
              end
            end
          end
        end
      end

      context 'when namespace has an active paid subscription' do
        let_it_be(:group_with_paid) { create(:group, owners: current_user) }
        let(:namespace_id) { group_with_paid.id }

        before do
          create(:gitlab_subscription, :premium, namespace: group_with_paid)
        end

        it_behaves_like 'service account creation success' do
          let(:username_prefix) { "service_account_group_#{group_with_paid.id}" }
        end
      end
    end

    context 'when current user is not a group owner' do
      let_it_be(:group_with_ultimate) { create(:group) }
      let_it_be(:current_user) { create(:user, maintainer_of: group_with_ultimate) }
      let_it_be(:group) { group_with_ultimate }

      before do
        create(:gitlab_subscription, :ultimate, namespace: group_with_ultimate, seats: 10)
        stub_ee_application_setting(allow_top_level_group_owners_to_create_service_accounts: true)
      end

      it_behaves_like 'service account creation failure'
      it_behaves_like 'skip_owner_check bypasses permission checks'
    end
  end

  def result
    service.execute
  end
end
