# frozen_string_literal: true

module ArtifactRegistry
  # A container manifest row from the AR manifests list. Two fields are easy for a UI to
  # misread. size is the manifest payload's own bytes for a remote (cached) repository, but for
  # a hosted repository it is a push-time manifest-tree total that can double-count blobs shared
  # across manifests rather than the payload's own size. subject_digest is null except on a
  # referrer row, which the list only returns when include_referrers is true, so it is null
  # everywhere until that argument lands.
  class Manifest
    include TimeCoercion

    def initialize(attributes = {})
      @attributes = attributes || {}
    end

    def id
      @attributes['id']
    end

    def digest
      @attributes['digest']
    end

    def media_type
      @attributes['media_type']
    end

    def artifact_type
      @attributes['artifact_type']
    end

    def subject_digest
      @attributes['subject_digest']
    end

    def size
      @attributes['size']
    end

    def created_at
      parse_time(@attributes['created_at'])
    end
  end
end
