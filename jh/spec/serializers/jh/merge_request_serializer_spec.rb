# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequestSerializer do
  let_it_be(:group) { create(:group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :public, group: group) }
  let_it_be(:resource) { create :merge_request, source_project: project, author: user }

  let(:json_entity) do
    described_class.new(current_user: user)
      .represent(resource, serializer: serializer)
      .with_indifferent_access
  end

  context 'when serializer is "monorepo"' do
    let(:serializer) { 'monorepo' }

    before do
      allow(::MergeRequests::MonorepoService).to receive(:monorepo_enabled?).and_return(true)
    end

    it 'matches json schema' do
      expect(json_entity.to_json).to match_schema(
        Rails.root.join('jh/spec/fixtures/api/schemas/entities/merge_request_monorepo.json')
      )
    end
  end
end
