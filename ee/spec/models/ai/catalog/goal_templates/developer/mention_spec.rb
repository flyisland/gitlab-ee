# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Catalog::GoalTemplates::Developer::Mention, feature_category: :duo_agent_platform do
  let_it_be(:project) { create(:project) }
  let_it_be(:issue) { create(:issue, project: project) }

  describe '.handler_for' do
    it 'returns Default when no delivery mode is given' do
      expect(described_class.handler_for({})).to eq(described_class::Default)
    end

    it 'returns Default for delivery_mode: :default' do
      expect(described_class.handler_for({ delivery_mode: :default })).to eq(described_class::Default)
    end

    it 'returns Adapter for delivery_mode: :adapter' do
      expect(described_class.handler_for({ delivery_mode: :adapter })).to eq(described_class::Adapter)
    end

    it 'accepts a string delivery mode' do
      expect(described_class.handler_for({ delivery_mode: 'adapter' })).to eq(described_class::Adapter)
    end

    it 'falls back to Default for an unknown delivery mode' do
      expect(described_class.handler_for({ delivery_mode: :unknown })).to eq(described_class::Default)
    end
  end

  describe '.base_vars' do
    it 'builds note_url with note anchor when note_id is present', :aggregate_failures do
      resource_url = Gitlab::UrlBuilder.build(issue)
      vars = described_class.base_vars(resource: issue, params: { note_id: 42, triggered_by_username: 'alice' })

      expect(vars[:note_url]).to eq("#{resource_url}#note_42")
      expect(vars[:resource_name]).to eq('issue')
      expect(vars[:triggered_by_username]).to eq('alice')
    end

    it 'falls back to resource_url when note_id is absent' do
      resource_url = Gitlab::UrlBuilder.build(issue)
      vars = described_class.base_vars(resource: issue, params: { triggered_by_username: 'alice' })

      expect(vars[:note_url]).to eq(resource_url)
    end

    it 'uses source_context from params when provided' do
      custom_context = "Issue: https://example.com\nTitle: Test"
      vars = described_class.base_vars(
        resource: issue,
        params: { triggered_by_username: 'alice', source_context: custom_context }
      )

      expect(vars[:source_context]).to eq(custom_context)
    end

    it 'includes note_url in the default source_context fallback' do
      resource_url = Gitlab::UrlBuilder.build(issue)
      vars = described_class.base_vars(resource: issue, params: { note_id: 42, triggered_by_username: 'alice' })

      expect(vars[:source_context]).to eq("Issue: #{resource_url}#note_42")
    end

    it 'uses resource_url in the default source_context when note_id is absent' do
      resource_url = Gitlab::UrlBuilder.build(issue)
      vars = described_class.base_vars(resource: issue, params: { triggered_by_username: 'alice' })

      expect(vars[:source_context]).to eq("Issue: #{resource_url}")
    end
  end

  describe Ai::Catalog::GoalTemplates::Developer::Mention::Adapter do
    it 'resolves with every placeholder filled and the conversation wired in', :aggregate_failures do
      goal = Ai::Catalog::GoalTemplates::Developer.resolve(
        event_type: :mention,
        resource: issue,
        user_input: 'Please look into this',
        params: { delivery_mode: :adapter, triggered_by_username: 'alice' }
      )

      expect(goal).not_to match(/%\{/)
      expect(goal).to include('Please look into this')
      expect(goal).to include('<conversation>')
      expect(goal).to include('<gitlab_context>')
    end

    it 'carries no self-post reply mechanics', :aggregate_failures do
      template = described_class.template

      expect(template).not_to include('%{delivery_instructions}')
      expect(template).not_to include('%{discussion_id}')
      expect(template).not_to include('%{note_url}')
    end
  end

  describe Ai::Catalog::GoalTemplates::Developer::Mention::Default do
    it 'resolves with every placeholder filled, wiring in the discussion id', :aggregate_failures do
      goal = Ai::Catalog::GoalTemplates::Developer.resolve(
        event_type: :mention,
        resource: issue,
        user_input: 'Please look into this',
        params: { delivery_mode: :default, triggered_by_username: 'alice', discussion_id: 'abc123' }
      )

      expect(goal).not_to match(/%\{/)
      expect(goal).to include('Please look into this')
      expect(goal).to include('abc123')
    end

    it 'exposes the discussion id for interpolation' do
      vars = described_class.vars(
        resource: issue,
        params: { triggered_by_username: 'alice', discussion_id: 'abc123' }
      )

      expect(vars[:discussion_id]).to eq('abc123')
    end
  end
end
