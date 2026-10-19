# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Groups::Menus::WorkItemsMenu, feature_category: :navigation do
  let_it_be(:owner) { create(:user) }
  let_it_be(:group) { create(:group, :private, owners: owner) }

  let(:context) { Sidebars::Groups::Context.new(current_user: owner, container: group) }

  it 'tags iterations as a Team feature with Feature Library metadata', :aggregate_failures do
    stub_licensed_features(iterations: true)
    item = described_class.new(context).renderable_items.find { |entry| entry.item_id == :iterations }
    serialized = item.serialize_for_super_sidebar

    expect(serialized[:tier]).to eq(:team)
    expect(serialized).to include(:description, :library_icon)
  end
end
