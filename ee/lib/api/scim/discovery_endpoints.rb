# frozen_string_literal: true

module API
  module Scim
    # SCIM service provider discovery endpoints (RFC 7644 Section 4):
    # /Schemas.
    #
    # The including API must define two helpers:
    # - `authenticate_scim_discovery!`: authenticates the SCIM token for the API context.
    # - `scim_discovery_base_url`: absolute URL of the SCIM API root, used for `meta.location`.
    module DiscoveryEndpoints
      # Schema IDs are URNs that contain dots (for example `...:core:2.0:User`),
      # which Grape would otherwise parse as a format extension.
      ID_REQUIREMENTS = { id: %r{[^/]+} }.freeze

      FAILURES = [
        { code: 401, message: 'Unauthorized' },
        { code: 403, message: 'SAML not enabled or filter not supported' },
        { code: 404, message: 'Not found' }
      ].freeze

      def mount_scim_discovery_endpoints(context:)
        helpers ::API::Helpers::RelatedResourcesHelpers

        mount_scim_schemas_endpoints(context)
      end

      private

      def mount_scim_schemas_endpoints(context)
        resource :Schemas do
          desc 'Get the SCIM schemas' do
            detail 'Returns the SCIM schemas supported by GitLab, per RFC 7644 Section 4.'
            success ::API::Entities::Scim::Schemas
            failure FAILURES
            tags ['scim']
          end
          params do
            optional :filter, type: String, desc: 'Filter expression (not supported; returns 403 if present)'
          end
          route_setting :authorization, skip_granular_token_authorization: :scim_token_auth
          get do
            authenticate_scim_discovery!

            scim_forbidden!(message: 'Filtering is not supported on this endpoint') if params[:filter].present?

            status 200
            present({ resources: ::Gitlab::Scim::SchemaDefinitions.all(context: context) },
              with: ::API::Entities::Scim::Schemas,
              base_url: scim_discovery_base_url)
          end

          desc 'Get a SCIM schema' do
            detail 'Returns a SCIM schema by its URN, per RFC 7644 Section 4.'
            success ::API::Entities::Scim::Schema
            failure FAILURES
            tags ['scim']
          end
          params do
            requires :id, type: String, desc: 'The URN of the schema'
          end
          route_setting :authorization, skip_granular_token_authorization: :scim_token_auth
          get ':id', requirements: ID_REQUIREMENTS do
            authenticate_scim_discovery!

            schema = ::Gitlab::Scim::SchemaDefinitions.find(params[:id], context: context)
            scim_not_found!(message: "Schema #{params[:id]} not found") unless schema

            status 200
            present schema, with: ::API::Entities::Scim::Schema, base_url: scim_discovery_base_url
          end
        end
      end
    end
  end
end
