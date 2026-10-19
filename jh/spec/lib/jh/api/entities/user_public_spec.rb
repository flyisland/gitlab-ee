# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::JH::API::Entities::UserPublic do
  subject(:entity_as_json) { entity.as_json }

  let_it_be(:user) { create(:user, :with_namespace) }
  let_it_be(:raw_phone) { '+8618516261234' }
  let_it_be(:encrypted_phone) { ::Gitlab::CryptoHelper.aes256_gcm_encrypt(raw_phone) }

  let(:entity) { ::API::Entities::UserPublic.new(user) }

  context 'when it is not JH SaaS' do
    let_it_be(:user) { create(:user, :with_namespace, phone: encrypted_phone) }

    it 'does not contain phone field' do
      expect(entity_as_json).not_to have_key(:phone)
    end
  end

  context 'when it is JH SaaS', :saas do
    it 'returns nil' do
      expect(entity_as_json[:phone]).to be_nil
    end

    context 'when decrypt failed' do
      let_it_be(:user) { create(:user, :with_namespace, phone: raw_phone) }

      it 'returns nil' do
        expect(entity_as_json[:phone]).to be_nil
      end
    end

    context 'when user has a valid phone' do
      let_it_be(:user) { create(:user, :with_namespace, phone: encrypted_phone) }

      it 'returns the phone' do
        expect(entity_as_json[:phone]).to eq raw_phone
      end
    end
  end
end
