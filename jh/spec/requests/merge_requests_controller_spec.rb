# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Projects::MergeRequestsController', feature_category: :source_code_management do
  let_it_be(:merge_request) { create(:merge_request) }
  let_it_be(:project) { merge_request.project }
  let_it_be(:user) { merge_request.author }

  describe 'GET #pipelines.json' do
    before do
      login_as(user)
    end

    describe '#rapid_diffs' do
      before do
        allow_any_instance_of(RapidDiffs::AppComponent).to receive(:initial_sidebar_width).and_return(
          { mr_tree_list_width: '250' }
        )
        allow_any_instance_of(RapidDiffs::AppComponent).to receive(:browser_visible?).and_return(
          false
        )
      end

      it 'returns 200' do
        get diffs_project_merge_request_path(project, merge_request, rapid_diffs: 'true')

        expect(response).to have_gitlab_http_status(:ok)
        expect(response.body).to include('data-rapid-diffs')
      end

      it 'shows only first 5 files' do
        get diffs_project_merge_request_path(project, merge_request, rapid_diffs: 'true')

        expect(response.body.scan('<diff-file ').size).to eq(5)
      end
    end
  end
end
