# frozen_string_literal: true

module Ai
  module DuoWorkflows
    module CommandValidators
      # Base class for program-specific command validators.
      #
      # Validators are keyed by program name (e.g. "git", "npm"), not by
      # tool name (e.g. "run_command", "run_git_command"). This decoupling
      # means that when run_git_command is deprecated and all git commands
      # flow through run_command, the same GitValidator applies with zero
      # code changes.
      #
      # Subclasses implement `safe_for_pattern_matching?` which receives
      # a parsed command hash and returns whether pattern-based approval
      # is allowed for the command.
      class Base
        # @param program [String] e.g. "git"
        # @param tokens [Array<String>] all arguments after the program name,
        #   including the subcommand (e.g. ["checkout", "main"])
        # @return [Boolean] true if the command is safe for pattern matching
        def safe_for_pattern_matching?(program:, tokens:)
          raise NotImplementedError, "#{self.class}#safe_for_pattern_matching? must be implemented"
        end
      end
    end
  end
end
