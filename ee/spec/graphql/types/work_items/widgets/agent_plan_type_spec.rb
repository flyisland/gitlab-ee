# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::WorkItems::Widgets::AgentPlanType, feature_category: :team_planning do
  let(:fields) do
    %i[type content content_html]
  end

  specify { expect(described_class.graphql_name).to eq('WorkItemWidgetAgentPlan') }

  specify { expect(described_class).to have_graphql_fields(fields) }

  describe 'field call count limits' do
    it 'limits content field call count to 1' do
      expect(described_class.fields['content'].extensions).to include(a_kind_of(::Gitlab::Graphql::Limit::FieldCallCount))
    end

    it 'limits contentHtml field call count to 1' do
      expect(described_class.fields['contentHtml'].extensions).to include(a_kind_of(::Gitlab::Graphql::Limit::FieldCallCount))
    end
  end
end
