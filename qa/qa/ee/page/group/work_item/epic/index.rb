# frozen_string_literal: true

module QA
  module EE
    module Page
      module Group
        module WorkItem
          module Epic
            class Index < QA::Page::Base
              view 'app/assets/javascripts/vue_shared/issuable/list/components/issuable_item.vue' do
                element 'issuable-title-link'
              end

              view 'app/assets/javascripts/work_items/components/create_work_item_modal.vue' do
                element 'new-epic-button'
              end

              view 'app/assets/javascripts/work_items/components/work_items_onboarding_modal/' \
                'work_items_onboarding_modal.vue' do
                element 'work-items-onboarding-modal'
              end

              def click_new_epic
                dismiss_onboarding_modal_if_present
                first("[data-testid='new-epic-button']").click
                EE::Page::Group::WorkItem::Epic::New.validate_elements_present!
              end

              def click_first_epic(page = EE::Page::Group::WorkItem::Epic::Show)
                dismiss_onboarding_modal_if_present
                all_elements('issuable-title-link', minimum: 1).first.click
                page.validate_elements_present! if page
              end

              def has_epic_title?(title)
                wait_until do
                  has_element?('issuable-title-link', text: title)
                end
              end

              def dismiss_onboarding_modal_if_present
                return unless has_element?('work-items-onboarding-modal', wait: 0.5)

                within_element('work-items-onboarding-modal') do
                  click_element('close-icon')
                end

                has_no_element?('work-items-onboarding-modal')
              end
            end
          end
        end
      end
    end
  end
end
