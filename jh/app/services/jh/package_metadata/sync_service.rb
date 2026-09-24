# frozen_string_literal: true

module JH
  module PackageMetadata
    module SyncService
      extend ::Gitlab::Utils::Override

      private

      override :connector
      def connector
        @connector ||= case sync_config.storage_type
                       when :aliyun
                         ::Gitlab::PackageMetadata::Connector::AliYun.new(sync_config)
                       else
                         super
                       end
      end
    end
  end
end
