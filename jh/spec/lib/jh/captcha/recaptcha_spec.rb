# frozen_string_literal: true

require 'spec_helper'
RSpec.describe Recaptcha, feature_category: :system_access do
  describe '.verify_via_api_call' do
    let(:rand_str) { '@EcF' }
    let(:ticket) { 't03Z2y17' }
    let(:captcha_response) { Base64.encode64(Gitlab::Json.generate({ rand_str: rand_str, ticket: ticket })) }

    subject { described_class.verify_via_api_call(captcha_response, {}) }

    context 'when it is JH COM', :saas do
      it 'calls Geetest captcha' do
        expect(::JH::Captcha::Geetest).to receive(:verify!).and_return(true)
        expect(subject).to be(true)
      end

      context 'when geetest_captcha disabled' do
        before do
          stub_feature_flags(geetest_captcha: false)
        end

        it 'calls Tencent captcha api' do
          expect(::JH::Captcha::TencentCloud).to receive(:verify!).and_return(true)

          expect(subject).to be(true)
        end
      end

      context 'with decoding errors' do
        let(:captcha_response) { 'wrong_response' }

        it 'returns false' do
          expect(subject).to be(false)
        end

        context 'when use tencent captcha' do
          before do
            stub_feature_flags(geetest_captcha: false)
          end

          it 'returns false' do
            expect(subject).to be(false)
          end
        end
      end
    end

    context 'when it is not JH COM' do
      it 'calls Google reCAPTCHA api' do
        expect(described_class).to receive(:google_captcha_verify_via_api_call).and_return(true)
        expect(subject).to be(true)
      end
    end
  end
end
