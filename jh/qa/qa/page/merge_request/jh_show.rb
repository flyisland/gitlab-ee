# frozen_string_literal: true

module QA
  module Page
    module MergeRequest
      class JhShow < QA::Page::Base
        view 'ee/app/assets/javascripts/vue_merge_request_widget/widgets/security_reports/mr_widget_security_reports.vue' do # rubocop:disable QA/ElementWithPattern
          element 'vulnerability-report-grouped'
        end

        def expand_vulnerability_view_report
          within_element('vulnerability-report-grouped') do
            click_element('extension-actions-button') if has_element?('extension-actions-button')
          end
        end

        def click_vulnerability_in_view_reports(name)
          within_element 'report-SAST' do
            click_on name
          end

          wait_until(reload: false) do
            find_element('vulnerability-modal-content')
          end
        end

        def wait_for_resolve_with_ai_completion
          wait_until(reload: false) do
            has_no_element?('vulnerability-modal-content')
          end
        end
      end
    end
  end
end
