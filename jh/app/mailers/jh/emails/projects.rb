# frozen_string_literal: true

module JH
  module Emails
    module Projects
      def rollback_visibility_level_email(project_id, user_id, obj)
        @project = ::Project.find project_id
        @user = ::User.find user_id
        @obj_url = obj_url(obj)
        emails = email_receivers_for(@user, @project)

        mail_with_locale(
          to: emails,
          subject: subject(
            format(s_("JH|ContentValidation|Illegal contents are detected in your project %{project_name}"),
              project_name: @project.full_name)
          )
        ) do |format|
          format.html { render layout: 'mailer' }
          format.text { render layout: 'mailer' }
        end
      end

      private

      def email_receivers_for(user, project)
        recipients = [user.email]
        recipients << project.owner.try(:email) unless project.group
        recipients.uniq.compact
      end

      def obj_url(obj)
        case obj
        when ::MergeRequest
          project_merge_request_url(@project, obj)
        when ::Issue
          ::Gitlab::UrlBuilder.build(obj)
        when ::Note
          suffix = "#note_#{obj.id}"
          url =
            case obj.noteable_type
            when 'Issue'
              ::Gitlab::UrlBuilder.build(obj.noteable)
            when 'MergeRequest'
              project_merge_request_url(@project, obj.noteable)
            when 'Snippet'
              project_snippet_url(@project, obj.noteable)
            when 'Commit'
              project_commit_url(@project, obj.noteable)
            end
          url.nil? ? edit_project_url(obj) : (url + suffix)
        else
          edit_project_url(obj)
        end
      end
    end
  end
end
