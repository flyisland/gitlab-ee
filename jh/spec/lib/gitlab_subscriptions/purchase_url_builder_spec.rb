# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::PurchaseUrlBuilder, feature_category: :subscription_management do
  describe '#build' do
    let(:subscription_portal_url) { Gitlab::Routing.url_helpers.subscription_portal_url }

    context 'when the plan is not supplied' do
      it 'generates the marketing page URL' do
        builder = described_class.new(plan_id: nil, namespace: nil)

        expect(builder.build).to eq "https://about.gitlab.cn/pricing"
      end
    end
  end
end
