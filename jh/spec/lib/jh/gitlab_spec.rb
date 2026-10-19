# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab, feature_category: :environment_management do
  using RSpec::Parameterized::TableSyntax

  where(:method_name, :test, :development, :result) do
    :com_url                        | false | false  | 'https://jihulab.com'
    :com_url                        | false | true   | 'https://jihulab.com'
    :com_url                        | true  | false  | 'https://jihulab.com'
    :staging_com_url                | false | false  | 'https://staging.jihulab.com'
    :staging_com_url                | false | true   | 'https://staging.jihulab.com'
    :staging_com_url                | true  | false  | 'https://staging.jihulab.com'
    :subdomain_regex                | false | false  | %r{\Ahttps://[a-z0-9-]+\.jihulab\.com\z}
    :subdomain_regex                | false | true   | %r{\Ahttps://[a-z0-9-]+\.jihulab\.com\z}
    :subdomain_regex                | true  | false  | %r{\Ahttps://[a-z0-9-]+\.jihulab\.com\z}
    :dev_url                        | false | false  | 'https://dev.gitlab.cn'
    :dev_url                        | false | true   | 'https://dev.gitlab.cn'
    :dev_url                        | true  | false  | 'https://dev.gitlab.cn'
    :commom_purchase_url            | false | false  | 'https://about.gitlab.cn/upgrade-plan'
    :commom_purchase_url            | false | true   | 'https://about.gitlab.cn/upgrade-plan'
    :commom_purchase_url            | true  | false  | 'https://about.gitlab.cn/upgrade-plan'
    :about_pricing_url              | false | false  | 'https://about.gitlab.cn/pricing'
    :about_pricing_url              | false | true   | 'https://about.gitlab.cn/pricing'
    :about_pricing_url              | true  | false  | 'https://about.gitlab.cn/pricing'
    :promo_host                     | false | false  | 'about.gitlab.cn'
    :promo_host                     | false | true   | 'about.gitlab.cn'
    :promo_host                     | true  | false  | 'about.gitlab.cn'
    :about_pricing_faq_url          | false | false  | 'https://about.gitlab.cn/pricing#faq'
    :about_pricing_faq_url          | false | true   | 'https://about.gitlab.cn/pricing#faq'
    :about_pricing_faq_url          | true  | false  | 'https://about.gitlab.cn/pricing#faq'
  end

  with_them do
    subject { described_class.method(method_name).call }

    before do
      allow(Rails).to receive_message_chain(:env, :test?).and_return(test)
      allow(Rails).to receive_message_chain(:env, :development?).and_return(development)
    end

    it { is_expected.to eq(result) }
  end

  describe '.hk?' do
    shared_examples 'is Hong Kong environment' do
      it 'hk? return true' do
        expect(Gitlab.hk?).to be true
      end
    end

    shared_examples 'is not Hong Kong environment' do
      it 'hk? return false' do
        expect(Gitlab.hk?).to be false
      end
    end

    context 'when SaaS region is HK' do
      before do
        stub_env('SAAS_REGION', 'HK')
      end

      it_behaves_like 'is Hong Kong environment'
    end

    context 'when SaaS region is not HK' do
      before do
        stub_env('SAAS_REGION', 'SOME_OTHER_REGION')
      end

      it_behaves_like 'is not Hong Kong environment'
    end

    context 'when has not envronment variable SAAS_REGION' do
      it_behaves_like 'is not Hong Kong environment'
    end
  end
end
