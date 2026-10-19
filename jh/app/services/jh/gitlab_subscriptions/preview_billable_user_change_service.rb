# frozen_string_literal: true

module JH
  module GitlabSubscriptions
    module PreviewBillableUserChangeService
      extend ::Gitlab::Utils::Override

      private

      override :will_increase_overage?
      def will_increase_overage?
        # To fix this problem: https://jihulab.com/gitlab-cn/gitlab/-/issues/4306#note_4960774
        #
        # This is a bug in Upstream. We fix it with this patch.
        # When the seats is limited, the overage will not increase.
        return false if target_namespace.block_seat_overages?

        super
      end
    end
  end
end
