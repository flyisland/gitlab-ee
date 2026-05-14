# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::YourWork::Menus::OrbitMenu, feature_category: :knowledge_graph do
  let_it_be(:user) { build_stubbed(:user) }

  let(:context) { Sidebars::Context.new(current_user: user, container: nil) }
  let(:menu) { described_class.new(context) }

  describe '#title' do
    it 'returns Orbit' do
      expect(menu.title).to eq('Orbit')
    end
  end

  describe '#sprite_icon' do
    it 'returns rocket' do
      expect(menu.sprite_icon).to eq('rocket')
    end
  end

  describe '#render?' do
    before do
      stub_feature_flags(knowledge_graph: true)
    end

    it 'returns true when feature flag is enabled' do
      expect(menu.render?).to be(true)
    end

    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(knowledge_graph: false)
      end

      it 'returns false' do
        expect(menu.render?).to be(false)
      end
    end

    context 'when user is nil' do
      let(:context) { Sidebars::Context.new(current_user: nil, container: nil) }

      it 'returns falsey' do
        expect(menu.render?).to be_falsey
      end
    end
  end

  describe '#active_routes' do
    it 'returns the orbit controller' do
      expect(menu.active_routes).to eq({ controller: 'dashboard/orbit' })
    end
  end

  describe '#configure_menu_items' do
    before do
      stub_feature_flags(knowledge_graph: true)
    end

    it 'includes Data Explorer, Schema, and Configuration items' do
      items = menu.renderable_items.map(&:item_id)

      expect(items).to contain_exactly(:orbit_data_explorer, :orbit_schema, :orbit_configuration)
    end
  end
end
