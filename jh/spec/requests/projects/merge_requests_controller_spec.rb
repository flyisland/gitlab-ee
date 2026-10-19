# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::MergeRequestsController, feature_category: :code_review_workflow do
  let_it_be(:group) { create(:group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :public, group: group) }
  let_it_be(:merge_request) { create :merge_request, source_project: project, author: user }

  describe 'POST bulk_merge' do
    subject(:request) do
      post "#{project_merge_request_path(project, merge_request)}/bulk_merge", params: { id: merge_request.id }
    end

    context 'when user is not logged in' do
      it 'returns 302' do
        request
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when user is logged in' do
      before_all do
        group.add_developer(user)
        login_as(user)
      end

      shared_examples 'renders 404' do
        it 'returns 404' do
          request
          expect(response).to have_gitlab_http_status(:not_found)
        end
      end

      context 'when "monorepo_enabled?" is false' do
        before do
          allow(::MergeRequests::MonorepoService).to receive(:monorepo_enabled?).and_return(false)
        end

        it_behaves_like 'renders 404'
      end

      context 'when "monorepo_enabled?" is true' do
        before do
          allow(::MergeRequests::MonorepoService).to receive(:monorepo_enabled?).and_return(true)
        end

        context 'when "bulk_merge!" raise an error' do
          before do
            allow_next_instance_of(MergeRequests::MonorepoService) do |monorepo_service|
              allow(monorepo_service).to receive(:bulk_merge!).and_raise(
                ::MergeRequests::MonorepoService::BulkMergeError.new('error-message')
              )
            end
          end

          it 'returns failed message' do
            request
            expect(response).to have_gitlab_http_status(:success)
            expect(json_response).to eq({ 'status' => 'failed', 'merge_error' => 'error-message' })
          end
        end

        context 'when "bulk_merge!" is successful' do
          before do
            allow_next_instance_of(MergeRequests::MonorepoService) do |monorepo_service|
              allow(monorepo_service).to receive(:bulk_merge!).and_return(true)
            end
          end

          it 'returns success message' do
            request
            expect(response).to have_gitlab_http_status(:success)
            expect(json_response).to eq({ 'status' => 'success' })
          end
        end
      end
    end
  end
end
