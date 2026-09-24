# frozen_string_literal: true

module JH
  module Ci
    module TemplateHelpers
      extend ::Gitlab::Utils::Override

      override :template_registry_host
      def template_registry_host
        'registry.gitlab.cn'
      end

      # override headers Accept
      override :public_image_manifest
      def public_image_manifest(registry, repository, reference)
        token = public_image_repository_token(registry, repository)

        headers = {
          'Authorization' => "Bearer #{token}",
          'Accept' => ::ContainerRegistry::Client::ACCEPTED_TYPES_RAW.join(", ")
        }
        response = with_net_connect_allowed do
          ::Gitlab::HTTP.get(image_manifest_url(registry, repository, reference), headers: headers)
        end

        if response.success?
          ::Gitlab::Json.parse(response.body)
        elsif response.not_found?
          nil
        else
          raise "Could not retrieve manifest: #{response.body}"
        end
      end
    end
  end
end
