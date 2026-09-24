# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Users > Terms', :js do
  let(:user) { create(:user) }
  let(:term_text) { 'By accepting, you promise to be nice!' }
  let!(:term) { create(:term, terms: term_text) }

  describe 'Phone verification', :phone_verification_code_enabled do
    let(:phone) { "+8615612341234" }
    let(:encrypted_phone) { ::Gitlab::CryptoHelper.aes256_gcm_encrypt(phone) }

    context 'when it is saas', :saas do
      context 'with a signed in user' do
        before do
          sign_in user
        end

        context 'when user without a phone' do
          it 'does not redirect to phone verification page' do
            expect(user.phone).to be_nil

            visit terms_path

            expect(page).to have_current_path(terms_path)
          end
        end
      end

      context 'without a signed in user' do
        it 'shows user menu items' do
          visit terms_path

          expect(page).to have_content(term_text)
        end
      end
    end
  end
end
