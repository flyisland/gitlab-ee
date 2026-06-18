# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Catalog::GoalTemplates::Developer::Mention, feature_category: :duo_agent_platform do
  let_it_be(:project) { create(:project) }
  let_it_be(:issue) { create(:issue, project: project) }

  describe '.vars' do
    it 'builds note_url with note anchor when note_id is present', :aggregate_failures do
      resource_url = Gitlab::UrlBuilder.build(issue)
      vars = described_class.vars(resource: issue, params: { note_id: 42, triggered_by_username: 'alice' })

      expect(vars[:note_url]).to eq("#{resource_url}#note_42")
      expect(vars[:resource_name]).to eq('issue')
      expect(vars[:triggered_by_username]).to eq('alice')
    end

    it 'falls back to resource_url when note_id is absent' do
      resource_url = Gitlab::UrlBuilder.build(issue)
      vars = described_class.vars(resource: issue, params: { triggered_by_username: 'alice' })

      expect(vars[:note_url]).to eq(resource_url)
    end

    it 'uses source_context from params when provided' do
      custom_context = "Issue: https://example.com\nTitle: Test"
      vars = described_class.vars(
        resource: issue,
        params: { triggered_by_username: 'alice', source_context: custom_context }
      )

      expect(vars[:source_context]).to eq(custom_context)
    end

    it 'includes note_url in the default source_context fallback' do
      resource_url = Gitlab::UrlBuilder.build(issue)
      vars = described_class.vars(resource: issue, params: { note_id: 42, triggered_by_username: 'alice' })

      expect(vars[:source_context]).to eq("Issue: #{resource_url}#note_42")
    end

    it 'uses resource_url in default source_context when note_id is absent' do
      resource_url = Gitlab::UrlBuilder.build(issue)
      vars = described_class.vars(resource: issue, params: { triggered_by_username: 'alice' })

      expect(vars[:source_context]).to eq("Issue: #{resource_url}")
    end

    context 'with delivery_mode: :adapter' do
      it 'includes auto-reply instruction and @mention' do
        vars = described_class.vars(
          resource: issue,
          params: { triggered_by_username: 'alice', delivery_mode: :adapter }
        )

        expect(vars[:delivery_instructions]).to include('posted automatically')
        expect(vars[:delivery_instructions]).to include('@alice')
      end
    end

    context 'with delivery_mode: :default' do
      it 'includes reply-in-thread and glab api instructions' do
        vars = described_class.vars(
          resource: issue,
          params: {
            triggered_by_username: 'alice',
            discussion_id: 'abc123',
            delivery_mode: :default
          }
        )

        expect(vars[:delivery_instructions]).to include('reply in the same discussion thread')
        expect(vars[:delivery_instructions]).to include('@alice')
        expect(vars[:delivery_instructions]).to include('glab api')
        expect(vars[:delivery_instructions]).to include('abc123')
      end
    end

    context 'without delivery_mode' do
      it 'defaults to reply-in-thread instruction' do
        vars = described_class.vars(
          resource: issue,
          params: { triggered_by_username: 'alice' }
        )

        expect(vars[:delivery_instructions]).to include('reply in the same discussion thread')
      end
    end

    context 'with an unknown delivery_mode' do
      it 'falls back to the default instruction' do
        vars = described_class.vars(
          resource: issue,
          params: { triggered_by_username: 'alice', delivery_mode: :unknown }
        )

        expect(vars[:delivery_instructions]).to include('reply in the same discussion thread')
      end
    end
  end

  describe '.template' do
    it 'includes conversation, gitlab_context, and note_url placeholders' do
      template = described_class.template

      expect(template).to include('<conversation>')
      expect(template).to include('<gitlab_context>')
      expect(template).to include('%{note_url}')
      expect(template).to include('%{source_context}')
      expect(template).to include('%{user_input}')
      expect(template).to include('%{delivery_instructions}')
      expect(template).to include('%{triggered_by_username}')
    end
  end
end
