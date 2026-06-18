# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Chain
          module CommandPolicy
            extend ActiveSupport::Concern

            prepended do
              condition(:ondemand_dast_scan, scope: :subject) do
                @subject.ondemand_dast_scan?
              end

              rule { ondemand_dast_scan & can?(:_run_dast_pipeline) }.policy do
                enable :run_pipeline
              end

              rule { ondemand_dast_scan & can?(:_create_dast_pipeline) }.policy do
                enable :create_pipeline
              end
            end
          end
        end
      end
    end
  end
end
