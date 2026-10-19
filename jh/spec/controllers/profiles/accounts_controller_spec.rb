# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Profiles::AccountsController do
  describe 'DELETE unlink' do
    let(:user) { create(:omniauth_user) }

    before do
      sign_in(user)
    end

    describe "cas3 provider" do
      let(:user) { create(:omniauth_user, provider: 'cas3') }

      it "does not allow to unlink connected account" do
        identity = user.identities.last

        delete :unlink, params: { provider: 'cas3' }

        expect(response).to have_gitlab_http_status(:found)
        expect(user.reset.identities).to include(identity)
      end
    end

    [:dingtalk].each do |provider|
      describe "#{provider} provider" do
        let(:user) { create(:omniauth_user, provider: provider.to_s) }

        it 'allows to unlink connected account' do
          identity = user.identities.last

          delete :unlink, params: { provider: provider.to_s }

          expect(response).to have_gitlab_http_status(:found)
          expect(user.reset.identities).not_to include(identity)
        end
      end
    end
  end
end
