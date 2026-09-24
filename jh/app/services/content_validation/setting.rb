# frozen_string_literal: true

module ContentValidation
  class Setting
    class << self
      def block_enabled?(container)
        # here container could be a project/wiki/snippet
        container = container.container if container.is_a?(Wiki)
        ::Gitlab.com? &&
          ::Gitlab::CurrentSettings.content_validation_endpoint_enabled? &&
          !container.private?
      end

      def content_validation_enable?
        ::Gitlab.com? &&
          ::Gitlab::CurrentSettings.content_validation_endpoint_enabled?
      end

      def check_enabled?(container)
        return content_validation_enable? if container.nil?

        # here container could be a project/wiki/snippet
        container = container.container if container.is_a?(Wiki)
        content_validation_enable? && !container.private?
      end
    end
  end
end
