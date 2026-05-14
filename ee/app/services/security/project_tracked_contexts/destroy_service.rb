# frozen_string_literal: true

module Security
  module ProjectTrackedContexts
    class DestroyService
      def initialize(tracked_context:, current_user:)
        @tracked_context = tracked_context
        @current_user = current_user
      end

      def execute
        return default_branch_error if tracked_context.is_default?

        if tracked_context.destroy
          ServiceResponse.success(payload: { tracked_context: tracked_context })
        else
          ServiceResponse.error(message: tracked_context.errors.full_messages.join(', '))
        end
      end

      private

      attr_reader :tracked_context, :current_user

      def default_branch_error
        ServiceResponse.error(message: 'Cannot untrack default branch')
      end
    end
  end
end
