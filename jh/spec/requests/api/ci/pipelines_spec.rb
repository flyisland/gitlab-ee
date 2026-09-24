# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Ci::Pipelines, feature_category: :continuous_integration do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :repository, creator: user, maintainers: user) }

  describe 'POST /projects/:id/pipeline' do
    context 'without gitlab-ci.yml' do
      it 'fails to create pipeline', :aggregate_failures do
        post api("/projects/#{project.id}/pipeline", user), params: { ref: project.default_branch }

        expect(response).to have_gitlab_http_status(:bad_request)
      end

      context 'when send param `ci_config_path`' do
        before do
          stub_request(:get, ci_config_path).to_return(status: 200, body: ci_config_content, headers: {})
        end

        let(:ci_config_path) { 'https://example.com/example.yml' }
        let(:ci_config_content) { "test-job:\n  script:\n    - echo Hello" }

        it 'creates and returns a new pipeline', :aggregate_failures do
          expect do
            post api("/projects/#{project.id}/pipeline", user),
              params: { ref: project.default_branch, ci_config_path: ci_config_path }
          end.to change { project.ci_pipelines.in_partition(Ci::Pipeline.current_partition_value).count }.by(1)

          expect(response).to have_gitlab_http_status(:created)
          expect(json_response).to be_a Hash
          expect(json_response['sha']).to eq project.commit.id
        end

        context 'when `ci_config_path` is invalid' do
          let(:ci_config_content) { 'some invalid configuration' }

          it 'fails to create pipeline', :aggregate_failures do
            post api("/projects/#{project.id}/pipeline", user),
              params: { ref: project.default_branch, ci_config_path: ci_config_path }

            expect(response).to have_gitlab_http_status(:bad_request)
            expect(json_response['message']['base'].first).to eq "`#{ci_config_path}`: Invalid configuration format"
          end
        end
      end
    end
  end
end
