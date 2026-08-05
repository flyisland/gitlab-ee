# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Experiments::AssignmentService, feature_category: :acquisition do
  describe '#read', :aggregate_failures do
    let_it_be(:user) { create(:user) }

    let(:experiment_name) { 'null_hypothesis' }
    let(:context_params) { { user: user.username } }

    before do
      allow(Gitlab::Experiment::Configuration).to receive(:cache).and_call_original
    end

    after do
      Gitlab::Experiment::Configuration.cache&.clear(key: experiment_name)
    end

    subject(:read) do
      described_class.new(experiment_name: experiment_name, context_params: context_params, current_user: user).read
    end

    context 'when no cached variant exists' do
      it 'returns success with nil variant' do
        expect(read).to be_success
        expect(read.payload[:experiment]).to eq(experiment_name)
        expect(read.payload[:variant]).to be_nil
        expect(read.payload[:cached]).to be false
        expect(read.payload[:context_key]).to be_present
      end
    end

    context 'when context is empty' do
      let(:context_params) { {} }

      it 'reads using the current user as the default context' do
        expect(read).to be_success
        expect(read.payload[:experiment]).to eq(experiment_name)
        expect(read.payload[:context_key]).to be_present
      end
    end

    context 'when context resolution fails' do
      let(:context_params) { { user: 'nonexistent_user' } }

      it 'returns the resolver error without reading' do
        expect(read).to be_error
        expect(read.message).to eq('User not found: nonexistent_user')
      end
    end
  end
end
