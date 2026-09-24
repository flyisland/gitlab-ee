# frozen_string_literal: true

module EE
  module SignUpHelpers
    extend ::Gitlab::Utils::Override

    override :fill_in_sign_up_form
    def fill_in_sign_up_form(new_user, invite: false)
      # JH accept terms
      terms_checkbox = all("input[data-testid='new-user-terms-accepted']", minimum: 0, wait: 0).first
      terms_checkbox&.set(true)

      super
    end
  end
end
