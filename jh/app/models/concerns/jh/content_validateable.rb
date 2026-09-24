# frozen_string_literal: true

module JH
  module ContentValidateable
    extend ActiveSupport::Concern

    def should_validate_content?
      ::Gitlab::CurrentSettings.current_application_settings.content_validation_endpoint_enabled &&
        ::Gitlab.jh? &&
        ::Gitlab.com?
    end

    def with_project_should_validate_content?
      return should_validate_content? if project.nil?

      !project.private? && should_validate_content?
    end
  end
end
