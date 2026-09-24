# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Captcha::CaptchaVerificationService, feature_category: :system_access do
  describe '#execute' do
    before do
      allow(Gitlab).to receive(:com?).and_return(true)
    end

    let(:rand_str) { '@EcF' }
    let(:ticket) { 't03Z2y17' }
    let(:captcha_response) { Base64.encode64(Gitlab::Json.generate({ rand_str: rand_str, ticket: ticket })) }
    let(:fake_ip) { '1.2.3.4' }
    let(:spam_params) do
      ::Spam::SpamParams.new(
        captcha_response: captcha_response,
        spam_log_id: double,
        ip_address: fake_ip,
        user_agent: double,
        referer: double
      )
    end

    let(:service) { described_class.new(spam_params: spam_params) }

    subject { service.execute }

    context 'when there is no captcha_response' do
      let(:captcha_response) { nil }

      it 'returns false' do
        expect(subject).to be(false)
      end
    end

    context 'with a captcha_response' do
      before do
        expect(Gitlab::Recaptcha).to receive(:load_configurations!)
        allow(::Recaptcha).to receive(:skip_env?).and_return(false)
      end

      context 'when use geetest_captcha' do
        it 'returns true' do
          expect(::JH::Captcha::Geetest).to receive(:verify!).with({ rand_str: rand_str,
ticket: ticket }).and_return(true)
          expect(service.execute).to be(true)
        end
      end

      context 'when use tencent_captcha' do
        before do
          stub_feature_flags(geetest_captcha: false)
        end

        it 'returns true' do
          expect(::JH::Captcha::TencentCloud).to receive(:verify!).with(ticket, fake_ip, rand_str).and_return(true)
          expect(service.execute).to be(true)
        end
      end
    end
  end
end
