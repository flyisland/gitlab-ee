# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::ContentValidationMessages do
  let(:controller_class) do
    Class.new do
      include JH::ContentValidationMessages
    end
  end

  subject { controller_class.new }

  describe '#illegal_tips' do
    it 'return the correct message' do
      expect(subject.illegal_tips).to eq(
        s_("JH|ContentValidation|According to the relevant laws and regulations, this content is not displayed."))
    end
  end

  describe '#illegal_tips_with_appeal_email' do
    it 'return the correct message' do
      expect(subject.illegal_tips_with_appeal_email).to eq(
        s_("JH|ContentValidation|According to the relevant laws and regulations, this content is not displayed. " \
          "If you believe this was a miscalculation, please email usersupport@gitlab.cn to appeal. " \
          "We will process your appeal within 24 hours (working days) and send the result to your registered " \
          "email address, please pay attention to it. Thank you for your understanding and support."))
    end
  end

  describe '#illegal_characters_tips_with_appeal_email' do
    it 'return the correct message' do
      expect(subject.illegal_characters_tips_with_appeal_email).to eq(
        s_("JH|ContentValidation|Your content couldn't be submitted because it violated the rules. " \
          "If you believe this was a miscalculation, please email usersupport@gitlab.cn to appeal. " \
          "We will process your appeal within 24 hours (working days) and send the result to your registered " \
          "email address, please pay attention to it. Thank you for your understanding and support.")
      )
    end
  end
end
