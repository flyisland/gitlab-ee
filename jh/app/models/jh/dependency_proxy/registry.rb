# frozen_string_literal: true

module JH
  module DependencyProxy
    module Registry
      extend ActiveSupport::Concern

      LIBRARY_URL = 'https://mirror.ccs.tencentyun.com'

      class_methods do
        extend ::Gitlab::Utils::Override

        override :manifest_url
        def manifest_url(image, tag)
          return super unless ::Feature.enabled?(:dependency_proxy_use_tencent_source) && ::Gitlab.com?

          "#{LIBRARY_URL}/#{image_path(image)}/manifests/#{tag}"
        end

        override :blob_url
        def blob_url(image, blob_sha)
          return super unless ::Feature.enabled?(:dependency_proxy_use_tencent_source) && ::Gitlab.com?

          "#{LIBRARY_URL}/#{image_path(image)}/blobs/#{blob_sha}"
        end
      end
    end
  end
end
