# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequest do
  describe 'validations' do
    it_behaves_like "content validation with project", :merge_request, :title
    it_behaves_like "content validation with project", :merge_request, :description
  end

  describe 'KNOWN_MERGE_PARAMS constant' do
    it 'includes skip_mono_central_pipeline parameter' do
      expect(MergeRequest::KNOWN_MERGE_PARAMS).to include(:skip_mono_central_pipeline)
    end
  end
end
