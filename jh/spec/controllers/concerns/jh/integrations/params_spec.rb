# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::Params do
  subject do
    Class.new do
      include Integrations::Params
    end.new
  end

  describe '#allowed_integration_params' do
    it 'contains corpid' do
      expect(subject.allowed_integration_params).to include(:corpid)
    end
  end
end
