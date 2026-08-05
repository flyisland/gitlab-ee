# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Duo::Administration::VerifyMcpServerSetup, :silence_stdout, feature_category: :mcp_server do
  let_it_be(:user, freeze: false) { create(:user, :admin, username: 'mcp_test_user') }

  let(:username) { user.username }
  let(:task) { described_class.new(username) }

  subject(:verify_setup) { task.execute }

  before do
    create(:application_setting,
      duo_features_enabled: true,
      lock_duo_features_enabled: false,
      instance_level_ai_beta_features_enabled: true)
    allow(::Gitlab::CurrentSettings).to receive_messages(
      duo_features_enabled?: true,
      instance_level_ai_beta_features_enabled?: true
    )
    create_current_license_without_expiration(plan: License::ULTIMATE_PLAN)
    stub_licensed_features(mcp_server: true)
  end

  describe '#execute' do
    context 'when everything is configured correctly' do
      it 'completes without error' do
        expect { verify_setup }.not_to raise_error
      end

      it 'collects system information' do
        verify_setup

        expect(task.diagnostics[:system]).to include(
          gitlab_version: Gitlab::VERSION,
          gitlab_edition: 'EE',
          user: user.username
        )
      end

      context 'when running CE' do
        before do
          allow(::Gitlab).to receive(:ee?).and_return(false)
        end

        it 'reports CE edition' do
          verify_setup

          expect(task.diagnostics[:system]).to include(gitlab_edition: 'CE')
        end
      end

      it 'reports no failures' do
        verify_setup

        expect(task.diagnostics.values).not_to include(hash_including(status: 'FAIL'))
      end
    end

    context 'when no username is provided' do
      let(:username) { nil }

      it 'skips user-specific checks' do
        verify_setup

        expect(task.diagnostics).not_to include(:user_active)
      end
    end

    context 'when username does not exist' do
      let(:username) { 'nonexistent_user' }

      it 'records failure for user lookup' do
        verify_setup

        expect(task.diagnostics[:user_lookup]).to include(status: 'FAIL')
        expect(task.diagnostics[:user_lookup][:message]).to include('nonexistent_user')
      end
    end
  end

  describe '#check_license' do
    context 'when no license is present' do
      before do
        allow(License).to receive(:current).and_return(nil)
      end

      it 'records failure' do
        verify_setup

        expect(task.diagnostics[:license]).to include(status: 'FAIL')
      end
    end

    context 'when license does not include mcp_server feature' do
      before do
        stub_licensed_features(mcp_server: false)
      end

      it 'records failure' do
        verify_setup

        expect(task.diagnostics[:license]).to include(status: 'FAIL')
      end
    end

    context 'when license includes mcp_server feature' do
      it 'records pass' do
        verify_setup

        expect(task.diagnostics[:license]).to include(status: 'PASS')
      end
    end
  end

  describe '#check_duo_availability' do
    context 'when duo availability is default_on' do
      before do
        stub_application_setting(duo_features_enabled: true, lock_duo_features_enabled: false)
      end

      it 'records pass' do
        verify_setup

        expect(task.diagnostics[:duo_availability]).to include(status: 'PASS')
      end
    end

    context 'when duo availability is default_off' do
      before do
        ApplicationSetting.current.update!(duo_features_enabled: false, lock_duo_features_enabled: false)
      end

      it 'records failure' do
        verify_setup

        expect(task.diagnostics[:duo_availability]).to include(status: 'FAIL')
      end
    end

    context 'when duo availability is never_on' do
      before do
        ApplicationSetting.current.update!(duo_features_enabled: false, lock_duo_features_enabled: true)
      end

      it 'records failure' do
        verify_setup

        expect(task.diagnostics[:duo_availability]).to include(status: 'FAIL')
      end
    end

    context 'when duo availability returns an unknown value' do
      before do
        settings = ApplicationSetting.current
        allow(::ApplicationSetting).to receive(:current).and_return(settings)
        allow(settings).to receive(:duo_availability).and_return(:unexpected_value)
      end

      it 'records failure' do
        verify_setup

        expect(task.diagnostics[:duo_availability]).to include(status: 'FAIL')
        expect(task.diagnostics[:duo_availability][:message]).to include('unknown')
      end
    end
  end

  describe '#check_duo_features_enabled' do
    context 'when duo_features_enabled is true' do
      it 'records pass' do
        verify_setup

        expect(task.diagnostics[:duo_features_enabled]).to include(status: 'PASS')
      end
    end

    context 'when duo_features_enabled is false' do
      before do
        allow(::Gitlab::CurrentSettings).to receive(:duo_features_enabled?).and_return(false)
        ApplicationSetting.current.update!(duo_features_enabled: false)
      end

      it 'records failure' do
        verify_setup

        expect(task.diagnostics[:duo_features_enabled]).to include(status: 'FAIL')
      end
    end
  end

  describe '#check_beta_features_enabled' do
    context 'when on SaaS' do
      before do
        stub_saas_features(gitlab_duo_saas_only: true)
      end

      it 'records pass and skips instance-level check' do
        verify_setup

        expect(task.diagnostics[:instance_level_ai_beta_features_enabled]).to include(status: 'PASS')
        expect(task.diagnostics[:instance_level_ai_beta_features_enabled][:message]).to include('SaaS')
      end
    end

    context 'when on self-managed' do
      before do
        stub_saas_features(gitlab_duo_saas_only: false)
      end

      context 'when beta features are enabled' do
        it 'records pass' do
          verify_setup

          expect(task.diagnostics[:instance_level_ai_beta_features_enabled]).to include(status: 'PASS')
        end
      end

      context 'when beta features are disabled' do
        before do
          allow(::Gitlab::CurrentSettings).to receive(:instance_level_ai_beta_features_enabled?).and_return(false)
          ApplicationSetting.current.update!(instance_level_ai_beta_features_enabled: false)
        end

        it 'records failure' do
          verify_setup

          expect(task.diagnostics[:instance_level_ai_beta_features_enabled]).to include(status: 'FAIL')
        end
      end
    end
  end

  describe '#check_oauth_discovery' do
    context 'when API::Mcp::Base is loaded with routes' do
      it 'records pass' do
        verify_setup

        expect(task.diagnostics[:oauth_discovery]).to include(status: 'PASS')
        expect(task.diagnostics[:oauth_discovery][:message]).to include('API::Mcp::Base')
      end
    end

    context 'when API::Mcp::Base is not defined' do
      before do
        hide_const('API::Mcp::Base')
      end

      it 'records failure' do
        verify_setup

        expect(task.diagnostics[:oauth_discovery]).to include(status: 'FAIL')
        expect(task.diagnostics[:oauth_discovery][:message]).to include('NOT loaded')
      end
    end
  end

  describe '#check_instance_access_rules' do
    context 'when rules exist' do
      let_it_be(:group) { create(:group) }

      before do
        create(:ai_instance_accessible_entity_rules, :duo_agent_platform, through_namespace: group)
        create(:ai_instance_accessible_entity_rules, :duo_classic, through_namespace: group)
      end

      it 'records warn with rule descriptions' do
        verify_setup

        expect(task.diagnostics[:instance_access_rules]).to include(status: 'WARN')
        expect(task.diagnostics[:instance_access_rules][:detail]).to include('duo_agent_platform')
      end
    end

    context 'when rules exist without namespace' do
      before do
        create(:ai_instance_accessible_entity_rules, :duo_classic, through_namespace: nil)
      end

      it 'records warn with default group label' do
        verify_setup

        expect(task.diagnostics[:instance_access_rules]).to include(status: 'WARN')
        expect(task.diagnostics[:instance_access_rules][:detail]).to include('Default (no group)')
      end
    end

    context 'when no rules exist' do
      it 'records info about no rules configured' do
        verify_setup

        expect(task.diagnostics[:instance_access_rules]).to include(status: 'INFO')
        expect(task.diagnostics[:instance_access_rules][:message]).to include('No instance-level access rules')
      end
    end
  end

  describe 'user checks' do
    context 'when user is active' do
      it 'records pass' do
        verify_setup

        expect(task.diagnostics[:user_active]).to include(status: 'PASS')
      end
    end

    context 'when user is blocked' do
      before do
        user.block!
      end

      after do
        user.activate!
      end

      it 'records failure' do
        verify_setup

        expect(task.diagnostics[:user_active]).to include(status: 'FAIL')
      end
    end
  end

  describe '#check_user_duo_banned' do
    context 'when duo is set to always off' do
      before do
        allow(::Gitlab::CurrentSettings).to receive(:duo_never_on?).and_return(true)
      end

      it 'records failure' do
        verify_setup

        expect(task.diagnostics[:user_duo_banned]).to include(status: 'FAIL')
        expect(task.diagnostics[:user_duo_banned][:message]).to include('Always off')
      end
    end
  end

  describe '#check_user_allowed_duo_agent_platform' do
    context 'when user is allowed to use duo_agent_platform' do
      before do
        allow_next_found_instance_of(User) do |found_user|
          allow(found_user).to receive(:allowed_to_use?).with(:duo_agent_platform).and_return(true)
        end
      end

      it 'records pass' do
        verify_setup

        expect(task.diagnostics[:user_allowed_duo_agent_platform]).to include(status: 'PASS')
        expect(task.diagnostics[:user_allowed_duo_agent_platform][:message]).to include('is allowed')
      end
    end

    context 'when user does not respond to allowed_to_use?' do
      before do
        allow_next_found_instance_of(User) do |found_user|
          allow(found_user).to receive(:respond_to?).and_call_original
          allow(found_user).to receive(:respond_to?).with(:allowed_to_use?).and_return(false)
        end
      end

      it 'records info' do
        verify_setup

        expect(task.diagnostics[:user_allowed_duo_agent_platform]).to include(status: 'INFO')
        expect(task.diagnostics[:user_allowed_duo_agent_platform][:message]).to include('not available')
      end
    end
  end

  describe '#check_user_instance_access_rules' do
    let_it_be(:group) { create(:group) }

    context 'when access rules exist and user has access' do
      before_all do
        group.add_developer(user)
      end

      before do
        create(:ai_instance_accessible_entity_rules, :duo_agent_platform, through_namespace: group)
        create(:ai_instance_accessible_entity_rules, :duo_classic, through_namespace: group)
      end

      it 'records pass for dap and classic access' do
        verify_setup

        expect(task.diagnostics[:user_dap_access_rule]).to include(status: 'PASS')
        expect(task.diagnostics[:user_classic_access_rule]).to include(status: 'PASS')
      end
    end

    context 'when access rules exist but user has no access' do
      let_it_be(:other_group) { create(:group) }

      before do
        create(:ai_instance_accessible_entity_rules, :duo_agent_platform, through_namespace: other_group)
        create(:ai_instance_accessible_entity_rules, :duo_classic, through_namespace: other_group)
      end

      it 'records warn for dap and classic access' do
        verify_setup

        expect(task.diagnostics[:user_dap_access_rule]).to include(status: 'WARN')
        expect(task.diagnostics[:user_classic_access_rule]).to include(status: 'WARN')
      end
    end
  end

  describe '#check_user_namespace_beta_features' do
    context 'when on SaaS' do
      before do
        stub_saas_features(gitlab_duo_saas_only: true)
      end

      context 'when user belongs to a group with MCP server enabled' do
        before do
          allow_next_found_instance_of(User) do |found_user|
            allow(found_user).to receive(:any_group_with_mcp_server_enabled?).and_return(true)
          end
        end

        it 'records pass' do
          verify_setup

          expect(task.diagnostics[:user_namespace_beta_features]).to include(status: 'PASS')
        end
      end

      context 'when user does not belong to any group with MCP server enabled' do
        before do
          allow_next_found_instance_of(User) do |found_user|
            allow(found_user).to receive(:any_group_with_mcp_server_enabled?).and_return(false)
          end
        end

        it 'records failure' do
          verify_setup

          expect(task.diagnostics[:user_namespace_beta_features]).to include(status: 'FAIL')
        end
      end
    end

    context 'when on SaaS but user does not respond to any_group_with_mcp_server_enabled?' do
      before do
        stub_saas_features(gitlab_duo_saas_only: true)
        allow_next_found_instance_of(User) do |found_user|
          allow(found_user).to receive(:respond_to?).and_call_original
          allow(found_user).to receive(:respond_to?).with(:any_group_with_mcp_server_enabled?).and_return(false)
        end
      end

      it 'does not record namespace beta features check' do
        verify_setup

        expect(task.diagnostics).not_to include(:user_namespace_beta_features)
      end
    end

    context 'when on self-managed' do
      before do
        stub_saas_features(gitlab_duo_saas_only: false)
      end

      it 'does not record namespace beta features check' do
        verify_setup

        expect(task.diagnostics).not_to include(:user_namespace_beta_features)
      end
    end
  end

  describe '#output_diagnostics' do
    it 'outputs JSON formatted diagnostics' do
      verify_setup

      expect(task.diagnostics).to include(:system, :license, :oauth_discovery)
    end
  end
end
