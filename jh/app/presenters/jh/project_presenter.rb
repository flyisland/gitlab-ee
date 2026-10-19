# frozen_string_literal: true

module JH
  module ProjectPresenter
    extend ::Gitlab::Utils::Override

    override :statistics_buttons
    def statistics_buttons
      super.tap do |buttons|
        wiki_agent_button = wiki_agent_anchor_data
        buttons << wiki_agent_button if wiki_agent_button
      end
    end

    private

    def wiki_agent_anchor_data
      return unless current_user&.human? && can?(current_user, :trigger_ai_flow, project)
      return unless can_create_wiki?

      flow_trigger = ::JH::Ai::Catalog::WikiAgentFlowTriggerFinder.new(project).execute.first
      return unless flow_trigger

      consumer = flow_trigger.ai_catalog_item_consumer
      return unless can?(current_user, :execute_ai_catalog_item, consumer)

      tooltip_icon = content_tag(
        :span,
        title: s_(
          'JH|Uses the code repository in this project to generate or update ' \
            'repository documentation in the project Wiki.'
        ),
        class: 'gl-ml-2',
        data: { toggle: 'tooltip' }
      ) { sprite_icon('information-o', css_class: 'gl-fill-icon-subtle') }

      label = content_tag(
        :span,
        statistic_icon('tanuki-ai', 'info') + s_('JH|Generate repository Wiki') + tooltip_icon
      )
      ::ProjectPresenter::AnchorData.new(false, label, project_wiki_agent_path(project), nil, nil, nil, {
        disable: true,
        method: :post,
        testid: 'run-wiki-agent-button'
      })
    end
  end
end
