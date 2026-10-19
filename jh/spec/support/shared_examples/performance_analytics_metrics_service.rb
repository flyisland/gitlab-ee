# frozen_string_literal: true

RSpec.shared_examples 'performance analytics metrics service validate' do
  context 'when date range over limits' do
    let(:params) { { metric: "issues_closed", start_date: 1.year.ago, end_date: Time.current } }

    it 'return error' do
      expect(subject.execute).to eq(
        {
          message: "Date range must be shorter than 180 days.",
          status: :error, http_status: :bad_request
        }
      )
    end
  end

  context 'when start date is not early than end date' do
    let(:params) { { metric: "issues_closed", start_date: 1.month.ago, end_date: 2.months.ago } }

    it 'return error' do
      expect(subject.execute).to eq(
        {
          message: "The start date must be earlier than the end date.",
          status: :error, http_status: :bad_request
        }
      )
    end
  end

  context 'when interval is not available' do
    let(:params) { { metric: "issues_closed", interval: "xxx" } }

    it 'return error' do
      expect(subject.execute).to eq(
        {
          message: "The interval must be one of all,monthly,daily.",
          status: :error, http_status: :bad_request
        }
      )
    end
  end

  context 'when metric is not available' do
    let(:params) { { metric: "xxx" } }

    it 'return error' do
      expect(subject.execute).to eq(
        {
          message: "The metric must be one of #{described_class.available_metrics.join(',')}.",
          status: :error, http_status: :bad_request
        }
      )
    end
  end
end
