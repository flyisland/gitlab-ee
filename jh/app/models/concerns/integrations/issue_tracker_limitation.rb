# frozen_string_literal: true

# This module is extracted from `base_issue_tracker.rb`
# and we want to reuse `one_issue_tracker` limitation in JH.
# See more: app/models/integrations/base_issue_tracker.rb
module Integrations
  module IssueTrackerLimitation
    extend ActiveSupport::Concern

    included do
      attribute :category, default: 'issue_tracker'
      validate :one_issue_tracker, if: :activated?, on: :manual_change

      def issue_tracker_path
        raise NotImplementedError
      end

      def activate_disabled_reason
        { trackers: other_external_issue_trackers } if other_external_issue_trackers.any?
      end

      def support_cross_reference?
        false
      end

      def support_close_issue?
        false
      end

      def create_cross_reference_note(external_issue, mentioned_in, author)
        # implement inside child if needed
      end

      def issue_url(iid)
        issues_url.gsub(':id', iid.to_s)
      end

      def new_issue_path
        new_issue_url
      end

      def issue_path(iid)
        issue_url(iid)
      end

      def reference_pattern(only_long: false)
        self.class.base_reference_pattern(only_long: only_long)
      end

      private

      def other_external_issue_trackers
        return [] unless project_level?

        @other_external_issue_trackers ||= project.integrations.external_issue_trackers.where.not(id: id)
      end

      def one_issue_tracker
        return if instance? || project.blank? || other_external_issue_trackers.empty?

        errors.add(:base,
          _('Another issue tracker is already in use. Only one issue tracker service can be active at a time'))
      end
    end

    class_methods do
      def base_reference_pattern(only_long: false)
        if only_long
          /(\b[A-Z][A-Z0-9_]*-)#{Gitlab::Regex.issue}/
        else
          /(\b[A-Z][A-Z0-9_]*-|#{Issue.reference_prefix})#{Gitlab::Regex.issue}/
        end
      end

      def supported_events
        %w[]
      end
    end
  end
end
