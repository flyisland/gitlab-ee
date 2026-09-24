# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupsHelper, feature_category: :source_code_management do
  let(:owner) { create(:user, group_view: :security_dashboard) }
  let(:current_user) { owner }
  let(:group) { create(:group, :private) }

  before do
    allow(helper).to receive(:current_user) { current_user }
    helper.instance_variable_set(:@group, group)

    group.add_owner(owner)
  end

  describe '#subgroup_creation_data' do
    subject { helper.subgroup_creation_data(group) }

    it 'returns expected hash' do
      expect(subject).to include({
        identity_verification_required: 'false',
        identity_verification_path: '#'
      })
    end

    context 'when the group creation limit is not exceeded' do
      it { is_expected.to include(identity_verification_required: 'false') }
    end

    context 'when the group creation limit is exceeded' do
      before do
        allow(current_user).to receive(:requires_identity_verification_to_create_group?).and_return(true)
      end

      it { is_expected.to include(identity_verification_required: 'false') }
    end
  end
end
