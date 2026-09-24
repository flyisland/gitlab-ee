# frozen_string_literal: true

module JH
  # PostReceive JH mixin
  #
  # This module is intended to encapsulate JH-specific model logic
  # and be prepended in the `PostReceive` worker
  module Repositories
    module PostReceiveWorker
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      private

      def process_project_changes(post_received, project, user)
        result = super

        if ::ContentValidation::Setting.check_enabled?(project)
          process_content_validation(project, project, ::Gitlab::GlRepository::PROJECT, user, post_received.changes)
        end

        result
      end

      def process_wiki_changes(post_received, wiki, user)
        result = super

        if ::ContentValidation::Setting.check_enabled?(wiki)
          process_content_validation(
            wiki, wiki.try(:project), ::Gitlab::GlRepository::WIKI, user, post_received.changes)
        end

        result
      end

      def process_snippet_changes(post_received, snippet)
        result = super

        if ::ContentValidation::Setting.check_enabled?(snippet)
          user = identify_user(post_received)
          process_content_validation(
            snippet,
            snippet.project,
            ::Gitlab::GlRepository::SNIPPET,
            user,
            post_received.changes)
        end

        result
      end

      def process_content_validation(container, project, repo_type, user, changes)
        ::ContentValidation::ProcessChangesService.new(
          container: container,
          project: project,
          repo_type: repo_type,
          user: user,
          changes: changes).execute
      end
    end
  end
end
