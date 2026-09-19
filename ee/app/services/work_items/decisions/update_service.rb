# frozen_string_literal: true

module WorkItems
  module Decisions
    class UpdateService
      UPDATABLE_ATTRIBUTES = %i[title description resolution_rationale discussion_id source_link].freeze

      def initialize(decision:, current_user:, params: {})
        @decision = decision
        @work_item = decision.work_item
        @current_user = current_user
        @params = params
      end

      def execute
        error = validate_params
        return ServiceResponse.error(message: error) if error

        decision.update!(update_attributes)

        ServiceResponse.success(payload: { decision: decision })
      rescue ActiveRecord::RecordInvalid => e
        ServiceResponse.error(message: e.record.errors.full_messages.to_sentence)
      end

      private

      attr_reader :decision, :work_item, :current_user, :params

      def validate_params
        return _('Operation not allowed') unless allowed?
        return _('No attributes to update') if update_attributes.empty?
        return if blank_attributes.empty?

        format(
          _("%{attributes} can't be blank"),
          attributes: blank_attributes.map { |attribute| decision.class.human_attribute_name(attribute) }.to_sentence
        )
      end

      # get_widget covers type registration, ai_workflows licensing, and the
      # decision_log feature flag
      def allowed?
        current_user.can?(:update_work_item, work_item) && work_item.get_widget(:decision_log).present?
      end

      def update_attributes
        params.slice(*UPDATABLE_ATTRIBUTES)
      end

      # A provided attribute may be replaced but never cleared; omitted
      # attributes are left untouched
      def blank_attributes
        update_attributes.select { |_, value| value.blank? }.keys
      end
    end
  end
end
