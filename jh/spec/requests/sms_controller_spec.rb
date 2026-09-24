# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SmsController, feature_category: :system_access do
  describe 'POST #verification_code' do
    let(:sms_code) { '123456' }
    let(:phone) { FFaker::PhoneNumber.short_phone_number }
    let(:area_code) { '+86' }
    let(:params) { { phone: phone, area_code: area_code } }
    let(:visitor_id_code) { 'b356c5e5f623717dbf219975b859f25f' }

    context 'when pass phone blank' do
      let(:params) { { phone: nil, area_code: area_code } }

      it 'renders PARAMS_BLANK_ERROR' do
        post verification_code_sms_url, params: params

        expect(response).to have_http_status(:ok)
        expected_json = Gitlab::Json.generate({ status: 'PARAMS_BLANK_ERROR' })
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when it is JH COM' do
      let(:expected_json) { Gitlab::Json.generate({ status: 'OK' }) }

      before do
        allow(::Gitlab).to receive_messages(jh?: true, com?: true)
      end

      context 'when use geetest' do
        it 'passes the code verification' do
          expect(JH::Sms::TencentSms).to receive(:send_code).and_return sms_code
          expect(Recaptcha).to receive(:geetest_captcha_verify_via_api_call).once.and_return true
          expect_next_instance_of(described_class) do |instance|
            expect(instance).to receive(:visitor_id_code).and_return visitor_id_code
          end

          post verification_code_sms_url, params: params

          expect(response).to have_http_status(:ok)
          expect(response.body).to eq(expected_json)
        end
      end

      context 'when use tencent_cloud captcha' do
        before do
          stub_feature_flags(geetest_captcha: false)
        end

        it 'passes the code verification' do
          expect(JH::Sms::TencentSms).to receive(:send_code).and_return sms_code
          expect(::JH::Captcha::TencentCloud).to receive(:verify!).and_return true
          expect_next_instance_of(described_class) do |instance|
            expect(instance).to receive(:visitor_id_code).and_return visitor_id_code
          end

          post verification_code_sms_url, params: params

          expect(response).to have_http_status(:ok)
          expect(response.body).to eq(expected_json)
        end
      end
    end

    context 'when it is not JH COM' do
      it 'returns error' do
        post verification_code_sms_url, params: params

        expected_json = Gitlab::Json.generate({ status: 'SENDING_CODE_ERROR' })
        expect(response.body).to eq(expected_json)
      end
    end

    context 'for CSRF safety', :allow_forgery_protection do
      before do
        stub_application_setting(recaptcha_enabled: false)
      end

      subject do
        post verification_code_sms_url, params: params,
          headers: { 'X-CSRF-Token' => 'invalid token' }
      end

      context 'with invalid X-CSRF-Token' do
        it { expect { subject }.to raise_exception(ActionController::InvalidAuthenticityToken) }
      end
    end
  end
end
