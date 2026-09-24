# frozen_string_literal: true

require "carrierwave/storage/fog"

# rubocop:disable Gitlab/ModuleWithInstanceVariables -- prepend modules for
# CarrierWave monkey-patching legitimately need access to the instance variables
# of the classes they are prepended into.
module JHCarrierWaveStorePatch
  DIRECTORY_FOR_SECURITY_REVIEW = %w[@hashed design_management namespace personal_snippet].freeze

  def store(new_file)
    # This patch is used to solve the problem of Tencent COS skipping security review
    # Related issues: https://jihulab.com/gitlab-cn/internal/content-security-backend/-/issues/41
    #
    # The default behavior of CarrierWave is to upload first and then copy, which will cause COS
    # to skip the security review.
    # The behavior after overwriting is: no copy, just created directly.
    unless new_file.is_a?(self.class) &&
        ::Feature.enabled?(:ff_direct_upload_to_final_path) &&
        DIRECTORY_FOR_SECURITY_REVIEW.any? { |dir| path.start_with?(dir) }
      return super
    end

    @content_type ||= new_file.content_type
    @file = directory.files.create({
      body: new_file.read,
      content_type: @content_type,
      key: path,
      public: @uploader.fog_public
    }.merge(@uploader.fog_attributes))
    true
  rescue StandardError => e
    Gitlab::AppLogger.error("Error storing file via direct upload: #{e.message}")
    super
  end
end
# rubocop:enable Gitlab/ModuleWithInstanceVariables

CarrierWave::Storage::Fog::File.prepend(JHCarrierWaveStorePatch)
