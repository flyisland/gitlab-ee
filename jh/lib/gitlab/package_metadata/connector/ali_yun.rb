# frozen_string_literal: true

require 'aliyun/oss'

module Gitlab
  module PackageMetadata
    module Connector
      class AliYun < BaseConnector
        def data_after(checkpoint)
          return all_files if checkpoint.blank?

          found_list = all_files.drop_while do |file|
            !file.checkpoint?(checkpoint)
          end

          if found_list.any?
            found_list.drop(1)
          else
            all_files
          end
        end

        private

        # gcp file_prefix has a trailing slash, so the base connector definition
        # is updated to add the trailing slash.
        def file_prefix
          File.join(super, '')
        end

        def all_files
          bucket.list_objects(prefix: file_prefix).to_a.lazy.map do |file|
            sequence, chunk = sequence_and_chunk_from(file.key)

            data_file_class.new(AliYunFileWrapper.new(bucket, file), sequence, chunk)
          end
        end

        def bucket
          connection.get_bucket(sync_config.base_uri)
        end

        def connection
          @connection ||= Aliyun::OSS::Client.new(
            endpoint: ENV.fetch('JH_MIRROR_PACKAGE_METADATA_BUCKET_ENDPOINT', 'https://oss-cn-beijing.aliyuncs.com'),
            access_key_id: ENV['JH_MIRROR_PACKAGE_METADATA_ACCESS_KEY_ID'],
            access_key_secret: ENV['JH_MIRROR_PACKAGE_METADATA_ACCESS_KEY_SECRET']
          )
        end

        class AliYunFileWrapper
          def initialize(bucket, aliyun_file)
            @bucket = bucket
            @aliyun_file = aliyun_file
          end

          def each_line(&)
            io.each_line(&)
          end

          private

          def io
            @io ||= begin
              # this will generate in-memory file-like object for following processing
              io = StringIO.new
              @bucket.get_object(@aliyun_file.key) { |chunk| io.write(chunk) }
              io.rewind
              io.read
            end
          end
        end
      end
    end
  end
end
