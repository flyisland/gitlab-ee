# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Group
        module Report
          class NotesCreated < Report::BaseEvent
            def self.header
              "Comments"
            end

            def event_target_action_scope
              Event.for_note.for_action(:commented)
            end
          end
        end
      end
    end
  end
end
