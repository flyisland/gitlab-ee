# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Catalog::GoalTemplates::Developer::Mention, feature_category: :duo_agent_platform do
  let_it_be(:project) { create(:project) }
  let_it_be(:issue) { create(:issue, project: project) }

  describe '.vars' do
    it 'builds note_url with note anchor when note_id is present' do
      resource_url = Gitlab::UrlBuilder.build(issue)
      vars = described_class.vars(resource: issue, params: { note_id: 42 })

      expect(vars[:note_url]).to eq("#{resource_url}#note_42")
      expect(vars[:resource_name]).to eq('issue')
    end

    it 'falls back to resource_url when note_id is absent' do
      resource_url = Gitlab::UrlBuilder.build(issue)
      vars = described_class.vars(resource: issue, params: {})

      expect(vars[:note_url]).to eq(resource_url)
    end

    it 'includes discussion_id when present in params' do
      vars = described_class.vars(resource: issue, params: { discussion_id: 'abc123' })

      expect(vars[:discussion_id]).to eq('abc123')
    end

    it 'returns empty string for discussion_id when absent' do
      vars = described_class.vars(resource: issue, params: {})

      expect(vars[:discussion_id]).to eq('')
    end
  end
end
