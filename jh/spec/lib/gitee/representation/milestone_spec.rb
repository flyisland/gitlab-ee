# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitee::Representation::Milestone do
  describe '#title' do
    it { expect(described_class.new('title' => 'test').title).to eq('test') }
  end

  describe '#description' do
    it { expect(described_class.new('description' => 'test').description).to eq('test') }
    it { expect(described_class.new('description' => nil).description).to be_nil }
  end

  describe '#due_date' do
    it { expect(described_class.new('due_on' => Time.zone.today.to_s).due_date).to eq(Time.zone.today) }
    it { expect(described_class.new('due_on' => nil).due_date).to be_nil }
  end

  describe '#state' do
    it { expect(described_class.new('state' => 'open').state).to eq('active') }
    it { expect(described_class.new('state' => 'closed').state).to eq('closed') }
  end

  describe '#created_at' do
    it { expect(described_class.new('created_at' => Time.zone.today).created_at).to eq(Time.zone.today) }
  end

  describe '#updated_at' do
    it { expect(described_class.new('updated_at' => Time.zone.today).updated_at).to eq(Time.zone.today) }
    it { expect(described_class.new('updated_at' => nil).updated_at).to be_nil }
  end
end
