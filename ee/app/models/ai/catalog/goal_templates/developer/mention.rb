# frozen_string_literal: true

module Ai
  module Catalog
    module GoalTemplates
      class Developer
        class Mention
          def self.handler_for(params)
            adapter?(params) ? Adapter : Default
          end

          def self.adapter?(params)
            (params[:delivery_mode] || :default).to_sym == :adapter
          end

          def self.base_vars(resource:, params:)
            resource_url = Gitlab::UrlBuilder.build(resource)
            triggered_by_username = params[:triggered_by_username].to_s
            note_id = params[:note_id]
            note_url = note_id ? "#{resource_url}#note_#{note_id}" : resource_url

            default_context = "#{Developer.resource_display_name(resource).capitalize}: #{note_url}"
            source_context = params[:source_context] || default_context

            {
              resource_name: Developer.resource_display_name(resource),
              triggered_by_username: triggered_by_username,
              note_url: note_url,
              source_context: source_context
            }
          end
        end
      end
    end
  end
end
