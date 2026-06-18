# frozen_string_literal: true

module Ai
  module DuoWorkflows
    module CommandValidators
      class GitValidator < Base
        # Layer 1: Subcommand allowlist (true allowlist, deny-by-default).
        # Only these git subcommands are eligible for pattern-based approval.
        # Unknown subcommands require exact-match approval.
        ALLOWED_SUBCOMMANDS = Set.new(%w[
          add
          bisect
          blame
          branch
          checkout
          cherry-pick
          clean
          commit
          describe
          diff
          difftool
          fetch
          grep
          init
          log
          merge
          mv
          pull
          push
          rebase
          reflog
          remote
          reset
          restore
          revert
          rm
          show
          stash
          status
          switch
          tag
          worktree
        ]).freeze

        # Layer 2: Global option allowlist (true allowlist, deny-by-default).
        # Pre-subcommand flags must be in this set. Everything else is rejected,
        # which blocks -c, -C, --exec-path, --config-env, and any other
        # global that could execute code or redirect git's binary lookup.
        ALLOWED_GLOBAL_OPTIONS = Set.new(%w[
          --no-pager
          --bare
          --no-replace-objects
          --literal-pathspecs
          --glob-pathspecs
          --icase-pathspecs
          --no-optional-locks
          --no-advice
        ]).freeze

        # Layer 3: Dangerous subcommand flag denylist (defense-in-depth ONLY).
        # Not comprehensive -- catches known code-execution flags but will
        # have gaps. Replaced by per-subcommand flag allowlists in #602494.
        DANGEROUS_SUBCOMMAND_FLAGS = Set.new(%w[
          --upload-pack
          --receive-pack
          --exec
          -x
          --extcmd
          --template
          --open-files-in-pager
          -c
          --config
        ]).freeze

        DANGEROUS_SUBCOMMAND_FLAG_PREFIXES = %w[
          --upload-pack=
          --receive-pack=
          --exec=
          --extcmd=
          --template=
          --open-files-in-pager=
          -O
          -c=
          --config=
        ].freeze

        def safe_for_pattern_matching?(program:, tokens:) # rubocop:disable Lint/UnusedMethodArgument -- program: is part of the Base interface; subclasses may use it
          global_options, subcommand, subcommand_args = split_tokens(tokens)

          unless subcommand
            log_rejection('no subcommand found', tokens)
            return false
          end

          unless ALLOWED_SUBCOMMANDS.include?(subcommand)
            log_rejection("subcommand '#{subcommand}' not in allowlist", tokens)
            return false
          end

          unless global_options_allowed?(global_options)
            log_rejection("disallowed global option in #{global_options}", tokens)
            return false
          end

          if subcommand_args_contain_dangerous_flags?(subcommand_args)
            log_rejection("dangerous flag in subcommand args #{subcommand_args}", tokens)
            return false
          end

          if bisect_run?(subcommand, subcommand_args)
            log_rejection('bisect run executes arbitrary scripts', tokens)
            return false
          end

          true
        end

        private

        # Splits tokens into [global_options, subcommand, subcommand_args].
        # Flags with value args (e.g. `-c <val>`) have the value classified
        # as the subcommand -- safe because such flags aren't in ALLOWED_GLOBAL_OPTIONS.
        def split_tokens(tokens)
          global_options = []
          subcommand = nil
          subcommand_args = []

          tokens.each_with_index do |token, index|
            if subcommand.nil?
              if token.start_with?('-')
                global_options << token
              else
                subcommand = token
                subcommand_args = tokens[(index + 1)..]
                break
              end
            end
          end

          [global_options, subcommand, subcommand_args]
        end

        def global_options_allowed?(global_options)
          global_options.all? { |opt| ALLOWED_GLOBAL_OPTIONS.include?(opt) }
        end

        def subcommand_args_contain_dangerous_flags?(args)
          args.any? do |arg|
            DANGEROUS_SUBCOMMAND_FLAGS.include?(arg) ||
              DANGEROUS_SUBCOMMAND_FLAG_PREFIXES.any? { |prefix| arg.start_with?(prefix) }
          end
        end

        # `git bisect run <script>` executes an arbitrary script per bisection
        # step. Scoped to bisect only to avoid false positives on branches or
        # files named "run" (e.g. `git checkout run`).
        def bisect_run?(subcommand, subcommand_args)
          subcommand == 'bisect' && subcommand_args.first == 'run'
        end

        def log_rejection(reason, tokens)
          Gitlab::AppLogger.debug(
            message: "GitValidator rejected command for pattern matching: #{reason}",
            tokens: tokens
          )
        rescue StandardError
          # Logging is best-effort; do not fail validation if the logger
          # is unavailable (e.g. fast_spec_helper context).
        end
      end
    end
  end
end
