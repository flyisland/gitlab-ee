# frozen_string_literal: true

module Geo
  class AiVectorizableFileUploadReplicator < Gitlab::Geo::Replicator
    include ::Geo::BlobReplicatorStrategy
    include ::Geo::Concerns::UploadReplicatorBehavior
    extend ::Gitlab::Utils::Override

    def self.model
      ::Geo::AiVectorizableFileUpload
    end

    # @return [String] human-readable title.
    def self.replicable_title
      s_('Geo|AI Vectorizable File Upload')
    end

    # @return [String] pluralized human-readable title.
    def self.replicable_title_plural
      s_('Geo|AI Vectorizable File Uploads')
    end

    def carrierwave_uploader
      model_record.retrieve_uploader
    end
  end
end
