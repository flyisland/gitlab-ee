# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module Trials
      class New < ::QA::Page::Base
        def fill_last_name(last_name)
          fill_element(:"last-name-field", last_name)
        end

        def has_last_name_field?
          has_element?(:"last-name-field", wait: 3)
        end

        def fill_company_name(company_name)
          fill_element(:"company-name-field", company_name)
        end

        def select_default_country
          click_element(:"country-dropdown")
          click_element(:"listbox-item-CN")
        end

        def fill_telephone(telephone)
          fill_element(:"phone-number-field", telephone)
        end

        def activate_my_trial
          click_element("submit-button")
        end
      end
    end
  end
end
