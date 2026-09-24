# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Auth::OAuth::User, feature_category: :system_access do
  include JH::Gitlab::Auth::OAuth::AuthHash

  describe '#build_new_user' do
    let(:extra_params) { {} }
    let(:oauth_temp_email) { "#{temporarily_email_prefix}@example.com" }

    subject(:oauth_user) do
      described_class.new(OmniAuth::AuthHash.new(info: { email: oauth_temp_email }), extra_params)
    end

    context 'for identity verification concerns', feature_category: :insider_threat do
      context 'when identity verification is enabled' do
        before do
          allow_next_instance_of(User) do |user|
            allow(user).to receive(:signup_identity_verification_enabled?).and_return(true)
          end
        end

        it 'still confirms the user' do
          expect(oauth_user.gl_user).to be_confirmed
        end
      end
    end
  end
end
