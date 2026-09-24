# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ServicePing::SubmitService, feature_category: :service_ping do
  let!(:organization) { create(:organization) }
  let!(:usage_data) { { uuid: 'uuid', unique_instance_id: 'unique_instance_id', recorded_at: Time.current } }

  subject(:submit_service) { described_class.new(organization: organization, payload: usage_data) }

  it 'returns correct host in JH' do
    expect(submit_service.send(:base_url)).to eq ENV['VERSION_DOT_HOST'] || described_class::JH_BASE_URL
  end
end
