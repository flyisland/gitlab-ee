# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::IssueTrackerLimitation do
  context 'when issue_tracker_path is not implemented' do
    subject(:integration_object) do
      described_module = described_class
      Class.new(Integration) { include described_module }.new
    end

    it 'raise NotImplementedError' do
      expect { integration_object.issue_tracker_path }.to raise_error(NotImplementedError)
    end
  end
end
