# frozen_string_literal: true

# rubocop:disable RSpec/VerifiedDoubles

require 'fast_spec_helper'
require 'rspec-parameterized'

require 'gitlab/error'
require 'gitlab/objectified_hash'

require_relative '../../../scripts/trigger-build'

RSpec.describe Trigger, feature_category: :tooling do
  let(:env) do
    {
      'CI_JOB_URL' => 'ci_job_url',
      'CI_PROJECT_PATH' => 'ci_project_path',
      'CI_COMMIT_REF_NAME' => 'ci_commit_ref_name',
      'CI_COMMIT_REF_SLUG' => 'ci_commit_ref_slug',
      'CI_COMMIT_SHA' => 'ci_commit_sha',
      'CI_MERGE_REQUEST_PROJECT_ID' => 'ci_merge_request_project_id',
      'CI_MERGE_REQUEST_IID' => 'ci_merge_request_iid',
      'PROJECT_TOKEN_FOR_CI_SCRIPTS_API_USAGE' => 'bot-token',
      'CI_JOB_TOKEN' => 'job-token',
      'GITLAB_USER_NAME' => 'gitlab_user_name',
      'GITLAB_USER_LOGIN' => 'gitlab_user_login',
      'QA_IMAGE' => 'qa_image',
      'DOCS_PROJECT_API_TOKEN' => nil,
      'CNG_SKIP_REDUNDANT_JOBS' => "false"
    }
  end

  let(:com_api_endpoint) { Trigger::Base.new.send(:endpoint) }
  let(:com_api_token) { env['PROJECT_TOKEN_FOR_CI_SCRIPTS_API_USAGE'] }
  let(:com_gitlab_client) { double('com_gitlab_client') }

  let(:downstream_gitlab_client_endpoint) { com_api_endpoint }
  let(:downstream_gitlab_client_token) { com_api_token }
  let(:downstream_gitlab_client) { com_gitlab_client }

  let(:stubbed_pipeline) { Struct.new(:id, :web_url).new(42, 'pipeline_url') }
  let(:trigger_token) { env['CI_JOB_TOKEN'] }

  before do
    stub_env(env)
    allow(subject).to receive(:puts)
    allow(Gitlab).to receive(:client)
      .with(
        endpoint: downstream_gitlab_client_endpoint,
        private_token: downstream_gitlab_client_token
      )
      .and_return(downstream_gitlab_client)
  end

  describe Trigger::CNG do
    describe '#variables' do
      describe 'with specific commit sha' do
        let(:downstream_project_path) { 'gitlab-org/build/cng' }
        let(:sha) { '3f1b1cdc5209' }
        let(:trigger_ref) { "trigger-refs/#{sha}" }

        let(:response) do
          Gitlab::ObjectifiedHash.new(
            code: 404,
            parsed_response: "Failure",
            request: { base_uri: "gitlab.com", path: "/branch" }
          )
        end

        before do
          stub_env('CNG_PROJECT_PATH', downstream_project_path)
          stub_env('CNG_COMMIT_SHA', sha)

          stub_env('CI_MERGE_REQUEST_TARGET_BRANCH_NAME', 'main-jh')

          allow(downstream_gitlab_client).to receive(:branch).with(downstream_project_path, trigger_ref).and_raise(
            Gitlab::Error::ResponseError.new(response)
          )
          allow(downstream_gitlab_client).to receive(:create_branch).with(downstream_project_path, trigger_ref, sha)
        end

        context 'when trigger ref branch creation fails' do
          before do
            allow(downstream_gitlab_client).to receive(:create_branch).and_raise("failed to create branch")
          end

          it "falls back to default ref" do
            expect(subject.variables).to include({
              "TRIGGER_BRANCH" => "main-jh"
            })
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/VerifiedDoubles
