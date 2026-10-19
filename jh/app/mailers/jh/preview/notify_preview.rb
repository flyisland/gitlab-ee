# frozen_string_literal: true

module JH
  module Preview
    module NotifyPreview
      extend ActiveSupport::Concern

      # We need to define the methods on the prepender directly because:
      # https://github.com/rails/rails/blob/3faf7485623da55215d6d7f3dcb2eed92c59c699/actionmailer/lib/action_mailer/preview.rb#L73
      prepended do
        def rollback_visibility_level_email
          ::Gitlab::ExclusiveLease.skipping_transaction_check do
            cleanup do
              note = create_note(noteable_type: 'Issue', noteable_id: issue.id, note: 'Issue note content')

              ::Notify.rollback_visibility_level_email(note.project.id, user.id, note).message
            end
          end
        end

        def notice_password_is_expiring_email
          ::Notify.notice_password_is_expiring_email(user, Time.current.to_date).message
        end
      end
    end
  end
end
