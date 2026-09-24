# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Saas, feature_category: :environment_management do
  using RSpec::Parameterized::TableSyntax

  where(:method_name, :test, :development, :result) do
    :customer_support_url           | false | false  | 'https://support.gitlab.cn'
    :customer_support_url           | false | true   | 'https://support.gitlab.cn'
    :customer_support_url           | true  | false  | 'https://support.gitlab.cn'
    :customer_license_support_url   | false | false  | 'https://support.gitlab.cn/#/portal/submitticket/3'
    :customer_license_support_url   | false | true   | 'https://support.gitlab.cn/#/portal/submitticket/3'
    :customer_license_support_url   | true  | false  | 'https://support.gitlab.cn/#/portal/submitticket/3'
    :gitlab_com_status_url          | false | false  | 'https://status.gitlab.cn'
    :gitlab_com_status_url          | false | true   | 'https://status.gitlab.cn'
    :gitlab_com_status_url          | true  | false  | 'https://status.gitlab.cn'
  end

  with_them do
    subject { described_class.method(method_name).call }

    before do
      allow(Rails).to receive_message_chain(:env, :test?).and_return(test)
      allow(Rails).to receive_message_chain(:env, :development?).and_return(development)
    end

    it { is_expected.to eq(result) }
  end

  context 'when is in HK region' do
    before do
      stub_env('SAAS_REGION', 'HK')
    end

    it 'returns HK urls' do
      expect(Gitlab.hk?).to be(true)
      expect(Gitlab.com_url).to eq('https://gitlab.hk')
      expect(Gitlab.staging_com_url).to eq('https://staging.gitlab.hk')
    end

    it 'matches the hk subdomain' do
      expect(Gitlab.subdomain_regex).to match('https://staging.gitlab.hk')
      expect(Gitlab.subdomain_regex).not_to match('https://staging.jihulab.com')
    end
  end

  describe '.feature_available?', :saas do
    # rubocop:disable Gitlab/FeatureAvailableUsage -- for test
    it 'return false when google_cloud_support' do
      expect(described_class.feature_available?(:google_cloud_support)).to be_falsy
    end

    it 'return true when onboarding' do
      expect(described_class.feature_available?(:onboarding)).to be_truthy
    end
    # rubocop:enable Gitlab/FeatureAvailableUsage

    # rubocop:disable Gitlab/FeatureAvailableUsage -- for test
    context 'when pipl_compliance is requested' do
      it 'is not available on JH SaaS' do
        expect(described_class.feature_available?(:pipl_compliance)).to be_falsy
      end

      context 'when in the HK region' do
        around do |example|
          original_url = Gitlab.config.gitlab['url']
          example.run
        ensure
          Gitlab.config.gitlab['url'] = original_url
        end

        before do
          stub_env('SAAS_REGION', 'HK')
          Gitlab.config.gitlab['url'] = Gitlab.com_url
        end

        it 'is not available on JH HK SaaS' do
          expect(Gitlab.com?).to be(true)
          expect(described_class.feature_available?(:pipl_compliance)).to be_falsy
        end
      end

      context 'when enforce_pipl_compliance is enabled' do
        before do
          stub_ee_application_setting(enforce_pipl_compliance: true)
        end

        it 'is still not available' do
          expect(described_class.feature_available?(:pipl_compliance)).to be_falsy
        end
      end
    end
    # rubocop:enable Gitlab/FeatureAvailableUsage
  end
end
