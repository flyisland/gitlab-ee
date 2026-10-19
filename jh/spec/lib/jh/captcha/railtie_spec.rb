# frozen_string_literal: true

require 'spec_helper'
RSpec.describe JH::Captcha::Railtie do
  describe 'recaptcha_tags' do
    before do
      allow(Gitlab).to receive(:com?).and_return(true)
    end

    subject { Recaptcha::Helpers.recaptcha_tags }

    it { is_expected.to include 'js-captcha' }
  end
end
