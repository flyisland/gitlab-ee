# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Git HTTP requests' do
  include ProjectForksHelper
  include GitHttpHelpers
  include WorkhorseHelpers

  shared_examples_for 'pulls are allowed' do
    it 'allows pulls' do
      download(path, **env) do |response|
        expect(response).to have_gitlab_http_status(:ok)
        expect(response.media_type).to eq(Gitlab::Workhorse::INTERNAL_API_CONTENT_TYPE)
      end
    end
  end

  shared_examples_for 'pushes are allowed' do
    it 'allows pushes', :sidekiq_might_not_need_inline do
      upload(path, **env) do |response|
        expect(response).to have_gitlab_http_status(:ok)
        expect(response.media_type).to eq(Gitlab::Workhorse::INTERNAL_API_CONTENT_TYPE)
      end
    end
  end

  shared_examples_for 'from CI' do
    context 'as from CI' do
      let(:build) { create(:ci_build, :running) }
      let(:env) { { user: 'gitlab-ci-token', password: build.token } }

      before do
        build.update!(user: user, project: project)
      end

      it_behaves_like 'pulls are allowed'
    end
  end

  describe 'phone verification' do
    let(:project) { create(:project, :repository) }
    let(:user) { create(:user) }
    let(:path) { "#{project.full_path}.git" }
    let(:env) { { user: user.username, password: user.password } }

    before do
      project.add_maintainer(user)
    end

    context 'when it is not JH SaaS' do
      it_behaves_like 'from CI'
      it_behaves_like 'pulls are allowed'
      it_behaves_like 'pushes are allowed'
    end

    context 'when it is JH SaaS', :saas, :phone_verification_code_enabled do
      it_behaves_like 'from CI'

      it 'blocks git access when the user did not verify phone', :aggregate_failures do
        clone_get(path, **env) do |response|
          expect(response).to have_gitlab_http_status(:forbidden)
        end

        download(path, **env) do |response|
          expect(response).to have_gitlab_http_status(:forbidden)
        end

        upload(path, **env) do |response|
          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end

      context 'when the user verified phone' do
        before do
          user.update!(phone: 'phone')
        end

        it 'allows clones' do
          clone_get(path, **env) do |response|
            expect(response).to have_gitlab_http_status(:ok)
          end
        end

        it_behaves_like 'pulls are allowed'
        it_behaves_like 'pushes are allowed'
      end
    end
  end
end
