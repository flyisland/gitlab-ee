# frozen_string_literal: true

module Geo
  class UploadReplicator < Gitlab::Geo::Replicator
    include ::Geo::BlobReplicatorStrategy
    include ::Geo::Concerns::UploadReplicatorBehavior

    def self.model
      ::Upload
    end

    # @return [String] human-readable title of this replicator.
    def self.replicable_title
      s_('Geo|Upload')
    end

    # @return [String] human-readable title of this replicator, pluralized.
    def self.replicable_title_plural
      s_('Geo|Uploads')
    end

    def carrierwave_uploader
      model_record.retrieve_uploader
    end
  end
end
