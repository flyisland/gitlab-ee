# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Validations::Validators::Phone do
  include ApiValidatorsHelpers

  subject do
    described_class.new(['test'], {}, false, scope.new, {})
  end

  context 'with valid user phone' do
    it 'does not raise a validation error' do
      expect_no_validation_error('test' => '+8615612341234')
      expect_no_validation_error('test' => '+85212345678')
    end
  end

  context 'with any invalid user phone' do
    it 'raises a validation error' do
      expect_validation_error('test' => '15612341234')
      expect_validation_error('test' => '+86156123412341')
      expect_validation_error('test' => '+861561234123x')
    end
  end
end
