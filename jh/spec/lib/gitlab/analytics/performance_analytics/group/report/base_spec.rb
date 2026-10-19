# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::Group::Report::Base do
  let(:group) { create(:group) }
  let(:model) do
    Class.new(described_class).new(group)
  end

  describe '#query_count' do
    it 'raises NotImplementedError' do
      expect { model.query_count }.to raise_error(NotImplementedError)
    end
  end

  describe '#query_summary' do
    it 'raises NotImplementedError' do
      expect { model.query_summary }.to raise_error(NotImplementedError)
    end
  end
end
