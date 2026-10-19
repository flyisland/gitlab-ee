# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProfilesHelper do
  describe '#email_provider_label' do
    it "returns omniauth provider label for users with external attributes" do
      stub_omniauth_setting(sync_profile_from_provider: ['cas3'])
      stub_omniauth_setting(sync_profile_attributes: true)
      stub_cas_omniauth_provider
      cas_user = create(:omniauth_user, provider: 'cas3')
      cas_user.create_user_synced_attributes_metadata(provider: 'cas3', name_synced: true, email_synced: true,
        location_synced: true)
      allow(helper).to receive(:current_user).and_return(cas_user)

      expect(helper.attribute_provider_label(:email)).to eq('CAS')
      expect(helper.attribute_provider_label(:name)).to eq('CAS')
      expect(helper.attribute_provider_label(:location)).to eq('CAS')
    end

    it "returns the correct omniauth provider label for users with some external attributes" do
      stub_omniauth_setting(sync_profile_from_provider: ['cas3'])
      stub_omniauth_setting(sync_profile_attributes: true)
      stub_cas_omniauth_provider
      cas_user = create(:omniauth_user, provider: 'cas3')
      cas_user.create_user_synced_attributes_metadata(provider: 'cas3', name_synced: false, email_synced: true,
        location_synced: false)
      allow(helper).to receive(:current_user).and_return(cas_user)

      expect(helper.attribute_provider_label(:name)).to be_nil
      expect(helper.attribute_provider_label(:email)).to eq('CAS')
      expect(helper.attribute_provider_label(:location)).to be_nil
    end
  end

  def stub_cas_omniauth_provider
    # rubocop:disable Style/OpenStructUse
    provider = OpenStruct.new(
      'name' => 'cas3',
      'label' => 'CAS'
    )
    # rubocop:enable Style/OpenStructUse

    stub_omniauth_setting(providers: [provider])
  end
end
