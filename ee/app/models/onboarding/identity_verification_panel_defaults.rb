# frozen_string_literal: true

# Default identity-verification right-panel image and heading shared across
# registration types. `FreeRegistration` overrides these to render the collab
# illustration in place of the pipeline default.
module Onboarding
  module IdentityVerificationPanelDefaults
    def identity_verification_panel_image
      'subscription/pipeline'
    end

    def identity_verification_panel_heading
      s_('InProductMarketing|Ship software faster')
    end
  end
end
