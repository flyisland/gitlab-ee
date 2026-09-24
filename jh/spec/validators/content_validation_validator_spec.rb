# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContentValidationValidator do
  let(:validator) { described_class.new(attributes: [:name]) }
  let(:illegal_characters_tips_with_appeal_email) do
    s_("JH|ContentValidation|Your content couldn't be submitted because it violated the rules. " \
      "If you believe this was a miscalculation, please email usersupport@gitlab.cn to appeal. " \
      "We will process your appeal within 24 hours (working days) and send the result to your registered " \
      "email address, please pay attention to it. Thank you for your understanding and support.")
  end

  describe '#validates_each' do
    it 'content has sentitive words' do
      stub_content_validation_request(false)
      user = build(:user)

      validator.validate_each(user, :name, 'sensitive words')

      expect(user.errors[:name]).to match_array([illegal_characters_tips_with_appeal_email])
    end

    it 'has no sentitive words' do
      stub_content_validation_request(true)
      user = build(:user)

      validator.validate_each(user, :name, 'Hello gitlab')

      expect(user.errors[:name]).to eq([])
    end

    it 'content validation service raise error' do
      stub_content_validation_request(false)
      allow_next_instance_of(ContentValidation::ContentValidationService) do |instance|
        allow(instance).to receive(:valid?).and_raise(StandardError)
      end

      user = build(:user)

      validator.validate_each(user, :name, 'Hello gitlab')

      expect(user.errors[:name]).to eq([])
    end
  end
end
