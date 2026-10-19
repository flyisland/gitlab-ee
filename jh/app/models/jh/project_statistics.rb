# frozen_string_literal: true

module JH
  module ProjectStatistics
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    private

    override :notify_storage_usage
    def notify_storage_usage
      super

      ::JH::Namespaces::Storage::RepoLimit::EmailNotificationService.execute(project)
    end
  end
end
