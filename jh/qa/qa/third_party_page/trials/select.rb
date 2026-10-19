# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module Trials
      class Select < ::QA::Page::Base
        def select_group(group)
          click_element(:"namespace-dropdown")
          find('li', text: group.to_s).click
          QA::Runtime::Logger.info("Choose #{group}")
        end
      end
    end
  end
end
