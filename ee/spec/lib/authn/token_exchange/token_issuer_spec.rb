# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Authn::TokenExchange::TokenIssuer, feature_category: :system_access do
  let_it_be(:cloud_connector_key) { create(:cloud_connector_keys) }
  let_it_be(:user) { create(:user) }

  let(:audience) { ['gitlab-artifact-registry'] }
  let(:ttl) { 300 }

  before do
    # CachingKeyLoader memoizes Keys.current at the class level, which leaks
    # across specs when other specs also create keys. Pin it to ours.
    allow(::CloudConnector::CachingKeyLoader).to receive(:private_jwk)
      .and_return(cloud_connector_key.to_jwk)
    allow(Doorkeeper::OpenidConnect.configuration).to receive(:issuer)
      .and_return('http://test.host/oauth-issuer')
    allow(::CloudConnector).to receive(:gitlab_realm).and_return('self-managed')
  end

  subject(:issuer) do
    described_class.new(audience: audience, user: user, ttl: ttl)
  end

  describe '#token' do
    it 'returns a signed JWT with the expected claim shape', :aggregate_failures do
      token = issuer.token

      payload, header = JWT.decode(token, cloud_connector_key.public_key, true, algorithm: 'RS256')

      expect(header).to include('typ' => 'JWT', 'alg' => 'RS256')
      expect(header['kid']).to eq(cloud_connector_key.to_jwk.kid)

      expect(payload).to include(
        'iss' => 'http://test.host/oauth-issuer',
        'aud' => ['gitlab-artifact-registry'],
        'sub' => user.id.to_s,
        'gitlab_realm' => 'self-managed',
        'gitlab_organization_id' => user.organization_id
      )
      expect(payload['jti']).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets iat, nbf, and exp', :freeze_time, :aggregate_failures do
      token = issuer.token
      payload, = JWT.decode(token, cloud_connector_key.public_key, true, algorithm: 'RS256')

      expect(payload['iat']).to eq(Time.current.to_i)
      expect(payload['nbf']).to eq(Time.current.to_i)
      expect(payload['exp']).to eq(Time.current.to_i + ttl)
    end

    it 'generates a fresh jti per mint' do
      jti1 = JWT.decode(issuer.token, nil, false).first['jti']
      jti2 = JWT.decode(issuer.token, nil, false).first['jti']

      expect(jti1).not_to eq(jti2)
    end

    describe 'gitlab_organization_role claim' do
      def decoded_role(for_user)
        token = described_class.new(audience: audience, user: for_user, ttl: ttl).token
        JWT.decode(token, cloud_connector_key.public_key, true, algorithm: 'RS256').first['gitlab_organization_role']
      end

      it "emits 'member' when the user does not own the organization" do
        expect(decoded_role(user)).to eq('member')
      end

      it "emits 'owner' when the user owns the organization" do
        owner = create(:user)
        owner.organization_users.find_by(organization: owner.organization).update!(access_level: :owner)

        expect(decoded_role(owner)).to eq('owner')
      end
    end
  end
end
