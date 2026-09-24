# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Entities::ContentBlockedState do
  let(:entity) { described_class.new(content_blocked_state) }
  let(:content_blocked_state) { create(:content_blocked_state, container: project) }
  let(:project) { create(:project) }

  subject { entity.as_json }

  it 'exposes container_identifier, commit_sha, blob_sha and path' do
    expect(subject).to include(:container_identifier, :commit_sha, :blob_sha, :path)
  end

  it 'exposes project_full_path' do
    expect(subject[:project_full_path]).to eq(project.full_path)
  end
end
