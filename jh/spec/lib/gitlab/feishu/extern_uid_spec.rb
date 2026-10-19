# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Gitlab::Feishu::ExternUid, feature_category: :system_access do
  subject(:open_id) { described_class.open_id_for(uid, tenant_key: 'tenant', app_id: 'cli_app') }

  let(:uid) { 'tenant:cli_app:ou_user' }

  it 'resolves the open ID of a matching identity' do
    expect(open_id).to eq('ou_user')
  end

  [nil, '', 'ou_user', 'other:cli_app:ou_user', 'tenant:other:ou_user',
    'tenant:cli_app:', 'tenant:cli_app:ou_user:extra', "tenant:cli_app:ou_user\n"].each do |value|
    context "with #{value.inspect}" do
      let(:uid) { value }

      it 'does not resolve a recipient' do
        expect(open_id).to be_nil
      end
    end
  end
end
