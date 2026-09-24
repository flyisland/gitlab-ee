# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::SystemDefined::Plan, feature_category: :plan_provisioning do
  describe '.all' do
    it 'includes the JH team plan' do
      expect(described_class.all).to include(have_attributes(id: 10_000, name: 'team', title: 'Team'))
    end
  end
end
