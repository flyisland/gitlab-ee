# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitee::Representation::Release do
  describe '#tag_name' do
    it { expect(described_class.new('tag_name' => 'v1').tag_name).to eq('v1') }
  end

  describe '#name' do
    it { expect(described_class.new('name' => 'release1').name).to eq('release1') }
  end

  describe '#body' do
    it { expect(described_class.new('body' => 'test').body).to eq('test') }
  end

  describe '#author_name' do
    it { expect(described_class.new('author' => { 'name' => 'Tom' }).author_name).to eq('Tom') }
  end

  describe '#created_at' do
    it { expect(described_class.new('created_at' => Time.zone.today).created_at).to eq(Time.zone.today) }
  end
end
