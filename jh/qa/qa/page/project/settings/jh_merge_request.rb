# frozen_string_literal: true

module QA
  module Page
    module Project
      module Settings
        class JhMergeRequest < QA::Page::Base
          # Add jh merge request due to single squash merge is jh-only function
          view 'jh/app/views/projects/settings/merge_requests/_merge_request_merge_method_settings.html.haml' do
            element 'merge-single-squash-radio'
          end

          def enable_single_squash_merge
            choose_element('merge-single-squash-radio', true)
            click_save_changes
          end

          def click_save_changes
            click_element('save-merge-request-changes-button')
          end
        end
      end
    end
  end
end
