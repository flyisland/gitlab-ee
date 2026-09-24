# frozen_string_literal: true

module QA
  module Page
    module Repository
      module Contributors
        class CodeLines < QA::Page::Base
          view 'jh/app/assets/javascripts/contributors/components/contributors.vue' do
            element 'code-lines-additions'
            element 'code-lines-deletions'
            element 'effective-code-lines-additions'
            element 'effective-code-lines-deletions'
          end

          def has_addition_lines_element?(text)
            wait_until(reload: true) do
              has_element?('code-lines-additions', text: text)
            end
          end

          def has_deletion_lines_element?(text)
            wait_until(reload: true) do
              has_element?('code-lines-deletions', text: text)
            end
          end

          def has_addition_effective_lines_element?(text)
            wait_until(reload: true) do
              has_element?('effective-code-lines-additions', text: text)
            end
          end

          def has_deletion_effective_lines_element?(text)
            wait_until(reload: true) do
              has_element?('effective-code-lines-deletions', text: text)
            end
          end
        end
      end
    end
  end
end
