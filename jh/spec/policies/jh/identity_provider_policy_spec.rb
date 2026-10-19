# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IdentityProviderPolicy do
  subject(:policy) { described_class.new(user, provider) }

  let(:user) { User.new }
  let(:provider) { :a_provider }

  describe '#rules' do
    context "when provider is cas3" do
      let(:provider) { 'cas3' }

      it { is_expected.to be_allowed(:link) }
      it { is_expected.not_to be_allowed(:unlink) }
    end
  end
end
