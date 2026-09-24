# frozen_string_literal: true

module JH
  module WikiActions
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override
    include ContentValidationMessages

    private

    override :send_wiki_file_blob
    def send_wiki_file_blob(wiki, file_blob)
      return super unless ::ContentValidation::Setting.block_enabled?(wiki)

      content_blocked_state = ::ContentValidation::ContentBlockedState.find_by_container_file_path(
        wiki,
        file_blob.path)

      return super unless content_blocked_state.present?

      render plain: illegal_tips_with_appeal_email
    end
  end
end
