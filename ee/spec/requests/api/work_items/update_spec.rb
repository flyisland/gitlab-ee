# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::WorkItems::Update, feature_category: :portfolio_management do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :private, reporters: user) }
  let_it_be(:work_item) { create(:work_item, :group_level, namespace: group) }

  before do
    stub_feature_flags(work_item_rest_api: user)
    stub_licensed_features(epics: true)
  end

  describe 'PATCH /groups/:id/-/work_items/:work_item_iid' do
    let(:api_request_path) { "/groups/#{group.id}/-/work_items/#{work_item.iid}" }

    it 'updates the work item' do
      patch api(api_request_path, user), params: { title: 'Updated title' }

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response['title']).to eq('Updated title')
      expect(work_item.reload.title).to eq('Updated title')
    end

    it_behaves_like 'authorizing granular token permissions', :update_work_item do
      let(:boundary_object) { group }
      let(:request) do
        patch api(api_request_path, personal_access_token: pat), params: { title: 'Updated title' }
      end
    end
  end
end
