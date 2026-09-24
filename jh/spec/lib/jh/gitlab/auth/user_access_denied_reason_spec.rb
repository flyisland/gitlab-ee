# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Auth::UserAccessDeniedReason do
  let(:user) { build(:user) }

  let(:reason) { described_class.new(user) }

  describe '#rejection_message' do
    subject { reason.rejection_message }

    context 'when it is JH SaaS', :saas, :phone_verification_code_enabled do
      context 'when a user did not verify phone' do
        it { is_expected.to match(/must verify your phone in order to perform this/) }
      end
    end
  end
end
