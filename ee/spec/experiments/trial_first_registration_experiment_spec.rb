# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TrialFirstRegistrationExperiment, :experiment, feature_category: :acquisition do
  let(:exp) { experiment(:trial_first_registration) }

  it_behaves_like 'defines control and candidate variants'

  describe 'CachedControlRollout' do
    let(:rollout) { TrialFirstRegistrationExperiment::CachedControlRollout.new(exp) }

    describe '#resolve' do
      context 'for control assignment' do
        before do
          allow(Feature).to receive(:enabled?).and_call_original
          allow(Feature)
            .to receive(:enabled?).with('trial_first_registration', anything, type: :experiment).and_return(false)
        end

        it 'validates the rollout before assignment' do
          expect(rollout).to receive(:validate!)

          rollout.resolve
        end

        it 'converts nil to :control for caching' do
          expect(rollout.resolve).to eq(:control)
        end
      end

      context 'for candidate assignment' do
        it 'resolves to :candidate' do
          expect(rollout.resolve).to eq(:candidate)
        end
      end
    end
  end
end
