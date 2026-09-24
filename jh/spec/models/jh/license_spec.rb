# frozen_string_literal: true

require "spec_helper"

RSpec.describe License, feature_category: :sm_provisioning do
  describe '#paid?', :with_license do
    let(:license) { build(:license, plan: License::TEAM_PLAN) }

    it 'returns true for team license' do
      expect(license.paid?).to be_truthy
    end
  end

  describe '.all_plans', :with_license do
    it 'returns values includes team' do
      expect(License::EE_ALL_PLANS).to include(License::TEAM_PLAN)
    end
  end

  describe 'validations' do
    let(:gl_license) { build(:gitlab_license) }

    subject(:license) { build(:license, data: gl_license.export) }

    describe '#check_restricted_user_count' do
      context 'when reconciliation_completed is false', :with_license do
        context 'when the restricted_user_count with threshold is less than active_user_count' do
          before do
            create(:license, plan: ::License::PREMIUM_PLAN)
            set_restrictions(restricted_user_count: 10, reconciliation_completed: false)
            create_list(:user, 10)
            create(:historical_data, recorded_at: described_class.current.starts_at, active_user_count: 100)
          end

          it 'add limit error' do
            expect(license.valid?).to be_falsey

            expect(license.errors.full_messages.to_sentence).to include(
              'gitlab.cn/sales/'
            )
          end
        end
      end
    end
  end

  def set_restrictions(opts)
    date = described_class.current.starts_at

    gl_license.restrictions = {
      active_user_count: opts[:restricted_user_count],
      previous_user_count: opts[:previous_user_count],
      trueup_period_seat_count: opts[:trueup_period_seat_count],
      trueup_quantity: opts[:trueup_quantity],
      trueup_from: (date - 1.year).to_s,
      trueup_to: date.to_s,
      reconciliation_completed: opts[:reconciliation_completed]
    }.compact
  end
end
