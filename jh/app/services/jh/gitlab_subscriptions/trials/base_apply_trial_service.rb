# frozen_string_literal: true

module JH
  module GitlabSubscriptions
    module Trials
      module BaseApplyTrialService
        extend ::Gitlab::Utils::Override

        private

        override :assign_seat

        def assign_seat(add_on_purchase, user)
          return unless ::Feature.enabled?(:jh_skip_auto_assign_duo_seat, user)

          super
        end
      end
    end
  end
end
