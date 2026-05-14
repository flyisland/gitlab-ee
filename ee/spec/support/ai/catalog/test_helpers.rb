# frozen_string_literal: true

module Ai
  module Catalog
    module TestHelpers
      def enable_ai_catalog(enabled = true)
        allow(Ai::Catalog).to receive(:available?).and_return(enabled)
        allow(Gitlab::Llm::StageCheck).to receive(:available?).and_return(enabled)
      end

      def click_more_actions_dropdown
        click_button 'More actions'
      end

      def click_more_actions_button(text)
        click_more_actions_dropdown
        click_button text
      end
    end
  end
end
