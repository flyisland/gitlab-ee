# frozen_string_literal: true

module JH
  module EverySidekiqWorkerTestHelper
    extend ::Gitlab::Utils::Override

    override :extra_retry_exceptions
    def extra_retry_exceptions
      {
        'ContentValidation::CommitServiceWorker' => 3,
        'ContentValidation::ProjectScanWorker' => false,
        'FreeTrial::BlockFreeTrialUserWorker' => 3,
        'FreeTrial::RemindFreeTrialUserWorker' => 3,
        'Wecom::SendNotificationWorker' => 3
      }
    end
  end
end
