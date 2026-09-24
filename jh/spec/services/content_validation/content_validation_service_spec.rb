# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContentValidation::ContentValidationService do
  let(:content_validation_service) { described_class.new }

  describe '#valid?' do
    context 'with webmock response true' do
      before do
        stub_content_validation_request(true)
      end

      it 'contain untrust content' do
        expect(content_validation_service.valid?("Hello giltab!")).to be true
      end
    end

    context 'with webmock response false' do
      before do
        stub_content_validation_request(false)
      end

      it 'trust content' do
        expect(content_validation_service.valid?("wow sensitive")).to be false
      end
    end
  end
end
