# frozen_string_literal: true

module JH
  module Notes
    module UpdateService
      extend ::Gitlab::Utils::Override
      include ContentValidationMessages

      override :execute
      def execute(note)
        return super unless ::ContentValidation::Setting.check_enabled?(project)
        return super unless note.for_issue? # only check issue note

        note.assign_attributes(params)
        return super unless note.note_changed?
        return super if ContentValidation::ContentValidationService.new.valid?(note.note)

        note.errors.add(:note, illegal_characters_tips_with_appeal_email)
        note
      end
    end
  end
end
