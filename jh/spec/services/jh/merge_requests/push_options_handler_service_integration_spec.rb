# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'JH::MergeRequests::PushOptionsHandlerService Integration', feature_category: :source_code_management do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { create(:user, developer_of: project) }

  let(:source_branch) { 'fix' }
  let(:target_branch) { 'feature' }
  let(:changes) do
    "#{Gitlab::Git::SHA1_BLANK_SHA} 570e7b2abdd848b95f2f578043fc23bd6f6fd24d refs/heads/#{source_branch}"
  end

  let(:push_options) { {} }

  # Create a test class that includes the JH module to test the integration
  let(:service_class) { ::MergeRequests::PushOptionsHandlerService }

  let(:service) do
    service_class.new(
      project: project,
      current_user: user,
      changes: changes,
      push_options: push_options
    )
  end

  describe 'integration with MergeRequest creation' do
    context 'when skip_mono_central_pipeline push option is provided' do
      let(:push_options) do
        {
          create: true,
          title: 'Test MR with skip_mono_central_pipeline',
          target: target_branch,
          skip_mono_central_pipeline: true
        }
      end

      it 'creates merge request with skip_mono_central_pipeline in merge_params' do
        service.execute
        expect(MergeRequest.count).to eq(1)
        created_mr = MergeRequest.last
        expect(created_mr.title).to eq('Test MR with skip_mono_central_pipeline')
        expect(created_mr.merge_params).to include('skip_mono_central_pipeline' => true)
      end
    end

    context 'when skip_mono_central_pipeline push option is false' do
      let(:push_options) do
        {
          create: true,
          title: 'Test MR with skip_mono_central_pipeline false',
          target: target_branch,
          skip_mono_central_pipeline: false
        }
      end

      it 'creates merge request with skip_mono_central_pipeline false in merge_params' do
        expect { service.execute }.to change { MergeRequest.count }.by(1)
        created_mr = MergeRequest.last
        expect(created_mr.title).to eq('Test MR with skip_mono_central_pipeline false')
        expect(created_mr.merge_params).to include('skip_mono_central_pipeline' => false)
      end
    end

    context 'when skip_mono_central_pipeline push option is not provided' do
      let(:push_options) do
        {
          create: true,
          title: 'Test MR without skip_mono_central_pipeline',
          target: target_branch
        }
      end

      it 'creates merge request without skip_mono_central_pipeline in merge_params' do
        expect { service.execute }.to change { MergeRequest.count }.by(1)
        created_mr = MergeRequest.last
        expect(created_mr.title).to eq('Test MR without skip_mono_central_pipeline')
        expect(created_mr.merge_params).not_to have_key('skip_mono_central_pipeline')
      end
    end

    context 'when updating existing merge request' do
      let!(:existing_mr) do
        create(:merge_request,
          source_project: project,
          target_project: project,
          source_branch: source_branch,
          target_branch: target_branch,
          author: user,
          merge_params: { 'existing_param' => 'value' }
        )
      end

      let(:push_options) do
        {
          skip_mono_central_pipeline: true
        }
      end

      it 'updates merge request with skip_mono_central_pipeline in merge_params' do
        expect { service.execute }.not_to change { MergeRequest.count }

        existing_mr.reload
        expect(existing_mr.merge_params).to include(
          'existing_param' => 'value',
          'skip_mono_central_pipeline' => true
        )
      end
    end

    context 'when combined with other push options' do
      let(:push_options) do
        {
          create: true,
          title: 'Complex MR with multiple options',
          description: 'Test description',
          target: target_branch,
          remove_source_branch: true,
          squash: true,
          skip_mono_central_pipeline: true
        }
      end

      it 'creates merge request with all parameters correctly set' do
        expect { service.execute }.to change { MergeRequest.count }.by(1)

        created_mr = MergeRequest.last
        expect(created_mr.title).to eq('Complex MR with multiple options')
        expect(created_mr.description).to eq('Test description')
        expect(created_mr.force_remove_source_branch?).to be true
        expect(created_mr.squash).to be true
        expect(created_mr.merge_params).to include('skip_mono_central_pipeline' => true)
      end
    end
  end

  describe 'error handling' do
    context 'when service encounters errors' do
      let(:push_options) do
        {
          'merge_request' => {
            'create' => '',
            'title' => '', # Invalid title to trigger error
            'target' => target_branch
          },
          'skip_mono_central_pipeline' => 'true'
        }
      end

      it 'handles errors gracefully and does not create merge request' do
        expect { service.execute }.not_to change { MergeRequest.count }
        expect(service.errors).not_to be_empty
      end
    end
  end
end
