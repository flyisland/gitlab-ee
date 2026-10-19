# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::Group::Report::BaseEvent do
  let(:group) { create(:group) }
  let(:model) do
    Class.new(described_class).new(group)
  end

  describe '#event_target_action_scope' do
    it 'raises NotImplementedError' do
      expect { model.event_target_action_scope }.to raise_error(NotImplementedError)
    end
  end
end
