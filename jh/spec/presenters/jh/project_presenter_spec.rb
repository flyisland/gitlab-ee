# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::ProjectPresenter, feature_category: :duo_agent_platform do
  describe '#statistics_buttons' do
    let(:presenter_class) do
      Class.new do
        prepend JH::ProjectPresenter

        def statistics_buttons
          []
        end
      end
    end

    let(:wiki_agent_button) do
      ::ProjectPresenter::AnchorData.new(false, s_('JH|Generate repository Wiki'), '/wiki_agent')
    end

    let(:presenter) { presenter_class.new }

    before do
      allow(presenter).to receive(:wiki_agent_anchor_data).and_return(wiki_agent_button)
    end

    it 'adds the Wiki Agent action to the project statistics buttons' do
      expect(presenter.statistics_buttons).to contain_exactly(wiki_agent_button)
    end
  end

  describe 'the Wiki Agent action' do
    let(:project) { build_stubbed(:project) }
    let(:current_user) { build_stubbed(:user) }
    let(:consumer) { instance_double(Ai::Catalog::ItemConsumer) }
    let(:flow_trigger) { instance_double(Ai::FlowTrigger, ai_catalog_item_consumer: consumer) }
    let(:finder) { instance_double(JH::Ai::Catalog::WikiAgentFlowTriggerFinder, execute: [flow_trigger]) }
    let(:presenter) { ::ProjectPresenter.new(project, current_user: current_user) }

    before do
      allow(presenter).to receive(:can?).and_return(true)
      allow(JH::Ai::Catalog::WikiAgentFlowTriggerFinder).to receive(:new).with(project).and_return(finder)
    end

    it 'uses the project POST endpoint and action label', :aggregate_failures do
      action = presenter.send(:wiki_agent_anchor_data)

      expect(action).to have_attributes(
        label: include(
          'tanuki-ai',
          'information-o',
          'data-toggle="tooltip"',
          s_('JH|Generate repository Wiki'),
          s_(
            'JH|Uses the code repository in this project to generate or update ' \
              'repository documentation in the project Wiki.'
          )
        ),
        link: project_wiki_agent_path(project)
      )
      expect(action.data).to eq(
        disable: true,
        method: :post,
        testid: 'run-wiki-agent-button'
      )
    end

    it 'is hidden without permission to execute the catalog item' do
      allow(presenter).to receive(:can?).with(current_user, :execute_ai_catalog_item, consumer).and_return(false)

      expect(presenter.send(:wiki_agent_anchor_data)).to be_nil
    end

    it 'is hidden without permission to create a wiki' do
      allow(presenter).to receive(:can?).with(current_user, :create_wiki, project).and_return(false)

      expect(presenter.send(:wiki_agent_anchor_data)).to be_nil
    end
  end
end
