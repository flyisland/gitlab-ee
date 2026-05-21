# frozen_string_literal: true

module Ai
  module DuoSettings
    class UpdateService
      def initialize(update_params, current_user: nil)
        @params = update_params
        @current_user = current_user
      end

      def execute
        ai_settings = ::Ai::Setting.instance

        ai_settings.update!(params)

        Ai::DuoSettings::ChangesAuditor.new(current_user, ai_settings).execute

        ServiceResponse.success(payload: ai_settings)
      rescue ActiveRecord::RecordInvalid => e
        ServiceResponse.error(message: e.record.errors.full_messages.join(", "))
      rescue StandardError => e
        Gitlab::ErrorTracking.track_exception(e)
        ServiceResponse.error(message: _("Unable to update AI settings"))
      end

      private

      attr_reader :params, :current_user
    end
  end
end
