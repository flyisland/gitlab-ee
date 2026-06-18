# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VirtualRegistries, feature_category: :virtual_registry do
  let_it_be(:group) { create(:group) }
  let_it_be(:user) { create(:user) }
  let(:permission) { :read_virtual_registry }

  describe '.registries_count_for' do
    context 'when registry_type is valid' do
      let(:registry_type) { :maven }
      let(:registry_class) { ::VirtualRegistries::Packages::Maven::Registry }
      let(:registries) { instance_double(Array, size: 5) }

      before do
        allow(registry_class).to receive(:for_group).with(group).and_return(registries)
      end

      it 'returns the count of registries for the given group and registry type' do
        expect(described_class.registries_count_for(group, registry_type: registry_type)).to eq(5)
      end

      it 'calls for_group on the registry class with the group' do
        expect(registry_class).to receive(:for_group).with(group)

        described_class.registries_count_for(group, registry_type: registry_type)
      end
    end

    context 'when registry_type is invalid' do
      let(:registry_type) { :invalid_type }

      it 'returns 0' do
        expect(described_class.registries_count_for(group, registry_type: registry_type)).to eq(0)
      end
    end
  end

  describe '.user_has_access?' do
    subject { described_class.user_has_access?(group, user, permission) }

    context 'when user does not have permission' do
      it { is_expected.to be(false) }
    end

    context 'when user has read_virtual_registry permission' do
      before_all do
        group.add_guest(user)
      end
      it { is_expected.to be(true) }
    end

    context 'with admin_virtual_registry permission' do
      let(:permission) { :admin_virtual_registry }

      it { is_expected.to be(false) }

      context 'when user is group owner' do
        before_all do
          group.add_owner(user)
        end

        it { is_expected.to be(true) }
      end
    end
  end

  describe '.any_registry_available?' do
    subject(:any_registry_available) { described_class.any_registry_available?(group, user, permission) }

    context 'when maven virtual registry is available' do
      before do
        allow(::VirtualRegistries::Packages::Maven).to receive(:virtual_registry_available?)
          .with(group, user, permission).and_return(true)
        allow(::VirtualRegistries::Container).to receive(:virtual_registry_available?)
          .with(group, user, permission).and_return(false)
      end

      it { is_expected.to be true }
    end

    context 'when container virtual registry is available' do
      before do
        allow(::VirtualRegistries::Packages::Maven).to receive(:virtual_registry_available?)
          .with(group, user, permission).and_return(false)
        allow(::VirtualRegistries::Container).to receive(:virtual_registry_available?)
          .with(group, user, permission).and_return(true)
      end

      it { is_expected.to be true }
    end

    context 'when both virtual registries are available' do
      before do
        allow(::VirtualRegistries::Container).to receive(:virtual_registry_available?)
          .with(group, user, permission).and_return(true)
        allow(::VirtualRegistries::Packages::Maven).to receive(:virtual_registry_available?)
          .with(group, user, permission).and_return(true)
      end

      it { is_expected.to be true }
    end

    context 'when no virtual registry is available' do
      before do
        allow(::VirtualRegistries::Packages::Maven).to receive(:virtual_registry_available?)
          .with(group, user, permission).and_return(false)
        allow(::VirtualRegistries::Container).to receive(:virtual_registry_available?)
          .with(group, user, permission).and_return(false)
      end

      it { is_expected.to be false }
    end

    context 'with admin_virtual_registry permission' do
      let(:permission) { :admin_virtual_registry }

      before do
        allow(::VirtualRegistries::Packages::Maven).to receive(:virtual_registry_available?)
          .with(group, user, permission).and_return(true)
      end

      it { is_expected.to be true }
    end
  end
end
