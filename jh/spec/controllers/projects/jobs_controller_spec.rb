# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::JobsController, feature_category: :continuous_integration do
  let_it_be(:project) { create(:project, :public) }

  describe '#raw_redirect_params' do
    subject(:redirect_query) { controller.send(:raw_redirect_params)[:query] }

    before do
      allow(controller).to receive(:project).and_return(project)
    end

    it 'omits response-content-type when the feature flag is enabled', :aggregate_failures do
      expect(redirect_query).not_to have_key('response-content-type')
      expect(redirect_query['response-content-disposition']).to eq('inline')
    end

    context 'when jh_hidden_oss_content_type is disabled' do
      before do
        stub_feature_flags(jh_hidden_oss_content_type: false)
      end

      it 'keeps the upstream response-content-type override', :aggregate_failures do
        expect(redirect_query['response-content-type']).to eq('text/plain; charset=utf-8')
        expect(redirect_query['response-content-disposition']).to eq('inline')
      end
    end
  end

  describe 'PATCH update_tags' do
    let(:project) { create(:project, :repository, maintainers: maintainer, developers: developer, reporters: reporter) }
    let(:maintainer) { create(:user) }
    let(:developer) { create(:user) }
    let(:reporter) { create(:user) }
    let(:user) { maintainer }
    let(:pipeline) { create(:ci_pipeline, project: project) }

    let(:job) { create(:ci_build, :pending, pipeline: pipeline, tag_list: ['runner-a']) }
    let(:tags) { ['runner-b'] }

    before do
      stub_not_protect_default_branch
      sign_in(user)
    end

    subject(:update_tags) do
      patch :update_tags, params: {
        namespace_id: project.namespace.to_param, project_id: project, id: job.id, tags: tags
      }, format: :json
    end

    it 'updates the tags for a maintainer' do
      update_tags

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response['tags']).to eq(tags)
      expect(job.reload.job_definition.tag_list).to eq(tags)
    end

    context 'when the user is an administrator', :enable_admin_mode do
      let(:user) { create(:admin) }

      it 'updates the tags' do
        update_tags

        expect(response).to have_gitlab_http_status(:ok)
        expect(job.reload.job_definition.tag_list).to eq(tags)
      end
    end

    context 'when the user is anonymous' do
      before do
        sign_out(user)
      end

      it 'requires authentication without changing the tags' do
        update_tags

        expect(response).to redirect_to(new_user_session_path)
        expect(job.reload.job_definition.tag_list).to eq(['runner-a'])
      end
    end

    context 'when the user is a developer who can retry the job' do
      let(:user) { developer }

      it 'denies access without changing the tags' do
        expect(Ability.allowed?(user, :retry_job, job)).to be(true)

        update_tags

        expect(response).to have_gitlab_http_status(:not_found)
        expect(job.reload.job_definition.tag_list).to eq(['runner-a'])
      end
    end

    context 'when the user cannot retry the job' do
      let(:user) { reporter }

      it 'denies access' do
        update_tags

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when the job is running' do
      let(:job) { create(:ci_build, :running, pipeline: pipeline) }

      it 'returns a conflict' do
        update_tags

        expect(response).to have_gitlab_http_status(:conflict)
      end
    end

    context 'when the tags exceed the limit' do
      let(:tags) { Array.new(50) { |i| "tag-#{i}" } }

      it 'rejects the tags' do
        update_tags

        expect(response).to have_gitlab_http_status(:unprocessable_entity)
      end
    end
  end
end
