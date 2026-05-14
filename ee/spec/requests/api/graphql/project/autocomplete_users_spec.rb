# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'autocomplete users for a project', feature_category: :team_planning do
  include GraphqlHelpers
  include Ai::Catalog::FlowFactoryHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, :public, group: group) }
  let_it_be(:current_user) { create(:user, guest_of: project) }

  let(:params) { {} }
  let(:query) do
    graphql_query_for(
      'project',
      { 'fullPath' => project.full_path },
      query_graphql_field('autocompleteUsers', params, 'id username')
    )
  end

  describe 'include_service_accounts_for_trigger_events' do
    let(:users) { graphql_data.dig('project', 'autocompleteUsers').pluck('username') }

    let_it_be(:regular_human_account) do
      create(:user, developer_of: project, username: 'regular_human_account')
    end

    let_it_be(:service_account_without_flow) do
      create(:composite_identity_service_account_for_project, project: project, username: 'without_flow')
    end

    let_it_be(:service_account_without_trigger) do
      create(:composite_identity_service_account_for_project, project: project, username: 'without_trigger')
    end

    let_it_be(:service_account_with_mention_trigger) do
      create(:composite_identity_service_account_for_project, project: project, username: 'with_mention_trigger')
    end

    let_it_be(:service_account_with_assign_trigger) do
      create(:composite_identity_service_account_for_project, project: project, username: 'with_assign_trigger')
    end

    before do
      create_flow_configuration_for_project(
        project, service_account_without_trigger, []
      )
      create_flow_configuration_for_project(
        project, service_account_with_mention_trigger, [0]
      )
      create_flow_configuration_for_project(
        project, service_account_with_assign_trigger, [1]
      )
    end

    context 'when include_service_accounts_for_trigger_events is not empty' do
      let(:params) { { include_service_accounts_for_trigger_events: [:ASSIGN] } }

      context 'and remove_duo_flow_service_accounts_from_autocomplete_query is disabled' do
        before do
          stub_feature_flags(remove_duo_flow_service_accounts_from_autocomplete_query: false)
        end

        it 'does not exclude any Duo service accounts' do
          post_graphql(query, current_user: current_user)

          expect(users)
            .to include(
              regular_human_account.username,
              service_account_without_flow.username,
              service_account_with_assign_trigger.username,
              service_account_without_trigger.username,
              service_account_with_mention_trigger.username
            )
        end
      end

      context 'and remove_duo_flow_service_accounts_from_autocomplete_query is enabled' do
        it 'excludes service accounts without the selected trigger event' do
          post_graphql(query, current_user: current_user)

          expect(users)
            .to include(
              regular_human_account.username,
              service_account_without_flow.username,
              service_account_with_assign_trigger.username
            ).and exclude(
              service_account_without_trigger.username,
              service_account_with_mention_trigger.username
            )
        end
      end
    end

    context 'when include_service_accounts_for_trigger_events is empty' do
      context 'and remove_duo_flow_service_accounts_from_autocomplete_query is enabled' do
        it 'does not exclude any Duo service accounts' do
          post_graphql(query, current_user: current_user)

          expect(users)
              .to include(
                regular_human_account.username,
                service_account_without_flow.username,
                service_account_with_assign_trigger.username,
                service_account_without_trigger.username,
                service_account_with_mention_trigger.username
              )
        end
      end
    end
  end

  describe 'duoStatus field' do
    let(:query) do
      graphql_query_for(
        'project',
        { 'fullPath' => project.full_path },
        query_graphql_field(
          'autocompleteUsers',
          params,
          <<~QUERY
          username
          duoStatus {
            disabled
            disabledReason
          }
          QUERY
        )
      )
    end

    let(:user_data) { graphql_data.dig('project', 'autocompleteUsers') }

    context 'when user type is human' do
      let!(:user) { current_user }

      it 'returns null' do
        post_graphql(query, current_user: current_user)

        expect(user_data[0]['username']).to eq(user.username)
        expect(user_data[0]['duoStatus']).to be_nil
      end
    end

    context 'when user is a regular service account' do
      let!(:user) do
        create(:user, :service_account, guest_of: project, composite_identity_enforced: false)
      end

      it 'returns null' do
        post_graphql(query, current_user: current_user)

        expect(user_data[0]['username']).to eq(user.username)
        expect(user_data[0]['duoStatus']).to be_nil
      end
    end

    context 'when user is a composite identity user' do
      let_it_be(:user) do
        create(:composite_identity_service_account_for_project, project: project)
      end

      let(:usage_quota_result) do
        ServiceResponse.success
      end

      before do
        allow_next_instance_of(
          ::Ai::UsageQuotaService,
          ai_feature: :duo_agent_platform,
          user: current_user
        ) do |instance|
          allow(instance).to receive(:execute).and_return(usage_quota_result)
        end
      end

      context 'and usage quota is not exceeded' do
        it 'returns the Duo status' do
          post_graphql(query, current_user: current_user)

          expect(user_data[0]['username']).to eq(user.username)
          expect(user_data[0]['duoStatus']).to match(
            'disabled' => false,
            'disabledReason' => ''
          )
        end
      end

      context 'and usage quota is exceeded' do
        let(:usage_quota_result) do
          ServiceResponse.error(reason: :usage_quota_exceeded, message: 'No credits available')
        end

        it 'returns the Duo status' do
          post_graphql(query, current_user: current_user)

          expect(user_data[0]['username']).to eq(user.username)
          expect(user_data[0]['duoStatus']).to match(
            'disabled' => true,
            'disabledReason' => 'Unavailable - no credits'
          )
        end
      end

      context 'when flowTriggerEvents are requested' do
        let(:usage_quota_result) do
          ServiceResponse.error(reason: :usage_quota_exceeded, message: 'No credits available')
        end

        let(:query_with_flow_trigger_events) do
          graphql_query_for(
            'project',
            { 'fullPath' => project.full_path },
            query_graphql_field(
              'autocompleteUsers',
              params,
              <<~QUERY
              username
              duoStatus {
                disabled
                disabledReason
                flowTriggerEvents
              }
              QUERY
            )
          )
        end

        before do
          create_flow_configuration_for_project(project, user, [1, 2])
        end

        it 'preloads flow triggers' do
          control_count = ActiveRecord::QueryRecorder.new do
            post_graphql(query, current_user: current_user)
          end

          expect do
            post_graphql(query_with_flow_trigger_events, current_user: current_user)
          end.not_to exceed_query_limit(control_count).with_threshold(1)

          expect(user_data[0]['username']).to eq(user.username)
          expect(user_data[0]['duoStatus']).to match(
            'disabled' => true,
            'disabledReason' => 'Unavailable - no credits',
            'flowTriggerEvents' => %w[ASSIGN ASSIGN_REVIEWER]
          )
        end
      end
    end
  end
end
