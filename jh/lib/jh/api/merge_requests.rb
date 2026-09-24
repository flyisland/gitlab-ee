# frozen_string_literal: true

module JH
  module API
    module MergeRequests
      extend ActiveSupport::Concern

      prepended do
        helpers do
          params :optional_params_ee do
            optional :skip_mono_central_pipeline, type: ::Grape::API::Boolean,
              desc: 'Skip creating monorepo central pipeline for this merge request'
            optional :approvals_before_merge, type: Integer,
              desc: 'Number of approvals required before this can be merged'
            optional :approval_rules_attributes, type: Array, documentation: { hidden: true } do
              optional :id, type: Integer, desc: 'The ID of a rule'
              optional :approvals_required, type: Integer, desc: 'Total number of approvals required'
            end
          end
        end
      end
    end
  end
end
