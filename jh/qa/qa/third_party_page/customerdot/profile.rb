# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module Customerdot
      class Profile < QA::Page::Base
        def has_user_information_area?
          has_css?('#personal-details')
        end
      end
    end
  end
end
