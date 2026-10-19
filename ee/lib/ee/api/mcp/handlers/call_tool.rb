# frozen_string_literal: true

module EE
  module API
    module Mcp
      module Handlers
        module CallTool
          extend ActiveSupport::Concern

          prepended do
            include ::Gitlab::InternalEventsTracking
            include ::Gitlab::Utils::StrongMemoize
          end

          private

          def track_start_event(tool_name, request_id, current_user, tool: nil, params: nil)
            track_internal_event(
              'start_mcp_tool_call',
              user: current_user,
              **resolve_tracking_scope(tool, params),
              additional_properties: {
                request_id: request_id,
                tool_name: tool_name,
                **client_fields
              }
            )
          end

          def track_finish_event(tool_name, request_id, current_user, success:, tool: nil, error: nil, params: nil)
            additional_properties = {
              request_id: request_id,
              tool_name: tool_name,
              has_tool_call_success: success.to_s,
              **client_fields
            }

            if error
              additional_properties[:failure_reason] = tool_status(error)
              additional_properties[:error_status] = error.message&.truncate(255)
            end

            track_internal_event(
              'finish_mcp_tool_call',
              user: current_user,
              **resolve_tracking_scope(tool, params),
              additional_properties: additional_properties
            )
          end

          def tool_call_namespace(tool, params)
            scope = resolve_tracking_scope(tool, params)
            (scope[:project] || scope[:namespace])&.root_ancestor
          end

          # Resolve the tool's target project/group from the tool's own container declaration so the
          # analytics event is attributed to it. No permission check: this feeds internal telemetry
          # and log gating only, never the response. The start event resolves it before the tool runs,
          # so aggregated tools rewriting params[:arguments] in place cannot change it.
          def resolve_tracking_scope(tool, params)
            strong_memoize(:resolved_tracking_scope) do
              containers = tracking_containers(tool, params)

              {
                project: containers.find { |container| container.is_a?(::Project) },
                namespace: containers.find { |container| container.is_a?(::Group) }
              }.compact
            end
          end

          def tracking_containers(tool, params)
            arguments = params.to_h.with_indifferent_access[:arguments] || {}
            # An unknown tool has no declaration of its own, so fall back to the default argument names.
            resolver = tool || ::Mcp::Tools::Base::BaseService.new(name: params[:name])

            resolver.governed_containers(arguments).containers
          rescue ArgumentError
            # Oversized container arguments; the tool reports them to the caller itself.
            []
          rescue StandardError => e
            ::Gitlab::ErrorTracking.track_exception(e, mcp_tool: params[:name])
            []
          end
        end
      end
    end
  end
end
