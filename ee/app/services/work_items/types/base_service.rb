# frozen_string_literal: true

module WorkItems
  module Types
    class BaseService < BaseContainerService
      include Gitlab::InternalEventsTracking

      FeatureNotAvailableError = ServiceResponse.error(
        message: 'Feature not available'
      )

      InvalidContainerError = ServiceResponse.error(
        message: 'Work item types can only be modified at the root group or organization level'
      )

      def initialize(container:, current_user: nil, params: {})
        super
      end

      private

      def resolved_container
        container.respond_to?(:sync) ? container.sync : container
      end
      strong_memoize_attr :resolved_container

      def feature_available?
        case resolved_container
        when ::Group
          Feature.enabled?(:work_item_configurable_types, resolved_container)
        else
          Feature.enabled?(:work_item_configurable_types, :instance)
        end
      end

      def valid_container?
        return true if resolved_container.is_a?(::Organizations::Organization)
        return true if resolved_container.is_a?(::Group) && resolved_container.root?

        false
      end

      def validation_error_response(record)
        ServiceResponse.error(message: record.errors.full_messages.to_sentence)
      end

      def work_item_type_provider
        ::WorkItems::TypesFramework::Provider.new(resolved_container)
      end
      strong_memoize_attr :work_item_type_provider

      def tracking_namespace
        resolved_container.is_a?(::Group) ? resolved_container : nil
      end
    end
  end
end
