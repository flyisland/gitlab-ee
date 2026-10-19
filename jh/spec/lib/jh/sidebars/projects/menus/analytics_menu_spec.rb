# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::AnalyticsMenu do
  let_it_be(:project) { create(:project, :repository) }
  let(:user) { project.first_owner }
  let(:context) do
    Sidebars::Projects::Context.new(
      current_user: user,
      container: project,
      current_ref: project.repository.root_ref
    )
  end

  before do
    stub_licensed_features(performance_analytics: true)
  end

  subject { described_class.new(context) }

  describe 'Project Menu items' do
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
