# frozen_string_literal: true

require "spec_helper"

# rubocop:disable RSpec/SpecFilePathFormat -- JSON-RPC has single path for method invocation
RSpec.describe API::Mcp, 'List tools request', feature_category: :mcp_server do
  let_it_be(:user) { create(:user) }
  let_it_be(:access_token) { create(:oauth_access_token, user: user, scopes: [:mcp]) }

  before do
    stub_application_setting(instance_level_ai_beta_features_enabled: true, duo_features_enabled: true)
    stub_ee_application_setting(elasticsearch_search: true)
    allow(::Search::Zoekt).to receive(:search_enabled?).and_return(true)

    manager = ObjectSpace.each_object(Mcp::Tools::Manager).first
    manager.instance_variable_set(:@mcp_routes, nil)
    manager.instance_variable_set(:@tools, nil)
    manager.instance_variable_set(:@api_tools, nil)
    manager.instance_variable_set(:@aggregated_api_tools, nil)
  end

  describe 'POST /mcp with tools/list method' do
    let(:params) do
      {
        jsonrpc: '2.0',
        method: 'tools/list',
        id: '1'
      }
    end

    def post_list_tools
      post api('/mcp', user, oauth_access_token: access_token), params: params
    end

    it 'returns success' do
      post_list_tools

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response['jsonrpc']).to eq(params[:jsonrpc])
      expect(json_response['id']).to eq(params[:id])
      expect(json_response.keys).to include('result')
    end

    it 'returns tools' do
      post_list_tools

      expect(json_response['result']['tools']).to be_present
    end

    it 'registers and surfaces every MCP tool defined in the codebase', :eager_load, :aggregate_failures do
      defined_tools = Mcp::Tools::Base::BaseService.descendants
        .reject { |klass| klass.superclass == Mcp::Tools::Base::BaseService }

      expect(defined_tools).not_to be_empty, 'No MCP tool services were discovered'

      surfaced_tools = Mcp::Tools::Manager.new.list_tools.values.map(&:class)

      unregistered = defined_tools - surfaced_tools

      expect(unregistered).to be_empty,
        "Tool services defined but not registered in Mcp::Tools::Manager: #{unregistered.map(&:name).join(', ')}"
    end

    it 'locks each tool to its publicly-contracted annotations', :aggregate_failures do
      post_list_tools

      expected_annotations = {
        # write, non-destructive
        'add_branch' => { 'readOnlyHint' => false, 'destructiveHint' => false },
        'save_merge_request' => { 'readOnlyHint' => false, 'destructiveHint' => false },
        'fork_repository' => { 'readOnlyHint' => false, 'destructiveHint' => false },
        'link_work_items' => { 'readOnlyHint' => false, 'destructiveHint' => false },
        'save_merge_request_review' => { 'readOnlyHint' => false, 'destructiveHint' => false },
        'save_note' => { 'readOnlyHint' => false, 'destructiveHint' => false },
        'save_work_item' => { 'readOnlyHint' => false, 'destructiveHint' => false },
        'attach_scan_profile' => { 'destructiveHint' => false, 'readOnlyHint' => false },
        'save_vulnerability' => { 'readOnlyHint' => false, 'destructiveHint' => false },
        # write, destructive
        'accept_merge_request' => { 'readOnlyHint' => false, 'destructiveHint' => true },
        'add_commit' => { 'readOnlyHint' => false, 'destructiveHint' => true },
        'manage_pipeline' => { 'readOnlyHint' => false, 'destructiveHint' => true },
        'save_pipeline' => { 'readOnlyHint' => false, 'destructiveHint' => true },
        # read-only
        'get_commit' => { 'readOnlyHint' => true },
        'get_duo_session' => { 'readOnlyHint' => true },
        'get_issue' => { 'readOnlyHint' => true },
        'get_job' => { 'readOnlyHint' => true },
        'get_mcp_server_version' => { 'readOnlyHint' => true },
        'get_merge_request' => { 'readOnlyHint' => true },
        'get_merge_request_commits' => { 'readOnlyHint' => true },
        'get_merge_request_conflicts' => { 'readOnlyHint' => true },
        'get_merge_request_diffs' => { 'readOnlyHint' => true },
        'get_merge_request_notes' => { 'readOnlyHint' => true },
        'get_merge_request_pipelines' => { 'readOnlyHint' => true },
        'get_pipeline' => { 'readOnlyHint' => true },
        'get_pipeline_jobs' => { 'readOnlyHint' => true },
        'get_project' => { 'readOnlyHint' => true },
        'get_repository_file' => { 'readOnlyHint' => true },
        'get_saved_view_work_items' => { 'readOnlyHint' => true },
        'get_user' => { 'readOnlyHint' => true },
        'get_vulnerability' => { 'readOnlyHint' => true },
        'get_work_item' => { 'readOnlyHint' => true },
        'get_work_item_types' => { 'readOnlyHint' => true },
        'list_commits' => { 'readOnlyHint' => true },
        'list_branches' => { 'readOnlyHint' => true },
        'list_duo_sessions' => { 'readOnlyHint' => true },
        'list_groups' => { 'readOnlyHint' => true },
        'list_merge_requests' => { 'readOnlyHint' => true },
        'list_project_members' => { 'readOnlyHint' => true },
        'list_pipelines' => { 'readOnlyHint' => true },
        'list_projects' => { 'readOnlyHint' => true },
        'list_releases' => { 'readOnlyHint' => true },
        'list_repository_tree' => { 'readOnlyHint' => true },
        'list_tags' => { 'readOnlyHint' => true },
        'list_vulnerabilities' => { 'readOnlyHint' => true },
        'list_work_items' => { 'readOnlyHint' => true },
        'search' => { 'readOnlyHint' => true },
        'search_labels' => { 'readOnlyHint' => true },
        'semantic_search' => { 'readOnlyHint' => true },
        'list_wiki_pages' => { 'readOnlyHint' => true }
      }

      actual_annotations = json_response['result']['tools'].to_h { |tool| [tool['name'], tool['annotations']] }

      expect(actual_annotations).to eq(expected_annotations)
    end
  end
end
# rubocop:enable RSpec/SpecFilePathFormat
