# frozen_string_literal: true

module JH
  module Users
    module UnblockService
      extend ::Gitlab::Utils::Override

      override :after_unblock_hook

      def after_unblock_hook(user)
        expire_free_trial_attribute(user) if ::Gitlab.com?
        super
      end

      private

      def expire_free_trial_attribute(user)
        last_attribute = user.last_custom_attribute
        return if last_attribute.blank? ||
          last_attribute.key != ::FreeTrial::BlockFreeTrialUserService::FREE_TRIAL_ENDS

        # if user is blocked and then paid(unblock), then blocked again
        # user should have two blocked attributes
        # however due to (user_id, key) unique key in attribute table, we have to change previous attribute
        # make blocked attribute always be last one
        last_attribute.update!(key: "#{last_attribute.key}/#{last_attribute.value}", value: 'expired')
        user.remove_free_trial_left_days
      end
    end
  end
end
