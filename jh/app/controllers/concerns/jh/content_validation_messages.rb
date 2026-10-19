# frozen_string_literal: true

module JH
  module ContentValidationMessages
    def illegal_tips
      s_("JH|ContentValidation|According to the relevant laws and regulations, this content is not displayed.")
    end

    def illegal_tips_with_appeal_email
      s_("JH|ContentValidation|According to the relevant laws and regulations, this content is not displayed. " \
        "If you believe this was a miscalculation, please email usersupport@gitlab.cn to appeal. " \
        "We will process your appeal within 24 hours (working days) and send the result to your registered " \
        "email address, please pay attention to it. Thank you for your understanding and support.")
    end

    def illegal_characters_tips_with_appeal_email
      s_("JH|ContentValidation|Your content couldn't be submitted because it violated the rules. " \
        "If you believe this was a miscalculation, please email usersupport@gitlab.cn to appeal. " \
        "We will process your appeal within 24 hours (working days) and send the result to your registered " \
        "email address, please pay attention to it. Thank you for your understanding and support.")
    end
  end
end
