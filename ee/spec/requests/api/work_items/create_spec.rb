# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::WorkItems::Create, feature_category: :portfolio_management do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :private, reporters: user) }

  before do
    stub_feature_flags(work_item_rest_api: user)
  end

  describe 'POST /namespaces/:id/-/work_items' do
    context 'when namespace is a group namespace and epics are supported' do
      let_it_be(:epic_type) { ::WorkItems::TypesFramework::Provider.new.find_by_base_type(:epic) }

      before do
        stub_licensed_features(epics: true)
      end

      it 'creates a group-level work item via the namespace endpoint' do
        post api("/namespaces/#{CGI.escape(group.full_path)}/-/work_items", user), params: {
          title: 'Group epic via namespace',
          work_item_type_id: epic_type.id
        }

        expect(response).to have_gitlab_http_status(:created)
        expect(json_response['title']).to eq('Group epic via namespace')
      end

      it_behaves_like 'authorizing granular token permissions', :create_work_item do
        let(:boundary_object) { group }
        let(:request) do
          post api("/namespaces/#{CGI.escape(group.full_path)}/-/work_items", personal_access_token: pat),
            params: { title: 'Group epic via namespace', work_item_type_id: epic_type.id }
        end
      end
    end
  end

  describe 'POST /groups/:id/-/work_items' do
    let(:api_request_path) { "/groups/#{group.id}/-/work_items" }

    context 'when group work items are supported (epic type)' do
      let_it_be(:epic_type) { ::WorkItems::TypesFramework::Provider.new.find_by_base_type(:epic) }

      before do
        stub_licensed_features(epics: true)
      end

      it 'creates a group-level work item' do
        post api(api_request_path, user), params: {
          title: 'Group epic',
          work_item_type_id: epic_type.id
        }

        expect(response).to have_gitlab_http_status(:created)
        expect(json_response['title']).to eq('Group epic')
      end

      it_behaves_like 'authorizing granular token permissions', :create_work_item do
        let(:boundary_object) { group }
        let(:request) do
          post api("/groups/#{group.id}/-/work_items", personal_access_token: pat),
            params: { title: 'Group epic', work_item_type_id: epic_type.id }
        end
      end
    end
  end
end
