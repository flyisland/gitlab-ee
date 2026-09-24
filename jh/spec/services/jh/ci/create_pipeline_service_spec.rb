# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::CreatePipelineService, feature_category: :continuous_integration do
  let(:project) { create(:project, :repository) }
  let(:params) do
    { ref: 'master',
      before: '00000000',
      after: project.commit.id,
      commits: [{ message: 'some commit' }] }
  end

  let_it_be(:user) { create(:user) }
  let(:service) { described_class.new(project, user, params) }

  describe '#extra_options' do
    context 'when params has no `ci_config_path`' do
      it 'returns extra options without `ci_config_path`' do
        expect(service.extra_options.keys).not_to include(:ci_config_path)
      end
    end

    context 'when params has ci_config_path' do
      let(:ci_config_path) { 'https://example.com/example.yaml' }

      before do
        params[:ci_config_path] = ci_config_path
      end

      it 'returns extra options with `ci_config_path` from params' do
        expect(service.extra_options).to include(ci_config_path: ci_config_path)
      end
    end
  end

  describe '#execute' do
    before do
      project.add_developer(user)
      stub_ci_pipeline_to_return_yaml_file
    end

    context 'when params has no `ci_config_path`' do
      it 'returns success', :aggregate_failures do
        response, pipeline = create_pipeline!

        expect(response).to be_success
        expect(pipeline).to be_created_successfully
      end
    end

    context 'when params has `ci_config_path`' do
      before do
        params[:ci_config_path] = ci_config_path
      end

      context 'when `ci_config_path` is invalid' do
        let(:ci_config_path) { '../example.yml' }

        it 'returns error', :aggregate_failures do
          response, pipeline = create_pipeline!
          expect(response).to be_error
          expect(response.message).to eq('ci_config_path is invalid')
          expect(pipeline.errors[:ci_config_path]).to eq ['cannot include leading slash or directory traversal.']
        end
      end
    end
  end

  def create_pipeline!
    response = service.execute(:push)

    [response, response.payload]
  end
end
