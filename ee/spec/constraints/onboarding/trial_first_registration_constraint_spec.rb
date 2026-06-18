# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Onboarding::TrialFirstRegistrationConstraint, feature_category: :onboarding do
  subject(:constraint) { described_class.new }

  let(:request) do
    env = Rack::MockRequest.env_for('/', method: 'GET')
    ActionDispatch::Request.new(env)
  end

  describe '#matches?' do
    context 'when onboarding feature is not available' do
      it 'returns false' do
        expect(constraint.matches?(request)).to be(false)
      end
    end

    context 'when onboarding feature is available', :saas_onboarding do
      context 'when from_sign_in param is not present' do
        let(:request) do
          env = Rack::MockRequest.env_for('/', method: 'GET', 'HTTP_REFERER' => 'https://example.com')
          ActionDispatch::Request.new(env)
        end

        it 'returns false' do
          expect(constraint.matches?(request)).to be(false)
        end
      end

      context 'when from_sign_in param is false' do
        let(:request) do
          env = Rack::MockRequest.env_for('/?from_sign_in=false', method: 'GET')
          ActionDispatch::Request.new(env)
        end

        it 'returns false' do
          expect(constraint.matches?(request)).to be(false)
        end
      end

      context 'when from_sign_in param is true' do
        let(:request) do
          env = Rack::MockRequest.env_for('/?from_sign_in=true', method: 'GET')
          ActionDispatch::Request.new(env)
        end

        context 'when referer is nil' do
          it 'returns false' do
            expect(constraint.matches?(request)).to be(false)
          end
        end

        context 'when referer is present' do
          let(:request) do
            env = Rack::MockRequest.env_for('/?from_sign_in=true', method: 'GET', 'HTTP_REFERER' => 'https://example.com')
            ActionDispatch::Request.new(env)
          end

          context 'when trial_first_registration is control' do
            before do
              experiment_double = instance_double(TrialFirstRegistrationExperiment, run: false)
              allow(constraint).to receive(:experiment).and_return(experiment_double)
            end

            it 'returns false' do
              expect(constraint.matches?(request)).to be(false)
            end
          end

          context 'when trial_first_registration is candidate' do
            before do
              experiment_double = instance_double(TrialFirstRegistrationExperiment, run: true)
              allow(constraint).to receive(:experiment).and_return(experiment_double)
            end

            it 'returns true' do
              expect(constraint.matches?(request)).to be(true)
            end
          end
        end
      end
    end
  end
end
