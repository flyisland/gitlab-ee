# frozen_string_literal: true

module QA
  module JH
    module Page
      module MergeRequest
        module Show
          def click_first_merge_request
            click_element('issuable-title-link')
          end

          def has_commits?(minimum: 1)
            has_css?('.commit', minimum: minimum)
          end

          def has_title_including?(title)
            find_element('title-content').text.include?(title)
          end
        end
      end
    end
  end
end
