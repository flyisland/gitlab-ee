# frozen_string_literal: true

module JH
  module Gitlab
    module Database
      module RetentionPolicy
        module ::Gitlab
          module Database
            class RetentionPolicy
              excluded_schemas = EXCLUDED_SCHEMAS
              remove_const :EXCLUDED_SCHEMAS
              EXCLUDED_SCHEMAS = (excluded_schemas | %w[gitlab_jh]).freeze
            end
          end
        end
      end
    end
  end
end
