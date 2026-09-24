# frozen_string_literal: true

module JH
  module API
    module Ci
      module Helpers
        module PipelinesHelpers
          extend ActiveSupport::Concern

          prepended do
            params :create_pipeline_params do
              requires :ref, type: String, desc: 'Reference',
                documentation: { example: 'develop' }
              optional :variables, type: Array, desc: 'Array of variables available in the pipeline' do
                optional :key, type: String, desc: 'The key of the variable', documentation: { example: 'UPLOAD_TO_S3' }
                optional :value, type: String, desc: 'The value of the variable', documentation: { example: 'true' }
                optional :variable_type, type: String, values: ::Ci::PipelineVariable.variable_types.keys,
                  default: 'env_var', desc: 'The type of variable, must be one of env_var or file. Defaults to env_var'
              end
              optional :ci_config_path, type: String, desc: 'The path to the CI configuration file'
            end
          end
        end
      end
    end
  end
end
