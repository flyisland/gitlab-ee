# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Querying audit events on a Duo Workflow', feature_category: :duo_agent_platform do
  include GraphqlHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :public, group: group) }
  let_it_be(:owner) { create(:user, developer_of: group) }
  let_it_be(:other_user) { create(:user) }
  let_it_be(:workflow) do
    create(:duo_workflows_workflow, project: project, user: owner)
  end

  let_it_be(:event_1) do
    create(:audit_events_ai_audit_event,
      target_project: project, user: owner, workflow_id: workflow.id,
      event_name: 'ai_agent_session_started', created_at: 3.minutes.ago)
  end

  let_it_be(:event_2) do
    create(:audit_events_ai_audit_event,
      target_project: project, user: owner, workflow_id: workflow.id,
      event_name: 'ai_llm_input_sent', created_at: 2.minutes.ago)
  end

  let_it_be(:event_3) do
    create(:audit_events_ai_audit_event,
      target_project: project, user: owner, workflow_id: workflow.id,
      event_name: 'ai_llm_response_received', created_at: 1.minute.ago)
  end

  let_it_be(:event_for_other_workflow) do
    other_workflow = create(:duo_workflows_workflow, project: project, user: owner)
    create(:audit_events_ai_audit_event,
      target_project: project, user: owner, workflow_id: other_workflow.id,
      event_name: 'ai_agent_session_started')
  end

  let(:variables) { { workflow_id: workflow.to_global_id.to_s } }
  let(:audit_events_args) { '' }

  let(:query) do
    fields = <<~GRAPHQL
      nodes {
        id
        auditEvents#{audit_events_args} {
          nodes {
            id
            eventName
            createdAt
            author {
              id
              username
            }
          }
          pageInfo {
            hasNextPage
            hasPreviousPage
            startCursor
            endCursor
          }
        }
      }
    GRAPHQL

    graphql_query_for('duoWorkflowWorkflows', variables, fields)
  end

  let(:current_user) { owner }

  subject(:returned_events) do
    graphql_data.dig('duoWorkflowWorkflows', 'nodes', 0, 'auditEvents', 'nodes')
  end

  before do
    # rubocop:disable RSpec/AnyInstanceOf -- not the next instance
    allow_any_instance_of(User).to receive_messages(allowed_to_use?: true, allowed_to_use_for_resource?: true)
    # rubocop:enable RSpec/AnyInstanceOf
    allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(any_args).and_return(true)
    # Default to the Postgres-backed reader. The ClickHouse-enabled path is
    # covered in its own context below.
    allow(::Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(false)
  end

  it 'returns audit events for the workflow only, ordered most recent first', :aggregate_failures do
    post_graphql(query, current_user: current_user)

    expect(response).to have_gitlab_http_status(:success)
    expect(graphql_errors).to be_nil

    expect(returned_events.length).to eq(3)

    # Order is enforced server-side via id DESC. eventName lets us identify
    # individual events without relying on the opaque GraphQL ID encoding.
    expect(returned_events.pluck('eventName')).to eq(
      %w[ai_llm_response_received ai_llm_input_sent ai_agent_session_started]
    )

    returned_ids = returned_events.pluck('id')
    # `id` is exposed as the canonical `cloud_event_id` UUID so that PG and
    # ClickHouse-backed reads produce stable identifiers.
    expect(returned_ids).to match_array(
      [event_3, event_2, event_1].map(&:cloud_event_id)
    )
    expect(returned_ids).not_to include(event_for_other_workflow.cloud_event_id)
  end

  it 'exposes eventName from the model' do
    post_graphql(query, current_user: current_user)

    names = returned_events.pluck('eventName')
    expect(names).to eq(%w[ai_llm_response_received ai_llm_input_sent ai_agent_session_started])
  end

  it 'returns the author user details' do
    post_graphql(query, current_user: current_user)

    authors = returned_events.pluck('author')
    expect(authors).to all(include('id' => owner.to_global_id.to_s, 'username' => owner.username))
  end

  it 'avoids N+1 queries when loading authors across multiple events' do
    create_list(:audit_events_ai_audit_event, 5,
      target_project: project, user: create(:user), workflow_id: workflow.id)

    control = ActiveRecord::QueryRecorder.new do
      post_graphql(query, current_user: current_user)
    end

    create_list(:audit_events_ai_audit_event, 5,
      target_project: project, user: create(:user), workflow_id: workflow.id)

    expect do
      post_graphql(query, current_user: current_user)
    end.not_to exceed_query_limit(control)
  end

  context 'with first/after pagination arguments' do
    let(:audit_events_args) { '(first: 2)' }

    it 'returns only the requested page', :aggregate_failures do
      post_graphql(query, current_user: current_user)

      expect(returned_events.length).to eq(2)
      expect(returned_events.pluck('eventName')).to eq(%w[ai_llm_response_received ai_llm_input_sent])

      page_info = graphql_data.dig('duoWorkflowWorkflows', 'nodes', 0, 'auditEvents', 'pageInfo')
      expect(page_info['hasNextPage']).to be(true)
    end
  end

  context 'when the user does not have access to the workflow' do
    let(:current_user) { other_user }

    before do
      # rubocop:disable RSpec/AnyInstanceOf -- not the next instance
      allow_any_instance_of(User).to receive_messages(allowed_to_use?: false, allowed_to_use_for_resource?: false)
      # rubocop:enable RSpec/AnyInstanceOf
    end

    it 'returns a permission error', :aggregate_failures do
      post_graphql(query, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)
      error = json_response['errors'].first
      expect(error['extensions']['code']).to eq('INSUFFICIENT_NAMESPACE_PERMISSIONS')
    end
  end

  context 'when the workflow has no audit events' do
    let(:variables) do
      empty_workflow = create(:duo_workflows_workflow, project: project, user: owner)
      { workflow_id: empty_workflow.to_global_id.to_s }
    end

    it 'returns an empty list', :aggregate_failures do
      post_graphql(query, current_user: current_user)

      expect(returned_events).to eq([])
    end
  end

  context 'when ClickHouse is globally enabled for analytics' do
    let(:ch_rows) do
      [
        {
          'id' => 1001,
          'cloud_event_id' => '00000000-0000-0000-0000-000000000003',
          'event_name' => 'ai_llm_response_received',
          'created_at' => 1.minute.ago.utc.strftime('%Y-%m-%d %H:%M:%S'),
          'workflow_id' => workflow.id.to_s,
          'ip_address' => '203.0.113.5',
          'details' => '{"latency_ms":42}',
          'author_id' => owner.id
        },
        {
          'id' => 1000,
          'cloud_event_id' => '00000000-0000-0000-0000-000000000002',
          'event_name' => 'ai_llm_input_sent',
          'created_at' => 2.minutes.ago.utc.strftime('%Y-%m-%d %H:%M:%S'),
          'workflow_id' => workflow.id.to_s,
          'ip_address' => '203.0.113.5',
          'details' => '{}',
          'author_id' => owner.id
        }
      ]
    end

    before do
      allow(::Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(true)
      ch_finder = instance_double(::AuditEvents::AiAuditEvents::ClickHouseFinder, execute: ch_rows)
      # `WorkflowType` uses `present_using ::Ai::DuoWorkflows::WorkflowPresenter`,
      # so the GraphQL object yielded to the finder is the presenter, not the raw model.
      allow(::AuditEvents::AiAuditEvents::ClickHouseFinder)
        .to receive(:new).and_return(ch_finder)
    end

    it 'returns ClickHouse-backed rows through the type', :aggregate_failures do
      post_graphql(query, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)
      expect(graphql_errors).to be_nil

      expect(returned_events.pluck('eventName')).to eq(
        %w[ai_llm_response_received ai_llm_input_sent]
      )
      expect(returned_events.pluck('id')).to eq(ch_rows.pluck('cloud_event_id'))
    end
  end

  context 'when the agent_artifacts_page feature flag is disabled' do
    before do
      stub_feature_flags(agent_artifacts_page: false)
    end

    it 'returns no audit events', :aggregate_failures do
      post_graphql(query, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)
      expect(graphql_errors).to be_nil
      expect(returned_events).to eq([])
    end

    context 'when the flag is enabled for a specific group only' do
      let_it_be(:other_group) { create(:group) }

      before do
        stub_feature_flags(agent_artifacts_page: other_group)
      end

      it 'still returns no events for workflows in other groups' do
        post_graphql(query, current_user: current_user)

        expect(returned_events).to eq([])
      end
    end
  end

  context 'when accessed by a compliance reviewer' do
    let(:current_user) { other_user }

    before_all do
      project.add_owner(other_user)
    end

    before do
      stub_licensed_features(
        group_level_compliance_dashboard: true,
        project_level_compliance_dashboard: true
      )
    end

    context 'with a foundational agent workflow' do
      let_it_be(:foundational_workflow) do
        create(:duo_workflows_workflow, project: project, user: owner,
          workflow_definition: 'security_analyst_agent/v1')
      end

      let_it_be(:foundational_event) do
        create(:audit_events_ai_audit_event,
          target_project: project, user: owner,
          workflow_id: foundational_workflow.id,
          event_name: 'ai_agent_session_started')
      end

      let(:variables) { { workflow_id: foundational_workflow.to_global_id.to_s } }

      it 'returns audit events', :aggregate_failures do
        post_graphql(query, current_user: current_user)

        expect(response).to have_gitlab_http_status(:success)
        expect(graphql_errors).to be_nil
        expect(returned_events.length).to eq(1)
        expect(returned_events.first['eventName']).to eq('ai_agent_session_started')
      end
    end

    context 'with a chat workflow' do
      let_it_be(:chat_workflow) do
        create(:duo_workflows_workflow, :agentic_chat, project: project, user: owner)
      end

      let(:variables) { { workflow_id: chat_workflow.to_global_id.to_s } }

      it 'returns a permission error', :aggregate_failures do
        post_graphql(query, current_user: current_user)

        expect(response).to have_gitlab_http_status(:success)
        error = json_response['errors'].first
        expect(error['extensions']['code']).to eq('INSUFFICIENT_NAMESPACE_PERMISSIONS')
      end
    end
  end
end
