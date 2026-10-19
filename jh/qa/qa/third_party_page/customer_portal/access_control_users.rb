# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module CustomerPortal
      class AccessControlUsers < ::QA::Page::Base
        def assign_finance_role(user)
          fill_in('搜索用户', with: user.username)
          find_field('搜索用户').send_keys(:enter)

          within(user_row(user)) { click_button('编辑') }

          within('[role="dialog"]') do
            finance_checkbox = find('label', text: '财务').find('input[type="checkbox"]', visible: :all)
            finance_checkbox.click unless finance_checkbox.checked?
            click_button('保存')
          end

          has_no_css?('[role="dialog"]')
          within(user_row(user)) { find('span', text: '财务', exact_text: true) }
        end

        private

        def user_row(user)
          find('tbody tr', text: "@#{user.username}")
        end
      end
    end
  end
end
