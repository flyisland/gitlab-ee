# frozen_string_literal: true

require 'spec_helper'
RSpec.describe ::JH::Captcha::Geetest, feature_category: :system_access do
  let(:captcha_response) do
    { lot_number: '1',
      captcha_output: '2',
      pass_token: '3',
      gen_time: '4' }
  end

  subject { described_class.verify!(captcha_response) }

  describe '.verify!' do
    before do
      stub_env('GEETEST_CAPTCHA_ID', 'fake_id')
      stub_env('GEETEST_CAPTCHA_KEY', 'fake_key')
    end

    context 'when success' do
      before do
        stub_request(:post, "#{JH::Captcha::Geetest.api_server}/validate?captcha_id=fake_id")
          .to_return(status: 200, body: '{"result": "success"}')
      end

      it 'returns true' do
        expect(subject).to be_truthy
      end
    end

    context 'when failed' do
      before do
        stub_request(:post, "#{JH::Captcha::Geetest.api_server}/validate?captcha_id=fake_id")
          .to_return(status: 200, body: '{"result": "fail"}')
      end

      it 'returns true' do
        expect(subject).to be_falsey
      end
    end

    context 'when response 500' do
      before do
        stub_request(:post, "#{JH::Captcha::Geetest.api_server}/validate?captcha_id=fake_id")
          .to_return(status: 500)
      end

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end
end
