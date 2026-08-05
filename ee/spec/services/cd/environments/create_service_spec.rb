# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::Environments::CreateService, feature_category: :continuous_delivery do
  let_it_be(:organization) { create(:organization) }
  let_it_be(:current_user) { create(:user) }

  let(:params) do
    {
      name: 'staging',
      description: 'Staging environment'
    }
  end

  subject(:result) do
    described_class.new(parent: organization, current_user: current_user, params: params).execute
  end

  describe '#execute' do
    it 'returns a success response with the persisted environment' do
      expect { result }.to change { ::Cd::Environment.count }.by(1)

      environment = result.payload[:environment]
      expect(result).to be_success
      expect(environment).to be_persisted
      expect(environment).to have_attributes(
        organization: organization,
        name: 'staging',
        description: 'Staging environment'
      )
    end

    context 'when name is blank' do
      let(:params) { super().merge(name: '') }

      it 'does not create an environment and returns the error' do
        expect { result }.not_to change { ::Cd::Environment.count }
        expect(result).to be_error
        expect(result.message).to include("Name can't be blank")
      end
    end

    context 'when name is already taken in the organization' do
      before do
        create(:cd_environment, organization: organization, name: 'staging')
      end

      it 'does not create an environment and returns the error' do
        expect { result }.not_to change { ::Cd::Environment.count }
        expect(result).to be_error
        expect(result.message).to include('Name has already been taken')
      end
    end
  end
end
