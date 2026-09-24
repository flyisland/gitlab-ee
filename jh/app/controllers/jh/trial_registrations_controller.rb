# frozen_string_literal: true

module JH
  module TrialRegistrationsController
    extend ::Gitlab::Utils::Override

    private

    override :sign_up_params
    def sign_up_params
      super.tap do |params|
        params['preferred_language'] = preferred_language if params.present?
      end
    end
  end
end
