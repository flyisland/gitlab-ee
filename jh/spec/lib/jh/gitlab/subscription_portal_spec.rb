# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::SubscriptionPortal do
  using RSpec::Parameterized::TableSyntax
  include SubscriptionPortalHelper

  let(:env_value) { nil }

  before do
    stub_env('CUSTOMER_PORTAL_URL', env_value)
    stub_env('STAGING_CUSTOMER_PORTAL_URL', env_value)
  end

  describe 'class methods' do
    where(:method_name, :result) do
      :default_staging_customer_portal_url | 'https://customers-stg.jihulab.com'
      :default_production_customer_portal_url | 'https://customers.jihulab.com'
    end

    with_them do
      subject { described_class.send(method_name) }

      it { is_expected.to eq(result) }
    end
  end
end
