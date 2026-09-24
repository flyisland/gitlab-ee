# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContentValidation::ProjectVisibilityChangedService do
  let(:project) { create(:project, :public) }
  let!(:project_visibility_changed_service) do
    described_class.new(project, project.owner)
  end

  describe 'content_validation_pass?' do
    context 'when content invalid' do
      it do
        stub_content_validation_request(false)
        expect(project_visibility_changed_service.content_validation_pass?).to be false
      end
    end

    context 'when content valid' do
      before do
        stub_content_validation_request(true)
      end

      it do
        expect(project_visibility_changed_service.content_validation_pass?).to be true
      end
    end
  end

  describe 'project_content_validation_pass?' do
    context 'when project content invalid' do
      it do
        stub_content_validation_request(false)
        expect(project_visibility_changed_service.project_content_validation_pass?).to be false
      end
    end

    context 'when project content valid' do
      before do
        stub_content_validation_request(true)
      end

      it do
        expect(project_visibility_changed_service.project_content_validation_pass?).to be true
      end
    end
  end

  describe 'issues_content_validation_pass?' do
    before do
      create(:issue, project: project)
    end

    context 'when issue content invalid' do
      before do
        stub_content_validation_request(false)
      end

      it do
        allow(project_visibility_changed_service).to(receive(:project_content_validation_pass?)).and_return(true)
        expect(project_visibility_changed_service.content_validation_pass?).to be false
      end
    end

    context 'when issue content valid' do
      before do
        stub_content_validation_request(true)
      end

      it do
        allow(project_visibility_changed_service).to(receive(:project_content_validation_pass?)).and_return(true)
        expect(project_visibility_changed_service.content_validation_pass?).to be true
      end
    end
  end

  describe 'execute' do
    before do
      allow(ContentValidation::Setting).to receive(:check_enabled?).and_return(true)
    end

    it 'content validation pass' do
      stub_content_validation_request(true)
      expect { project_visibility_changed_service.execute }.not_to change { project.reset.visibility_level }
    end

    it 'context validation failed' do
      stub_content_validation_request(false)
      expect { project_visibility_changed_service.execute }.to change { project.reset.visibility_level }
      expect(project.reset.private?).to be true
    end
  end
end
