# frozen_string_literal: true

module JH
  module Integrations
    module Params
      extend ::Gitlab::Utils::Override

      ALLOWED_PARAMS_JH = [:corpid, :language_for_notify].freeze

      override :allowed_integration_params

      def allowed_integration_params
        super + ALLOWED_PARAMS_JH
      end
    end
  end
end
