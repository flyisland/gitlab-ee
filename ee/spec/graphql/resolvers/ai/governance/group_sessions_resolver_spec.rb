# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Ai::Governance::GroupSessionsResolver, :click_house,
  feature_category: :compliance_management do
  include GraphqlHelpers
  include Ai::Governance::SessionClickHouseHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:other_user) { create(:user) }
  let_it_be(:member_role) { create(:member_role, :guest, :read_agent_artifacts, namespace: group) }
  let_it_be(:membership) { create(:group_member, :guest, member_role: member_role, user: user, group: group) }
  let_it_be(:reference_time) { Time.current.change(usec: 0) }

  let(:duo_session_id) { 1 }
  let(:external_session_id) { 2 }
  let(:current_user) { user }
  let(:args) { {} }

  subject(:resolved) { resolve(described_class, obj: group, args: args, ctx: { current_user: current_user }) }

  before do
    stub_licensed_features(
      custom_roles: true,
      project_level_compliance_dashboard: true,
      group_level_compliance_dashboard: true
    )
    allow(::Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(true)

    insert_ai_governance_sessions(
      ai_governance_session_row(id: duo_session_id, namespace: project.project_namespace, project: project,
        user: user, flow_type: 'chat', session_started_at: reference_time - 2.hours),
      ai_governance_session_row(id: external_session_id, namespace: group, user: other_user,
        source: :claude_code_compliance_api, flow_type: 'claude_code', session_started_at: reference_time - 1.hour)
    )
  end

  def resolved_ids
    ai_governance_session_ids(resolved.items)
  end

  it 'returns the sessions of the group, newest first' do
    expect(resolved_ids).to eq([external_session_id, duo_session_id])
  end

  context 'when the feature flag is disabled' do
    before do
      stub_feature_flags(ai_governance_sessions_api: false)
    end

    it 'returns no sessions' do
      expect(resolved).to be_empty
    end
  end

  context 'when ClickHouse is not enabled for analytics' do
    before do
      allow(::Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(false)
    end

    it 'returns no sessions without querying ClickHouse' do
      expect(::Ai::Governance::Sessions::ClickHouseFinder).not_to receive(:new)

      expect(resolved).to be_empty
    end
  end

  context 'when the user cannot read agent artifacts' do
    let(:current_user) { create(:user) }

    it 'returns no sessions' do
      expect(resolved_ids).to be_empty
    end
  end

  describe 'agent class' do
    using RSpec::Parameterized::TableSyntax

    where(:agent_class, :expected_ids) do
      'ALL'          | [2, 1]
      'INTERNAL_DAP' | [1]
      'EXTERNAL'     | [2]
    end

    with_them do
      let(:args) { { agent_class: agent_class } }

      it 'filters on the session source' do
        expect(resolved_ids).to eq(expected_ids)
      end
    end
  end

  context 'with a flow type filter' do
    let(:args) { { flow_type: 'chat' } }

    it 'returns matching sessions' do
      expect(resolved_ids).to eq([duo_session_id])
    end
  end

  context 'with a project path filter' do
    let(:args) { { project_path: project.full_path } }

    it 'returns the sessions of the project' do
      expect(resolved_ids).to eq([duo_session_id])
    end
  end

  context 'with a triggered by user filter' do
    let(:args) { { triggered_by_user_id: global_id_of(other_user) } }

    it 'returns sessions triggered by the user' do
      expect(resolved_ids).to eq([external_session_id])
    end
  end

  context 'with a session start range' do
    let(:args) do
      { session_started_after: reference_time - 3.hours, session_started_before: reference_time - 90.minutes }
    end

    it 'returns sessions started within the range' do
      expect(resolved_ids).to eq([duo_session_id])
    end
  end

  context 'when sessionStartedAfter equals sessionStartedBefore' do
    let(:args) { { session_started_after: reference_time - 1.hour, session_started_before: reference_time - 1.hour } }

    it 'returns sessions started at that time' do
      expect(resolved_ids).to eq([external_session_id])
    end
  end

  context 'when sessionStartedAfter is after sessionStartedBefore' do
    let(:args) { { session_started_after: reference_time, session_started_before: reference_time - 1.hour } }

    it 'returns an argument error' do
      expect(resolved).to be_a(Gitlab::Graphql::Errors::ArgumentError)
      expect(resolved.message).to eq('sessionStartedAfter must not be after sessionStartedBefore')
    end

    context 'when the feature flag is disabled' do
      before do
        stub_feature_flags(ai_governance_sessions_api: false)
      end

      it 'returns an argument error' do
        expect(resolved).to be_a(Gitlab::Graphql::Errors::ArgumentError)
      end
    end
  end

  describe 'negated filters' do
    using RSpec::Parameterized::TableSyntax

    where(:not_args, :expected_ids) do
      { flow_type: 'chat' }              | [2]
      { project_path: 'does/not-exist' } | [2, 1]
      {}                                 | [2, 1]
    end

    with_them do
      let(:args) { { not: not_args } }

      it 'excludes matching sessions' do
        expect(resolved_ids).to eq(expected_ids)
      end
    end

    context 'with a negated project path' do
      let(:args) { { not: { project_path: project.full_path } } }

      it 'excludes the project but keeps namespace-scoped sessions' do
        expect(resolved_ids).to eq([external_session_id])
      end
    end

    context 'with a negated triggered by user' do
      let(:args) { { not: { triggered_by_user_id: global_id_of(other_user) } } }

      it 'passes the unwrapped user id to the finder' do
        expect(::Ai::Governance::Sessions::ClickHouseFinder).to receive(:new)
          .with(hash_including(params: hash_including(not: { user_id: other_user.id })))
          .and_call_original

        expect(resolved_ids).to eq([duo_session_id])
      end
    end
  end
end
