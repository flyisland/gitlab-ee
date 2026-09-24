# frozen_string_literal: true

module JH
  module NotesActions
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override
    include ContentValidationMessages

    override :create
    def create
      return super if params[:note].blank? || !::ContentValidation::Setting.check_enabled?(project)

      content_validation_service = ContentValidation::ContentValidationService.new
      unless content_validation_service.valid?(params[:note][:note])
        json = {
          valid: false,
          content_invalid: true,
          errors: illegal_characters_tips_with_appeal_email
        }
        render json: json, status: :unprocessable_entity
        return
      end

      super
    end

    override :update
    def update
      return super if params[:note].blank? || !::ContentValidation::Setting.check_enabled?(project)

      content_validation_service = ContentValidation::ContentValidationService.new
      unless content_validation_service.valid?(params[:note][:note])
        json = {
          valid: false,
          content_invalid: true,
          errors: illegal_characters_tips_with_appeal_email
        }
        render json: json, status: :unprocessable_entity
        return
      end

      super
    end
  end
end
