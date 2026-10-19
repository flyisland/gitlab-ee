# frozen_string_literal: true

module QA
  module Page
    module Component
      class DuoWorkflow < QA::Page::Base
        view 'ee/app/assets/javascripts/ai/shared/widgets/duo_workflow_action.vue' do
          element 'duo-workflow-action-button'
        end

        def click_generate_mr_with_duo
          click_element('duo-workflow-action-button')
        end

        def click_fix_pipeline_with_duo
          click_element('duo-workflow-action-button')
        end

        def click_convert_jenkins_file_with_duo
          click_element('duo-workflow-action-button')
        end
      end
    end
  end
end
