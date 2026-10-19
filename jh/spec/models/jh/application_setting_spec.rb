# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApplicationSetting, feature_category: :shared do
  using RSpec::Parameterized::TableSyntax

  subject(:setting) { described_class.create_from_defaults }

  describe 'validations' do
    describe 'content_validation_endpoint' do
      context 'when content_validation_endpoint is enabled' do
        before do
          setting.content_validation_endpoint_enabled = true
        end

        it do
          is_expected.to(
            allow_value('https://example.org/content_validation').for(:content_validation_endpoint_url))
        end

        it { is_expected.not_to allow_value('nonsense').for(:content_validation_endpoint_url) }
        it { is_expected.not_to allow_value(nil).for(:content_validation_endpoint_url) }
        it { is_expected.not_to allow_value('').for(:content_validation_endpoint_url) }
      end

      context 'when content_validation_endpoint is NOT enabled' do
        before do
          setting.content_validation_endpoint_enabled = false
        end

        it { is_expected.not_to allow_value('nonsense').for(:content_validation_endpoint_url) }
        it { is_expected.to allow_value(nil).for(:content_validation_endpoint_url) }
        it { is_expected.to allow_value('').for(:content_validation_endpoint_url) }
      end
    end

    describe 'dingtalk integration' do
      context 'when enabled' do
        before do
          setting.dingtalk_integration_enabled = true
        end

        it { is_expected.not_to allow_value(nil).for(:dingtalk_app_key) }
        it { is_expected.not_to allow_value('').for(:dingtalk_app_key) }
        it { is_expected.to allow_value('some key').for(:dingtalk_app_key) }

        it { is_expected.not_to allow_value(nil).for(:dingtalk_app_secret) }
        it { is_expected.not_to allow_value('').for(:dingtalk_app_secret) }
        it { is_expected.to allow_value('some secret').for(:dingtalk_app_secret) }

        it { is_expected.not_to allow_value(nil).for(:dingtalk_corpid) }
        it { is_expected.not_to allow_value('').for(:dingtalk_corpid) }
        it { is_expected.to allow_value('some secret').for(:dingtalk_corpid) }
      end

      context 'when disabled' do
        before do
          setting.dingtalk_integration_enabled = false
        end

        it { is_expected.to allow_value(nil).for(:dingtalk_app_key) }
        it { is_expected.to allow_value('').for(:dingtalk_app_key) }

        it { is_expected.to allow_value(nil).for(:dingtalk_app_secret) }
        it { is_expected.to allow_value('').for(:dingtalk_app_secret) }

        it { is_expected.to allow_value(nil).for(:dingtalk_corpid) }
        it { is_expected.to allow_value('').for(:dingtalk_corpid) }
      end
    end

    describe 'feishu integration' do
      context 'when enabled' do
        before do
          setting.feishu_integration_enabled = true
        end

        it { is_expected.not_to allow_value(nil).for(:feishu_app_key) }
        it { is_expected.not_to allow_value('').for(:feishu_app_key) }
        it { is_expected.to allow_value('some key').for(:feishu_app_key) }

        it { is_expected.not_to allow_value(nil).for(:feishu_app_secret) }
        it { is_expected.not_to allow_value('').for(:feishu_app_secret) }
        it { is_expected.to allow_value('some secret').for(:feishu_app_secret) }
      end

      context 'when disabled' do
        before do
          setting.feishu_integration_enabled = false
        end

        it { is_expected.to allow_value(nil).for(:feishu_app_key) }
        it { is_expected.to allow_value('').for(:feishu_app_key) }

        it { is_expected.to allow_value(nil).for(:feishu_app_secret) }
        it { is_expected.to allow_value('').for(:feishu_app_secret) }
      end
    end

    describe 'password expiration integration' do
      context 'when password expiration enabled' do
        before do
          setting.password_expiration_enabled = true
        end

        context 'for password_expires_in_days' do
          context 'when is valid' do
            it { is_expected.to allow_value(91).for(:password_expires_in_days) }
          end

          context 'when is not valid' do
            it { is_expected.not_to allow_value(13).for(:password_expires_in_days) }
            it { is_expected.not_to allow_value(401).for(:password_expires_in_days) }
            it { is_expected.not_to allow_value(nil).for(:password_expires_in_days) }
            it { is_expected.not_to allow_value('').for(:password_expires_in_days) }
            it { is_expected.not_to allow_value('abc').for(:password_expires_in_days) }
          end
        end

        context 'for password_expires_notice_before_days' do
          context 'when is valid' do
            it { is_expected.to allow_value(8).for(:password_expires_notice_before_days) }
          end

          context 'when is not valid' do
            it { is_expected.not_to allow_value(0).for(:password_expires_notice_before_days) }
            it { is_expected.not_to allow_value(31).for(:password_expires_notice_before_days) }
          end
        end

        context 'when password_expires_in_days is less than password_expires_notice_before_days' do
          it do
            setting.password_expires_notice_before_days = 30
            setting.password_expires_in_days = 29
            expect(setting.valid?).to be false
          end
        end
      end

      context 'when password expiration disabled' do
        before do
          setting.password_expiration_enabled = false
        end

        it { is_expected.to allow_value(90).for(:password_expires_in_days) }
        it { is_expected.not_to allow_value(91).for(:password_expires_in_days) }
        it { is_expected.to allow_value(7).for(:password_expires_notice_before_days) }
        it { is_expected.not_to allow_value(8).for(:password_expires_notice_before_days) }
      end
    end
  end

  describe "jh_usage_statistics" do
    context "when feature is disabled" do
      before do
        stub_feature_flags(jh_usage_statistics: false)
      end

      context "when usage_ping_enabled is true" do
        before do
          setting.update!(usage_ping_enabled: true)
        end

        it "usage_ping_enabled return false" do
          expect(setting.usage_ping_enabled).to be(false)
        end
      end

      context "when version_check_enabled is true" do
        before do
          setting.update!(version_check_enabled: true)
        end

        it "version_check_enabled return false" do
          expect(setting.version_check_enabled).to be(false)
        end
      end
    end
  end

  describe 'default values' do
    it { expect(setting.ci_requires_identity_verification_on_free_plan).to be false }
  end
end
