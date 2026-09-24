# frozen_string_literal: true

module JH
  module Projects
    module Ci
      module PipelineEditorController
        extend ActiveSupport::Concern

        prepended do
          before_action do
            push_frontend_feature_flag(:jh_ci_graph_editor, @project)
          end
        end
      end
    end
  end
end
