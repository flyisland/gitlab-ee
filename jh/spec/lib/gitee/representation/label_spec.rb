# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitee::Representation::Label do
  describe '#color' do
    it { expect(described_class.new('color' => 'FFFFFF').color).to eq('#FFFFFF') }
  end

  describe '#title' do
    it { expect(described_class.new('name' => 'test').title).to eq('test') }
  end

  describe '#url' do
    it { expect(described_class.new('url' => 'http://test.com').url).to eq('http://test.com') }
    it { expect(described_class.new('url' => nil).url).to be_nil }
  end

  describe '#created_at' do
    it { expect(described_class.new('created_at' => Time.zone.today).created_at).to eq(Time.zone.today) }
  end

  describe '#updated_at' do
    it { expect(described_class.new('updated_at' => Time.zone.today).updated_at).to eq(Time.zone.today) }
    it { expect(described_class.new('updated_at' => nil).updated_at).to be_nil }
  end
end
