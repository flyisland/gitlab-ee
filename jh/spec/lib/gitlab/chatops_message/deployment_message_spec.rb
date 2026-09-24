# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ChatopsMessage::DeploymentMessage do
  subject { described_class.new(args) }

  let_it_be(:user) { create(:user, name: 'John Smith', username: 'smith') }
  let_it_be(:namespace) { create(:namespace, name: 'myspace') }
  let_it_be(:project) { create(:project, :repository, namespace: namespace, path: 'myproject') }
  let_it_be(:commit, freeze: false) { project.commit('HEAD') }
  let_it_be(:ci_build) { create(:ci_build, project: project) }
  let_it_be(:environment) { create(:environment, name: 'myenvironment', project: project) }
  let_it_be(:deployment) do
    create(:deployment, status: :success, deployable: ci_build,
      environment: environment, project: project, user: user, sha: commit.sha)
  end

  let(:args) do
    { markdown: true }.merge(Gitlab::DataBuilder::Deployment.build(deployment, 'success', Time.current))
  end

  describe '#message' do
    it 'returns a message with the data returned by the deployment data builder' do
      expect(subject.pretext).to eq("Deploy to myenvironment Succeeded")
    end

    it 'returns a message for a successful deployment' do
      args.merge!(
        status: 'success',
        environment: 'production'
      )

      expect(subject.pretext).to eq('Deploy to production Succeeded')
    end

    it 'returns a message for a failed deployment' do
      args.merge!(
        status: 'failed',
        environment: 'production'
      )

      expect(subject.pretext).to eq('Deploy to production Failed')
    end

    it 'returns a message for a canceled deployment' do
      args.merge!(
        status: 'canceled',
        environment: 'production'
      )

      expect(subject.pretext).to eq('Deploy to production Cancelled')
    end

    it 'returns a message for a deployment to another environment' do
      args.merge!(
        status: 'success',
        environment: 'staging'
      )

      expect(subject.pretext).to eq('Deploy to staging Succeeded')
    end

    it 'returns a message for a deployment with any other status' do
      args.merge!(
        status: 'unknown',
        environment: 'staging'
      )

      expect(subject.pretext).to eq('Deploy to staging Unknown')
    end

    it 'returns a message for a running deployment' do
      args.merge!(
        status: 'running',
        environment: 'production'
      )

      expect(subject.pretext).to eq('Starting deploy to production')
    end
  end

  describe '#attachments' do
    def deployment_data(params)
      {
        object_kind: "deployment",
        status: "success",
        deployable_id: 3,
        deployable_url: "deployable_url",
        environment: "sandbox",
        project: {
          name: "greatproject",
          web_url: "project_web_url",
          path_with_namespace: "project_path_with_namespace"
        },
        user: {
          name: "Jane Person",
          username: "jane"
        },
        user_url: "user_url",
        short_sha: "12345678",
        commit_url: "commit_url",
        commit_title: "commit title text"
      }.merge(params)
    end

    it 'returns attachments with the data returned by the deployment data builder' do
      job_url = Gitlab::Routing.url_helpers.project_job_url(project, ci_build)
      commit_url = Gitlab::UrlBuilder.build(deployment.commit)
      user_url = Gitlab::Routing.url_helpers.user_url(user)

      expect(subject.attachments).to include("[myspace/myproject](#{project.web_url}) with job " \
        "[##{ci_build.id}](#{job_url}) by [John Smith (smith)](#{user_url})")
      expect(subject.attachments).to include("[#{deployment.short_sha}](#{commit_url}): #{commit.title}")
    end
  end

  describe "#template_theme" do
    using RSpec::Parameterized::TableSyntax

    where(:status, :theme) do
      'created' | :success
      'success' | :success
      'running' | :running
      'failed' | :error
      'canceled' | :cancel
      'skipped' | :warning
      'blocked' | :warning
    end

    with_them do
      it "return corresponding theme" do
        args[:status] = status

        expect(subject.template_theme).to eq(Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[theme])
      end
    end
  end
end
