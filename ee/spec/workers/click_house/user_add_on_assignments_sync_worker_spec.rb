# frozen_string_literal: true

require 'spec_helper'

# Remove after next required stop %19.2
RSpec.describe ClickHouse::UserAddOnAssignmentsSyncWorker, feature_category: :seat_cost_management do
  it_behaves_like 'an idempotent worker'

  it 'does nothing' do
    expect(described_class.new.perform).to be_nil
  end
end
