# frozen_string_literal: true

# ContentValidation for input content
class ContentValidationValidator < ActiveModel::EachValidator
  include JH::ContentValidationMessages

  def validate_each(record, attribute, value)
    return if value.blank?
    return unless record.public_send(:"#{attribute}_changed?")

    content_validation_service = ContentValidation::ContentValidationService.new
    unless content_validation_service.valid?(value)
      record.errors.add(
        attribute,
        :content_invalid,
        message: illegal_characters_tips_with_appeal_email
      )
    end
  rescue StandardError => e
    # If the external service is down or other error happen, we don't want to block record save
    Gitlab::AppLogger.error(e)
  end
end
