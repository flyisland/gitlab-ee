# frozen_string_literal: true

require 'fast_spec_helper'
require 'omniauth-wecom'

require_relative '../../../../lib/gitlab/wecom/extern_uid'

RSpec.describe Gitlab::Wecom::ExternUid, feature_category: :system_access do
  let(:corp_id) { 'ww1234567890abcdef' }
  let(:user_id) { 'zhang.san@example' }
  let(:extern_uid) { "#{corp_id}:#{user_id}" }

  it 'agrees with the separator the OmniAuth strategy writes' do
    expect(described_class::SEPARATOR).to eq(OmniAuth::Strategies::Wecom::UID_SEPARATOR)
  end

  describe '.encode' do
    it 'joins the corp id and the user id' do
      expect(described_class.encode(corp_id, user_id)).to eq(extern_uid)
    end

    it 'returns nil when either part is missing' do
      expect(described_class.encode(nil, user_id)).to be_nil
      expect(described_class.encode(corp_id, '')).to be_nil
    end
  end

  describe '.decode' do
    it 'splits into corp id and user id' do
      expect(described_class.decode(extern_uid)).to eq([corp_id, user_id])
    end

    it 'splits on the first separator only, so user ids keep their own colons' do
      expect(described_class.decode("#{corp_id}:a:b")).to eq([corp_id, 'a:b'])
    end

    it 'returns nil for values that are not corp-scoped' do
      expect(described_class.decode(user_id)).to be_nil
      expect(described_class.decode(":#{user_id}")).to be_nil
      expect(described_class.decode("#{corp_id}:")).to be_nil
      expect(described_class.decode(nil)).to be_nil
    end
  end

  describe '.user_id_for' do
    it 'returns the user id when the corp id matches' do
      expect(described_class.user_id_for(extern_uid, corp_id)).to eq(user_id)
    end

    it 'returns nil when the corp id differs, so a stale binding cannot be used' do
      expect(described_class.user_id_for(extern_uid, 'ww_other_corp')).to be_nil
    end

    it 'returns nil when no corp id is configured' do
      expect(described_class.user_id_for(extern_uid, nil)).to be_nil
    end

    it 'returns nil for a legacy uid that carries no corp id' do
      expect(described_class.user_id_for(user_id, corp_id)).to be_nil
    end
  end
end
