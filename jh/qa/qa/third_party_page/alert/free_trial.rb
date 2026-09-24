# frozen_string_literal: true

module QA
  module ThirdPartyPage
    module Alert
      class FreeTrial < ::QA::Page::Base
        def trial_activated_message?
          has_text?('You have successfully started a GitLab Ultimate trial')
        end
      end
    end
  end
end
