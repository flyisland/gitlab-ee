# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Groups::Menus::AnalyticsMenu do
  let_it_be(:owner) { create(:user) }
  let(:user) { owner }
  let(:context) { Sidebars::Groups::Context.new(current_user: user, container: group) }
  let(:menu) { described_class.new(context) }
  let_it_be_with_refind(:group) do
    create(:group, :private).tap do |g|
      g.add_owner(owner)
    end
  end

  before do
    stub_licensed_features(performance_analytics: true)
  end

  describe 'Group Menu items' do
    subject { described_class.new(context).renderable_items.index { |e| e.item_id == item_id } }

    describe 'Performance Analytics' do
      let(:item_id) { :performance_analytics }

      it { is_expected.not_to be_nil }

      describe 'without a valid license' do
        before do
          stub_licensed_features(performance_analytics: false)
        end

        it { is_expected.to be_nil }
      end

      describe 'when the performance_analytics feature flag is disabled' do
        before do
          stub_feature_flags(performance_analytics: false)
        end

        it { is_expected.to be_nil }
      end
    end
  end
end
