# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::DeploymentsMenu, feature_category: :navigation do
  let_it_be_with_reload(:project) { create(:project, :repository) }

  let(:user) { project.first_owner }
  let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project) }

  describe 'Pages' do
    subject { described_class.new(context).renderable_items.index { |e| e.item_id == item_id } }

    let(:item_id) { :pages }

    before do
      allow(project).to receive(:pages_available?).and_return(pages_enabled)
    end

    describe 'when pages are enabled' do
      let(:pages_enabled) { true }

      it { is_expected.not_to be_nil }

      describe 'when the user does not have access' do
        let(:user) { nil }

        it { is_expected.to be_nil }
      end
    end

    describe 'when pages are not enabled' do
      let(:pages_enabled) { false }

      it { is_expected.to be_nil }
    end
  end
end
