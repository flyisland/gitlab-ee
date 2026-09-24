# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Admin::Users::SearchUserByPhone', feature_category: :user_management do
  include StubENV

  let(:user_phone) { "+8615688888888" }
  let(:encrypted_phone) { ::Gitlab::CryptoHelper.aes256_gcm_encrypt(user_phone) }

  let_it_be(:admin) { create(:admin) }

  before do
    sign_in(admin)
    enable_admin_mode!(admin)
  end

  context 'when it is JH COM', :saas do
    describe 'search user by phone in admin panel' do
      before do
        create(:user, name: "Alice C", phone: encrypted_phone)
      end

      it 'shows user with phone' do
        visit admin_users_path

        expect(find('#js-admin-users-app')["data-users"]).to include("Alice C")
      end

      context "when use phone without area code" do
        it 'shows user with phone' do
          visit admin_users_path(search_query: "15688888888")

          expect(find('#js-admin-users-app')["data-users"]).to include("Alice C")
        end
      end

      context "when phone not exists" do
        it 'not showing user' do
          visit admin_users_url(search_query: "+8615688888899")

          expect(find('#js-admin-users-app')["data-users"]).not_to include("Alice C")
        end
      end
    end
  end
end
