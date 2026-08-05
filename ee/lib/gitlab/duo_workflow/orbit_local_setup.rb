# frozen_string_literal: true

module Gitlab
  module DuoWorkflow
    # Builds the shell commands that install and run Orbit local indexing
    # inside a Duo Agent Platform workload.
    #
    # Orbit local indexes the current checkout so the agent has a
    # branch-aware knowledge graph - not just the default-branch graph
    # served by the remote Orbit API.
    #
    # Gated behind the +duo_developer_orbit+ feature flag and the
    # per-user Orbit killswitch, matching the same gate used to route
    # the developer flow to the +2.0.0-orbit+ variant.
    #
    # All commands are best-effort: failures are logged as warnings and
    # never abort the workload.
    #
    # The install and index commands are best-effort. The orbit binary has
    # runtime requirements (notably a recent GLIBC) that are not satisfied by
    # every workload base image. When the binary cannot run on the host,
    # the install step may succeed but the binary will be unusable. The
    # index step is therefore guarded by an executable-bit preflight check,
    # so we don't try to run a binary that was never installed.
    # The workload continues regardless of orbit's outcome.
    class OrbitLocalSetup
      attr_reader :current_user

      def initialize(current_user:)
        @current_user = current_user
      end

      def commands
        return [] unless enabled?

        [
          install_command,
          index_command
        ]
      end

      private

      def enabled?
        Feature.enabled?(:duo_developer_orbit, current_user) &&
          ::Ai::Orbit::Settings.killswitch_on?(current_user)
      end

      def install_command
        <<~SH.squish
          glab orbit local --install --yes
          || echo "Warning: Orbit local install failed; continuing without local index" >&2
        SH
      end

      def index_command
        <<~SH.strip
          if [ -x "$HOME/.config/glab-cli/bin/orbit" ]; then
            glab orbit local --yes index . || echo "Warning: Orbit local indexing failed; continuing without local index" >&2
          else
            echo "Warning: Orbit local indexing skipped; continuing without local index" >&2
          fi
        SH
      end
    end
  end
end
