# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SeatAlert::Namespace::BaseComponent, feature_category: :seat_cost_management do
  let(:group) do
    build_stubbed(:group, namespace_settings: build_stubbed(:namespace_settings, seat_control: :off))
  end

  let(:user) { build_stubbed(:user) }

  subject(:component) do
    SeatAlert::Namespace::ThresholdComponent.new(
      root_namespace: group,
      current_user: user,
      remaining_seat_count: 5,
      total_seat_count: 100
    )
  end

  describe 'JH purchase link override' do
    it 'prepends the JH module' do
      expect(described_class).to be <= JH::SeatAlert::Namespace::BaseComponent
    end

    context 'on SaaS', :saas do
      it 'renders purchase more seats link to usage quotas page' do
        render_inline(component)

        expect(page).to have_link('Purchase more seats', href: group_usage_quotas_path(group))
      end
    end

    context 'on self-managed' do
      it 'renders purchase more seats link to help page' do
        render_inline(component)

        expect(page).to have_link(
          'Purchase more seats',
          href: help_page_path('subscriptions/manage_seats.md', anchor: 'buy-more-seats')
        )
      end
    end
  end
end
