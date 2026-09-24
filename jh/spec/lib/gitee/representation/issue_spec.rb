# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitee::Representation::Issue do
  describe '#number' do
    it { expect(described_class.new('number' => 1).number).to eq(1) }
  end

  describe '#author' do
    it { expect(described_class.new('user' => { 'name' => 'Tom' }).author).to eq('Tom') }
  end

  describe '#description' do
    it { expect(described_class.new({ 'body' => 'Text' }).description).to eq('Text') }
    it { expect(described_class.new({}).description).to be_nil }
  end

  describe '#state' do
    it { expect(described_class.new({ 'state' => 'closed' }).state).to eq('closed') }
    it { expect(described_class.new({ 'state' => 'open' }).state).to eq('opened') }
    it { expect(described_class.new({ 'state' => 'progressing' }).state).to eq('opened') }
    it { expect(described_class.new({ 'state' => 'rejected' }).state).to eq('closed') }
  end

  describe '#title' do
    it { expect(described_class.new('title' => 'Issue').title).to eq('Issue') }
  end

  describe '#labels' do
    it do
      expect(
        described_class.new({ 'labels' => [{ 'name' => 'test' }, { 'name' => 'test1' }] }).labels
      ).to eq(%w[test test1])
    end

    it { expect(described_class.new({ 'labels' => {} }).labels).to eq([]) }
  end

  describe '#milestone' do
    it { expect(described_class.new({ 'milestone' => { 'title' => '1.0' } }).milestone).to eq('1.0') }
    it { expect(described_class.new({}).milestone).to be_nil }
  end

  describe '#created_at' do
    it { expect(described_class.new('created_at' => Time.zone.today).created_at).to eq(Time.zone.today) }
  end

  describe '#updated_at' do
    it { expect(described_class.new('updated_at' => Time.zone.today).updated_at).to eq(Time.zone.today) }
  end

  describe '#due_date' do
    it { expect(described_class.new('deadline' => Time.zone.today).due_date).to eq(Time.zone.today) }
  end

  describe '#to_s' do
    it { expect(described_class.new('number' => 'aaa').to_s).to eq('aaa') }
  end
end
