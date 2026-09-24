# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    module Presenters
      class Deploy < Presenters::Base
        def present(from, to)
          message = "Deployment started from #{from} to #{to}. " \
            "[Follow its progress](#{resource_url})."

          { type: :markdown, title: 'deployment started', content: message }
        end

        def action_not_found
          { type: :text, content: "Couldn't find a deployment manual action." }
        end
      end
    end
  end
end
