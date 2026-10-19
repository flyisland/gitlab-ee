# rubocop:disable Naming/FileName -- Rails inflects the JH prefix as the JH acronym.
# frozen_string_literal: true

module JH
  module Ai
    module Catalog
      module GoalTemplates
        class JHAdvancedCodeReview < ::Ai::Catalog::GoalTemplates::Base
          def self.resolve(event_type:, resource:, user_input: nil, params: {}) # rubocop:disable Lint/UnusedMethodArgument
            raise ArgumentError, 'resource must be a merge request' unless resource.is_a?(::MergeRequest)

            resource.iid.to_s
          end
        end
      end
    end
  end
end
# rubocop:enable Naming/FileName
