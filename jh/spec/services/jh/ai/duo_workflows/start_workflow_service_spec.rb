# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Ai::DuoWorkflows::StartWorkflowService, :request_store, feature_category: :duo_agent_platform do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:maintainer) { create(:user, maintainer_of: project) }

  describe '#instance_image' do
    subject(:instance_image) { service.send(:instance_image) }

    let(:workflow) { build_stubbed(:duo_workflows_workflow, user: maintainer, project: project) }
    let(:service) { described_class.new(workflow: workflow, params: {}) }
    let(:base_image_version) { described_class::IMAGE_PATH.split(':').last }
    let(:jh_image_path) do
      'registry.jihulab.com/gitlab-cn/modelops/duo-workflow/default-docker-image/workflow-generic-image'
    end

    let(:expected_jh_image) { "#{jh_image_path}:#{base_image_version}" }

    context 'when Gitlab.jh? is true' do
      before do
        allow(Gitlab).to receive(:jh?).and_return(true)
      end

      context 'when JH_WORKFLOW_IMAGE_PATH environment variable is not set' do
        before do
          stub_env('JH_WORKFLOW_IMAGE_PATH', nil)
        end

        it 'uses the default JH_IMAGE_PATH constant' do
          expect(instance_image).to eq(expected_jh_image)
        end
      end

      context 'when JH_WORKFLOW_IMAGE_PATH environment variable is set' do
        let(:custom_image_path) { 'custom-registry.com/custom/path' }
        let(:expected_custom_image) { "#{custom_image_path}:#{base_image_version}" }

        before do
          stub_env('JH_WORKFLOW_IMAGE_PATH', custom_image_path)
        end

        it 'uses the custom image path from environment variable' do
          expect(instance_image).to eq(expected_custom_image)
        end
      end

      context 'when JH_WORKFLOW_IMAGE_PATH is empty string' do
        before do
          stub_env('JH_WORKFLOW_IMAGE_PATH', '')
        end

        it 'uses the default JH_IMAGE_PATH constant' do
          expect(instance_image).to eq(expected_jh_image)
        end
      end

      context 'when extracting version from base IMAGE constant' do
        let(:different_version) { 'v1.2.3' }
        let(:base_image_with_version) do
          "gitlab-org/duo-workflow/default-docker-image/workflow-generic-image:#{different_version}"
        end

        before do
          stub_const('::Ai::DuoWorkflows::StartWorkflowService::IMAGE_PATH', base_image_with_version)
        end

        it 'extracts and uses the version from base IMAGE constant' do
          expect(instance_image).to eq("#{jh_image_path}:#{different_version}")
        end
      end
    end

    context 'when Gitlab.jh? is false' do
      before do
        allow(Gitlab).to receive(:jh?).and_return(false)
      end

      it 'calls the parent class instance_image method' do
        expect(instance_image).to eq("registry.gitlab.com/#{described_class::IMAGE_PATH}")
      end
    end
  end
end
