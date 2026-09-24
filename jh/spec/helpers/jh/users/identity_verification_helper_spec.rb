# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::IdentityVerificationHelper, feature_category: :instance_resiliency do
  let_it_be_with_reload(:user) { create(:user) }

  describe '#pipl_restricted_country?' do
    before do
      allow_any_instance_of(JH::Users::IdentityVerificationHelper).to receive(
        :pipl_restricted_country?).and_return(false)
    end

    context 'when on JH instance' do
      it 'returns false', :aggregate_failures do
        expect(pipl_restricted_country?('CN')).to be(false)
        expect(pipl_restricted_country?('HK')).to be(false)
        expect(pipl_restricted_country?('MO')).to be(false)
        expect(pipl_restricted_country?('US')).to be(false)
      end
    end
  end
end
