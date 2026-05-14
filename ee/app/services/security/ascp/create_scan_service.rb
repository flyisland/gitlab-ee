# frozen_string_literal: true

module Security
  module Ascp
    class CreateScanService
      include Gitlab::ExclusiveLeaseHelpers

      LOCK_TTL = 1.minute
      LOCK_RETRIES = 10
      LOCK_SLEEP_SEC = 0.5.seconds

      def initialize(project:, params:)
        @project = project
        @params = params
      end

      def execute
        in_lock(lock_key, ttl: LOCK_TTL, retries: LOCK_RETRIES, sleep_sec: LOCK_SLEEP_SEC) do
          scan = build_scan
          if scan.save
            ServiceResponse.success(payload: { scan: scan })
          else
            ServiceResponse.error(message: scan.errors.full_messages.to_sentence)
          end
        end
      rescue Gitlab::ExclusiveLeaseHelpers::FailedToObtainLockError
        ServiceResponse.error(message: 'Failed to obtain lock for scan creation. Please retry.')
      end

      private

      def lock_key
        "ascp:scan_sequence:#{@project.id}"
      end

      def build_scan
        Scan.new(
          project: @project,
          scan_sequence: next_sequence,
          base_scan: resolve_base_scan,
          **@params.except(:base_scan_id)
        )
      end

      def next_sequence
        Scan.next_scan_sequence_for(@project.id)
      end

      def resolve_base_scan
        return unless @params[:base_scan_id]

        Scan.find_for_project(@params[:base_scan_id], @project.id)
      end
    end
  end
end
