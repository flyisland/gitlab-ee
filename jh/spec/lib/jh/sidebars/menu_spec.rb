# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Menu, feature_category: :navigation do
  using RSpec::Parameterized::TableSyntax

  let(:context) { Sidebars::Context.new(current_user: nil, container: nil) }
  let(:menu) { described_class.new(context) }

  describe '#tier_for' do
    subject(:tier) { menu.send(:tier_for, :iterations) }

    where(:plan, :expected_tier) do
      License::TEAM_PLAN     | :team
      License::STARTER_PLAN  | :premium
      License::PREMIUM_PLAN  | :premium
      License::ULTIMATE_PLAN | :ultimate
      nil | nil
    end

    with_them do
      before do
        allow(GitlabSubscriptions::Features).to receive(:minimum_plan_for).with(:iterations).and_return(plan)
      end

      it 'maps the plan to a supported Feature Library tier' do
        expect(tier).to eq(expected_tier)
      end
    end
  end
end
