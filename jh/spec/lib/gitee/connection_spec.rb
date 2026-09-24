# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitee::Connection do
  describe '#get' do
    before do
      allow(Gitlab::HTTP).to receive(:get).and_return({})
    end

    it 'calls Gitlab::HTTP::get' do
      connection = described_class.new({})

      connection.get('/users')
    end
  end
end
