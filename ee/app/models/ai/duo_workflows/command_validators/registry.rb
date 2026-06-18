# frozen_string_literal: true

module Ai
  module DuoWorkflows
    module CommandValidators
      # Maps program names to their validators. Keyed by program binary
      # name, not tool name (run_command vs run_git_command).
      #
      # Unregistered programs fail closed -- pattern-based approval
      # requires a registered validator; exact-match always works.
      class Registry
        VALIDATORS = {
          'git' => GitValidator
        }.freeze

        class << self
          def validator_for(program)
            klass = VALIDATORS[program]
            return unless klass

            klass.new
          end

          def registered?(program)
            VALIDATORS.key?(program)
          end
        end
      end
    end
  end
end
