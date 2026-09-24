# frozen_string_literal: true

require "spec_helper"

RSpec.describe API::MergeRequests, feature_category: :code_review_workflow do
  include ProjectForksHelper

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :public, :repository) }
  let!(:merge_request) do
    create(:merge_request, :simple, author: user, source_project: project, target_project: project, title: "Test MR")
  end

  before_all do
    project.add_maintainer(user)
  end

  describe 'POST /projects/:id/merge_requests' do
    def create_merge_request(params)
      post api("/projects/#{project.id}/merge_requests", user), params: params
    end

    let(:default_params) do
      {
        title: 'Test MR with skip parameter',
        source_branch: 'feature_new',
        target_branch: 'master'
      }
    end

    before do
      project.repository.create_branch('feature_new', 'master')
    end

    context 'when creating with skip_mono_central_pipeline parameter' do
      it 'successfully creates merge request with skip_mono_central_pipeline set to true' do
        create_merge_request(
          default_params.merge(skip_mono_central_pipeline: true)
        )

        expect(response).to have_gitlab_http_status(:created)

        created_mr = MergeRequest.last
        expect(created_mr.title).to eq('Test MR with skip parameter')
        expect(created_mr.merge_params).to include('skip_mono_central_pipeline' => true)
      end

      it 'successfully creates merge request with skip_mono_central_pipeline set to false' do
        create_merge_request(
          default_params.merge(skip_mono_central_pipeline: false)
        )

        expect(response).to have_gitlab_http_status(:created)

        created_mr = MergeRequest.last
        expect(created_mr.merge_params).to include('skip_mono_central_pipeline' => false)
      end

      it 'accepts string values for skip_mono_central_pipeline parameter' do
        create_merge_request(
          default_params.merge(skip_mono_central_pipeline: "true")
        )

        expect(response).to have_gitlab_http_status(:created)

        created_mr = MergeRequest.last
        expect(created_mr.merge_params).to include('skip_mono_central_pipeline' => true)
      end

      it 'does not include skip_mono_central_pipeline in merge_params when not provided' do
        create_merge_request(default_params)

        expect(response).to have_gitlab_http_status(:created)

        created_mr = MergeRequest.last
        expect(created_mr.merge_params).not_to have_key('skip_mono_central_pipeline')
      end

      it 'can be combined with other parameters' do
        create_merge_request(
          default_params.merge(
            description: 'Test description',
            skip_mono_central_pipeline: true
          )
        )

        expect(response).to have_gitlab_http_status(:created)

        created_mr = MergeRequest.last
        expect(created_mr.title).to eq('Test MR with skip parameter')
        expect(created_mr.description).to eq('Test description')
        expect(created_mr.merge_params).to include('skip_mono_central_pipeline' => true)
      end
    end
  end
end
