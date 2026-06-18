# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::Applications::CreateService, feature_category: :continuous_delivery do
  let_it_be(:organization) { create(:organization) }
  let_it_be(:group) { create(:group, organization: organization) }
  let_it_be(:current_user) { create(:user) }

  let(:params) { { name: 'my-application', description: 'a description' } }

  subject(:result) do
    described_class.new(parent: parent, current_user: current_user, params: params).execute
  end

  describe '#execute' do
    shared_examples 'creates the application' do |parent_attribute|
      it 'returns a success response with the persisted application' do
        expect { result }.to change { ::Cd::Application.count }.by(1)

        application = result.payload[:application]
        expect(result).to be_success
        expect(application).to be_persisted
        expect(application).to have_attributes(
          parent_attribute => parent,
          name: 'my-application',
          description: 'a description'
        )
      end
    end

    shared_examples 'returns an error' do |message, parent_attribute|
      it 'does not create an application and returns the error with the unsaved application' do
        expect { result }.not_to change { ::Cd::Application.count }
        expect(result).to be_error
        expect(result.message).to include(message)

        application = result.payload[:application]
        expect(application).not_to be_persisted
        expect(application).to have_attributes(parent_attribute => parent)
      end
    end

    context 'when parent is a group' do
      let(:parent) { group }

      it_behaves_like 'creates the application', :group

      context 'when name is blank' do
        let(:params) { super().merge(name: '') }

        it_behaves_like 'returns an error', "Name can't be blank", :group
      end

      context 'when name is already taken in the group' do
        before do
          create(:cd_application, group: group, name: 'my-application')
        end

        it_behaves_like 'returns an error', 'Name has already been taken', :group
      end
    end

    context 'when parent is an organization' do
      let(:parent) { organization }

      it_behaves_like 'creates the application', :organization

      context 'when name is already taken in the organization' do
        before do
          create(:cd_application, :for_organization, organization: organization, name: 'my-application')
        end

        it_behaves_like 'returns an error', 'Name has already been taken', :organization
      end
    end
  end
end
