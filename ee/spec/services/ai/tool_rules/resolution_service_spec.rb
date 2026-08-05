# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::ToolRules::ResolutionService, feature_category: :ai_agents do
  let_it_be_with_reload(:namespace) { create(:group) }

  let(:surface) { :web }
  let(:result) { service.execute }

  subject(:service) { described_class.new(namespace: namespace, surface: surface) }

  before do
    ::Ai::ToolRules::Registry.instance_variable_set(:@all_tool_names, nil)
    ::Ai::ToolRules::Registry.instance_variable_set(:@catalog_tool_names, nil)
    ::Ai::ToolRules::Registry.instance_variable_set(:@action_type_for, nil)
  end

  describe '#execute' do
    it 'returns a success response' do
      expect(result).to be_success
    end

    it 'always includes START_FLOWS in both privilege lists' do
      expect(result.payload[:agent_privileges]).to include(
        ::Ai::DuoWorkflows::Workflow::AgentPrivileges::START_FLOWS
      )
      expect(result.payload[:pre_approved_agent_privileges]).to include(
        ::Ai::DuoWorkflows::Workflow::AgentPrivileges::START_FLOWS
      )
    end

    context 'when namespace has no settings' do
      before do
        namespace.namespace_settings.destroy!
        namespace.reload
      end

      it 'falls back to :ask and returns no pre_approved_tools' do
        expect(result.payload[:pre_approved_tools]).to be_empty
      end
    end

    context 'when no rules exist for the namespace' do
      context 'when fallback is :ask (default_on)' do
        before do
          namespace.namespace_settings.update!(
            tool_approval_for_session_availability: :default_on
          )
        end

        it 'includes all privilege group constants in agent_privileges' do
          expect(result.payload[:agent_privileges]).to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_GITLAB,
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
          )
        end

        it 'returns empty tools' do
          expect(result.payload[:pre_approved_tools]).to be_empty
          expect(result.payload[:denied_tools]).to be_empty
        end

        it 'does not include groups in pre_approved_agent_privileges' do
          expect(result.payload[:pre_approved_agent_privileges]).to match_array(
            [::Ai::DuoWorkflows::Workflow::AgentPrivileges::START_FLOWS]
          )
        end
      end

      context 'when fallback is :allow (default_off)' do
        before do
          namespace.namespace_settings.update!(
            tool_approval_for_session_availability: :default_off
          )
        end

        it 'includes all privilege group constants in pre_approved_agent_privileges' do
          expect(result.payload[:pre_approved_agent_privileges]).to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_GITLAB,
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
          )
        end

        it 'returns pre_approved_tools when no explicit rules exist but the fallback is approve' do
          expect(result.payload[:pre_approved_tools]).not_to be_empty
        end
      end
    end

    context 'when rules exist for the namespace' do
      context 'when a group has a deny rule' do
        before do
          create(:ai_tool_rule, namespace: namespace, tool_name: 'create_issue', web_access: :deny)
        end

        it 'excludes the group constant from agent_privileges' do
          expect(result.payload[:agent_privileges]).not_to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
          )
        end

        it 'excludes the group from pre_approved_agent_privileges' do
          expect(result.payload[:pre_approved_agent_privileges]).not_to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
          )
        end

        it 'includes the tool in denied_tools' do
          expect(result.payload[:denied_tools]).to include('create_work_item')
        end
      end

      context 'when a group has an ask rule' do
        before do
          create(:ai_tool_rule, namespace: namespace, tool_name: 'create_issue', web_access: :ask)
        end

        it 'includes the group constant in agent_privileges' do
          expect(result.payload[:agent_privileges]).to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
          )
        end

        it 'excludes the group from pre_approved_agent_privileges' do
          expect(result.payload[:pre_approved_agent_privileges]).not_to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
          )
        end

        it 'does not include the tool in pre_approved_tools' do
          expect(result.payload[:pre_approved_tools]).not_to include('create_work_item')
        end
      end

      context 'when a group has an allow rule' do
        before do
          create(:ai_tool_rule, namespace: namespace, tool_name: 'create_issue', web_access: :allow)
        end

        it 'includes the group constant in agent_privileges' do
          expect(result.payload[:agent_privileges]).to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
          )
        end

        it 'includes the group constant in pre_approved_agent_privileges' do
          expect(result.payload[:pre_approved_agent_privileges]).to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
          )
        end

        it 'includes the MCP tool name in pre_approved_tools' do
          expect(result.payload[:pre_approved_tools]).to include('create_work_item')
        end
      end

      context 'when tools in a group have mixed permissions' do
        before do
          create(:ai_tool_rule, namespace: namespace, tool_name: 'create_issue', web_access: :allow)
          create(:ai_tool_rule, namespace: namespace, tool_name: 'update_issue', web_access: :deny)
        end

        it 'deny takes precedence over allow' do
          expect(result.payload[:agent_privileges]).not_to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
          )
        end

        it 'includes the allowed tool in pre_approved_tools' do
          expect(result.payload[:pre_approved_tools]).to include('create_work_item')
        end

        it 'includes the denied tool in denied_tools' do
          expect(result.payload[:denied_tools]).to include('update_issue')
        end
      end
    end

    context 'when read_only_files group has a rule' do
      context 'when a tool in the group is denied' do
        before do
          create(:ai_tool_rule, namespace: namespace, tool_name: 'read_file', web_access: :deny)
        end

        it 'excludes READ_ONLY_FILES from agent_privileges and includes the tool in denied_tools',
          :aggregate_failures do
          expect(result.payload[:agent_privileges]).not_to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_FILES
          )
          expect(result.payload[:denied_tools]).to include('read_file')
        end
      end

      context 'when the fallback permission is :allow (default_off)' do
        before do
          namespace.namespace_settings.update!(tool_approval_for_session_availability: :default_off)
        end

        it 'includes READ_ONLY_FILES in both agent_privileges and pre_approved_agent_privileges',
          :aggregate_failures do
          expect(result.payload[:agent_privileges]).to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_FILES
          )
          expect(result.payload[:pre_approved_agent_privileges]).to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_FILES
          )
        end
      end
    end

    context 'when surface is local' do
      let(:surface) { :local }

      before do
        create(:ai_tool_rule, namespace: namespace, tool_name: 'create_issue',
          web_access: :deny, local_access: :allow)
      end

      it 'uses local_access instead of web_access' do
        expect(result.payload[:pre_approved_agent_privileges]).to include(
          ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
        )
      end
    end

    context 'when surface is ambient' do
      let(:surface) { :ambient }

      before do
        create(:ai_tool_rule, namespace: namespace, tool_name: 'create_issue', web_access: :allow)
      end

      it 'treats ambient as a web surface' do
        expect(result.payload[:pre_approved_agent_privileges]).to include(
          ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
        )
      end
    end

    context 'when project is provided' do
      let_it_be(:project) { create(:project, namespace: namespace) }

      subject(:service) { described_class.new(namespace: namespace, surface: surface, project: project) }

      context 'when project has no rules — inherits namespace rules' do
        before do
          create(:ai_tool_rule, namespace: namespace, tool_name: 'create_issue', web_access: :ask)
        end

        it 'uses the namespace rule', :aggregate_failures do
          expect(result.payload[:agent_privileges]).to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
          )
          expect(result.payload[:pre_approved_agent_privileges]).not_to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
          )
        end
      end

      context 'when project escalates namespace rule (ask → deny)' do
        before do
          create(:ai_tool_rule, namespace: namespace, tool_name: 'create_issue', web_access: :ask)
          create(:ai_tool_rule, namespace: namespace, project: project, tool_name: 'create_issue', web_access: :deny)
        end

        it 'applies the more restrictive project rule', :aggregate_failures do
          expect(result.payload[:agent_privileges]).not_to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
          )
          expect(result.payload[:denied_tools]).to include('create_work_item')
        end
      end

      context 'when only a project rule exists with no namespace rule' do
        before do
          create(:ai_tool_rule, namespace: namespace, project: project, tool_name: 'create_issue', web_access: :deny)
        end

        it 'applies the project rule' do
          expect(result.payload[:denied_tools]).to include('create_work_item')
        end
      end

      context 'when namespace rule has nil for the queried surface' do
        before do
          namespace.namespace_settings.update!(tool_approval_for_session_availability: :default_on)
          create(:ai_tool_rule, namespace: namespace, tool_name: 'create_issue', web_access: nil, local_access: :deny)
          create(:ai_tool_rule, namespace: namespace, project: project, tool_name: 'create_issue', web_access: :allow)
        end

        it 'allows project rule to set the unconfigured surface' do
          expect(result.payload[:pre_approved_tools]).to include('create_work_item')
        end
      end

      context 'when project rule has nil for the queried surface' do
        before do
          create(:ai_tool_rule, namespace: namespace, tool_name: 'create_issue', web_access: :ask)
          create(:ai_tool_rule, namespace: namespace, project: project, tool_name: 'create_issue', web_access: nil,
            local_access: :deny)
        end

        it 'keeps the namespace rule for the unconfigured surface', :aggregate_failures do
          expect(result.payload[:agent_privileges]).to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
          )
          expect(result.payload[:pre_approved_agent_privileges]).not_to include(
            ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
          )
        end
      end
    end
  end
end
