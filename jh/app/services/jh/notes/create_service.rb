# frozen_string_literal: true

module JH
  module Notes
    module CreateService
      extend ::Gitlab::Utils::Override
      include ContentValidationMessages

      override :execute
      def execute(
        skip_capture_diff_note_position: false, skip_merge_status_trigger: false, executing_user: nil, importing: false)
        return super if params[:note].blank? || !::ContentValidation::Setting.check_enabled?(project)

        note = ::Notes::BuildService.new(project, current_user,
          params.except(:merge_request_diff_head_sha, :scope_validator)).execute(executing_user: executing_user)
        return super unless note.for_issue? # only check issue note
        return super if ContentValidation::ContentValidationService.new.valid?(note.note)

        note.errors.add(:note, illegal_characters_tips_with_appeal_email)
        note
      end
    end
  end
end
