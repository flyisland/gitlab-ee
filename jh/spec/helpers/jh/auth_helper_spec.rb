# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuthHelper, feature_category: :system_access do
  describe 'popular_enabled_button_based_providers', :saas do
    it 'returns the intersection set of popular & enabled providers' do
      allow(helper).to receive(:enabled_button_based_providers).and_return(%w[twitter github gitlab])
      expect(helper.popular_enabled_button_based_providers).to eq(%w[github gitlab])

      allow(helper).to receive(:enabled_button_based_providers).and_return(%w[gitlab bitbucket])
      expect(helper.popular_enabled_button_based_providers).to eq(%w[gitlab])

      allow(helper).to receive(:enabled_button_based_providers).and_return(%w[bitbucket])
      expect(helper.popular_enabled_button_based_providers).to be_empty

      allow(helper).to receive(:enabled_button_based_providers).and_return(%w[gitlab github dingtalk alicloud])
      expect(helper.popular_enabled_button_based_providers).to eq(%w[gitlab github dingtalk alicloud])
    end

    it 'returns enabled providers with sorted order' do
      allow(helper).to receive(:button_based_providers).and_return(%w[alicloud dingtalk gitlab github])
      expect(helper.enabled_button_based_providers).to eq(%w[github gitlab dingtalk alicloud])
    end
  end

  describe '#enabled_button_based_providers' do
    before do
      allow(helper).to receive(:button_based_providers).and_return(%w[github wecom gitlab dingtalk])
    end

    # WeCom sign-in needs a prior binding, so it must not sit among the
    # providers anyone can use. Upstream sorting decides the rest.
    it 'puts WeCom last' do
      expect(helper.enabled_button_based_providers.last).to eq('wecom')
    end

    it 'puts WeCom last on SaaS too', :saas do
      expect(helper.enabled_button_based_providers.last).to eq('wecom')
    end

    it 'keeps every other provider' do
      expect(helper.enabled_button_based_providers).to match_array(%w[github wecom gitlab dingtalk])
    end
  end

  describe '#provider_has_builtin_icon?' do
    # provider_image_tag builds the filename from the provider name, so the
    # asset has to exist or the sign-in button renders a broken image.
    %w[dingtalk wecom].each do |provider|
      it "is true for #{provider}, and ships the matching asset" do
        expect(helper.provider_has_builtin_icon?(provider)).to be(true)

        asset = Rails.root.join('jh/app/assets/images/auth_buttons', "#{provider}_64.png")
        expect(asset).to exist
      end
    end

    it 'leaves other providers to upstream' do
      expect(helper.provider_has_builtin_icon?('some_other_provider')).to be(false)
    end
  end

  describe '#enabled_button_based_providers_for_signup' do
    before do
      allow(helper).to receive(:enabled_button_based_providers).and_return(%w[github wecom])
    end

    # An instance that opens sign-up to every provider must still not offer
    # WeCom, which cannot create an account.
    it 'leaves WeCom out when every provider is allowed' do
      stub_omniauth_setting(allow_single_sign_on: true)

      expect(helper.enabled_button_based_providers_for_signup).to eq(%w[github])
    end

    it 'leaves WeCom out even when it is listed explicitly' do
      stub_omniauth_setting(allow_single_sign_on: %w[github wecom])

      expect(helper.enabled_button_based_providers_for_signup).to eq(%w[github])
    end

    it 'keeps WeCom available for signing in' do
      stub_omniauth_setting(allow_single_sign_on: true)

      expect(helper.enabled_button_based_providers).to include('wecom')
    end
  end

  describe '#jh_signup_button_based_providers' do
    before do
      allow(helper).to receive(:enabled_button_based_providers).and_return(%w[github wecom])
    end

    # The JH sign-up page does not filter by allow_single_sign_on, so neither
    # does this. WeCom is the only thing it takes out.
    it 'drops WeCom and leaves the rest alone' do
      stub_omniauth_setting(allow_single_sign_on: %w[gitlab])

      expect(helper.jh_signup_button_based_providers).to eq(%w[github])
    end
  end
end
