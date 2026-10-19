# frozen_string_literal: true

module JH
  module EverySidekiqWorkerTestHelper
    extend ::Gitlab::Utils::Override

    override :extra_retry_exceptions
    def extra_retry_exceptions
      {
        'Ai::Messaging::ApprovalDecisionWorker' => false,
        'ContentValidation::CommitServiceWorker' => 3,
        'ContentValidation::ProjectScanWorker' => false,
        'Dingtalk::SendNotificationWorker' => 3,
        'Feishu::DuoMessageWorker' => 3,
        'Feishu::SendNotificationWorker' => 3,
        'FreeTrial::BlockFreeTrialUserWorker' => 3,
        'FreeTrial::RemindFreeTrialUserWorker' => 3,
        'Notifications::ChannelEnqueueWorker' => 3,
        'Notifications::FanoutWorker' => 3,
        'Wecom::SendNotificationWorker' => 3
      }
    end
  end
end
