# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::YourWork::Menus::PerformanceMeasurementMenu, feature_category: :navigation do
  let(:user) { build_stubbed(:user) }
  let(:context) { Sidebars::Context.new(current_user: user, container: nil) }

  subject(:result) { described_class.new(context) }

  describe '#render?' do
    context 'when `jh_new_performance_measurement` feature flag is enabled' do
      context 'when `current_user` is available' do
        before do
          stub_feature_flags(jh_new_performance_measurement: [user])
        end

        it 'returns true' do
          expect(result.render?).to be true
        end
      end

      context 'when `current_user` is not available' do
        let(:user) { nil }

        it 'returns false' do
          expect(result.render?).to be false
        end
      end
    end

    context 'when `ui_for_organizations` feature flag is disabled' do
      before do
        stub_feature_flags(jh_new_performance_measurement: false)
      end

      it 'returns false' do
        expect(result.render?).to be false
      end
    end
  end
end
