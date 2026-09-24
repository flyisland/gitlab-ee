# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::DingtalkTrackerData do
  let(:integration) { create(:dingtalk_integration, :instance) }
  let(:dingtalk_tracker_data) { create(:dingtalk_tracker_data, integration: integration) }

  before do
    stub_licensed_features(dingtalk_integration: true)
  end

  describe 'factory available' do
    it { expect(dingtalk_tracker_data.valid?).to be true }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:integration) }
  end

  describe 'corpid' do
    subject { dingtalk_tracker_data.attributes.keys }

    it { is_expected.to include('corpid') }
  end
end
