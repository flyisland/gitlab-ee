# frozen_string_literal: true

require 'spec_helper'
RSpec.describe ::JH::Captcha::TencentCloud do
  describe '.verify' do
    let(:rand_str) { '@EcF' }
    let(:ticket) { 't03Z2y17' }

    subject { described_class.verify!(ticket, nil, rand_str) }

    it 'returns nil by default' do
      expect(subject).to be_nil
    end

    context 'when verify via api call' do
      let(:cli) do
        instance_double(TencentCloud::Captcha::V20190722::Client)
      end

      let(:response) do
        instance_double(TencentCloud::Captcha::V20190722::DescribeCaptchaResultResponse)
      end

      before do
        stub_env('TC_CAPTCHA_ID', '1')
        stub_env('TC_CAPTCHA_KEY', '2')
        stub_env('TC_CAPTCHA_APP_ID', '3')
        stub_env('TC_CAPTCHA_APP_SECRET_KEY', '4')
        allow(TencentCloud::Captcha::V20190722::Client).to receive(:new).and_return(cli)
        allow(TencentCloud::Captcha::V20190722::DescribeCaptchaAppIdInfoResponse).to receive(:new).and_return(cli)
      end

      context 'when response is successful' do
        it 'returns true' do
          expect(cli).to receive(:DescribeCaptchaResult).and_return(response)
          expect(response).to receive(:CaptchaCode).and_return(1)
          expect(response).to receive(:EvilLevel).and_return(0)
          expect(subject).to be_truthy
        end

        context 'when EvilLevel is nil' do
          it 'returns true' do
            expect(cli).to receive(:DescribeCaptchaResult).and_return(response)
            expect(response).to receive(:CaptchaCode).and_return(1)
            expect(response).to receive(:EvilLevel).and_return(nil)
            expect(subject).to be_truthy
          end
        end
      end

      context 'when CaptchaCode is not 1' do
        it 'returns false' do
          expect(cli).to receive(:DescribeCaptchaResult).and_return(response)
          expect(response).to receive(:CaptchaCode).and_return(2)
          expect(subject).to be_falsey
        end
      end

      context 'when EvilLevel is 100' do
        it 'returns false' do
          expect(cli).to receive(:DescribeCaptchaResult).and_return(response)
          expect(response).to receive(:CaptchaCode).and_return(1)
          expect(response).to receive(:EvilLevel).and_return(100)
          expect(subject).to be_falsey
        end
      end
    end
  end
end
