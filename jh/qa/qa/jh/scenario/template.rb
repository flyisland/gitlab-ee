# frozen_string_literal: true

module QA
  module JH
    module Scenario
      module Template
        def self.prepended(_base)
          # Runner is loaded lazily after JH extension modules are eager loaded.
          ::QA::Specs::Runner.prepend_mod_with( # rubocop:disable Cop/InjectEnterpriseEditionModule
            "Specs::Runner", namespace: ::QA)
        end

        def perform(options, *args)
          # set driver_path to avoid update latest driver during running test
          # which cause network issue due to great wall
          if ::QA::Runtime::Env.skip_update_driver?
            ::Selenium::WebDriver::Chrome::Service.driver_path = proc { ::Webdrivers::Chromedriver.driver_path }
          end

          super
        end
      end
    end
  end
end
