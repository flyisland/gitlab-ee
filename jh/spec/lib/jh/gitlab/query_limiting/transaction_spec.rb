# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::QueryLimiting::Transaction, feature_category: :database do
  after do
    Thread.current[described_class::THREAD_KEY] = nil
  end

  let(:jh_plus_count) { JH::Gitlab::QueryLimiting::Transaction::JH_QUERY_LIMITING_PLUS.to_i }

  describe '#act_upon_results' do
    context 'when the query threshold is exceeded' do
      let(:transaction) do
        trans = described_class.new
        trans.count = described_class.default_threshold + 8

        trans
      end

      it 'raises an error when this is enabled' do
        expect { transaction.act_upon_results }
          .to raise_error(described_class::ThresholdExceededError)
      end
    end

    context 'when there is a different threshold', :request_store do
      before do
        Gitlab::SafeRequestStore[:query_limiting_override_threshold] = 200
      end

      context 'when the query threshold is not exceeded' do
        it 'does nothing' do
          trans = described_class.new

          expect(trans).not_to receive(:raise)

          trans.act_upon_results
        end
      end

      context 'when the query threshold is exceeded' do
        let(:transaction) do
          trans = described_class.new
          trans.count = 208

          trans
        end

        it 'raises an error when this is enabled' do
          expect { transaction.act_upon_results }
            .to raise_error(described_class::ThresholdExceededError)
        end
      end
    end
  end

  describe '#raise_error?' do
    it 'returns true in a test environment' do
      transaction = described_class.new

      expect(transaction.raise_error?).to be(true)
    end

    it 'returns false in a production environment' do
      transaction = described_class.new

      stub_rails_env('production')

      expect(transaction.raise_error?).to be(false)
    end
  end

  describe '#error_message' do
    it 'returns the error message to display when the threshold is exceeded' do
      transaction = described_class.new
      transaction.count = max = described_class.default_threshold
      real_max = max + jh_plus_count

      expect(transaction.error_message).to eq(
        "Too many SQL queries were executed: a maximum of #{real_max} " \
          "is allowed but #{max} SQL queries were executed"
      )
    end

    it 'includes a list of executed queries' do
      transaction = described_class.new
      transaction.count = max = described_class.default_threshold
      %w[foo bar baz].each { |sql| transaction.executed_sql(sql) }

      message = transaction.error_message
      real_max = max + jh_plus_count

      expect(message).to start_with(
        "Too many SQL queries were executed: a maximum of #{real_max} " \
          "is allowed but #{max} SQL queries were executed"
      )

      expect(message).to include("0: foo", "1: bar", "2: baz")
    end

    it 'includes the action name in the error message when present' do
      transaction = described_class.new
      transaction.count = described_class.default_threshold
      max = described_class.threshold
      real_max = max + jh_plus_count
      transaction.action = 'UsersController#show'

      expect(transaction.error_message).to eq(
        "Too many SQL queries were executed in UsersController#show: " \
          "a maximum of #{real_max} is allowed but #{max} SQL queries were executed"
      )
    end
  end
end
