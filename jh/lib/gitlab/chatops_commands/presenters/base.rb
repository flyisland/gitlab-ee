# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    module Presenters
      class Base
        include Gitlab::Routing

        TEXT_LIMIT_PER_FIELD = 20

        def initialize(resource = nil, is_group_message = false)
          @resource = resource
          @is_group_message = is_group_message
        end

        def display_errors(header = "The action was not successful, because:")
          message = header_with_list(header, @resource.errors.full_messages)
          { type: :markdown, content: message, title: "error" }
        end

        private

        attr_reader :resource, :is_group_message

        def limit(str)
          str.length >= TEXT_LIMIT_PER_FIELD ? "#{str[0..TEXT_LIMIT_PER_FIELD]}..." : str
        end

        def header_with_list(header, items)
          message = [header]

          items.each do |item|
            message << "- #{item}"
          end

          message.join("\n")
        end

        def resource_url
          url_for(
            [
              resource.project,
              resource
            ]
          )
        end

        def project_link
          "[#{project.full_name}](#{project.web_url})"
        end

        def author_profile_link
          "[#{author.to_reference}](#{url_for(author)})"
        end

        def pretext
          ''
        end
      end
    end
  end
end
