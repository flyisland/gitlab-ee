# frozen_string_literal: true

module JH
  module Banzai
    module Filter
      module MarkdownEngines
        module CommonMark
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          private

          attr_reader :context

          override :render_options
          def render_options
            options = super

            if context[:common_mark_extra_render_options].is_a?(Array)
              options += context[:common_mark_extra_render_options]
            end

            options.uniq
          end
        end
      end
    end
  end
end
