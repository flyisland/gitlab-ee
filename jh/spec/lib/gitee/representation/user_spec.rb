# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitee::Representation::User do
  describe '#username' do
    it 'returns correct value' do
      user = described_class.new('login' => 'Tom')

      expect(user.username).to eq('Tom')
    end
  end
end
