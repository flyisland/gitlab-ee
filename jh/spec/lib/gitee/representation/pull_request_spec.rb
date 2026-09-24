# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitee::Representation::PullRequest do
  describe '#author' do
    it { expect(described_class.new({ 'user' => { 'name' => 'Tom' } }).author).to eq('Tom') }
    it { expect(described_class.new({}).author).to be_nil }
  end

  describe '#description' do
    it { expect(described_class.new({ 'body' => 'Text' }).description).to eq('Text') }
    it { expect(described_class.new({}).description).to be_nil }
  end

  describe '#iid' do
    it { expect(described_class.new({ 'number' => 1 }).iid).to eq(1) }
  end

  describe '#state' do
    it { expect(described_class.new({ 'state' => 'merged' }).state).to eq('merged') }
    it { expect(described_class.new({ 'state' => 'closed' }).state).to eq('closed') }
    it { expect(described_class.new({ 'state' => 'open' }).state).to eq('opened') }
  end

  describe '#created_at' do
    it { expect(described_class.new('created_at' => Time.zone.today).created_at).to eq(Time.zone.today) }
  end

  describe '#updated_at' do
    it { expect(described_class.new('updated_at' => Time.zone.today).updated_at).to eq(Time.zone.today) }
  end

  describe '#title' do
    it { expect(described_class.new('title' => 'Issue').title).to eq('Issue') }
  end

  describe '#draft?' do
    it { expect(described_class.new('draft' => true).draft?).to be(true) }
    it { expect(described_class.new('draft' => false).draft?).to be(false) }
  end

  describe '#milestone' do
    it { expect(described_class.new({ 'milestone' => { 'title' => '1.0' } }).milestone).to eq('1.0') }
    it { expect(described_class.new({}).milestone).to be_nil }
  end

  describe '#source_branch_name' do
    it { expect(described_class.new({ 'head' => { 'ref' => 'feature' } }).source_branch_name).to eq('feature') }
    it { expect(described_class.new({ 'head' => {} }).source_branch_name).to be_nil }
  end

  describe '#source_branch_sha' do
    it { expect(described_class.new({ 'head' => { 'sha' => 'abcd123' } }).source_branch_sha).to eq('abcd123') }
    it { expect(described_class.new({ 'head' => {} }).source_branch_sha).to be_nil }
  end

  describe '#target_branch_name' do
    it { expect(described_class.new({ 'base' => { 'ref' => 'master' } }).target_branch_name).to eq('master') }
    it { expect(described_class.new({ 'base' => {} }).target_branch_name).to be_nil }
  end

  describe '#target_branch_sha' do
    it { expect(described_class.new({ 'base' => { 'sha' => 'abcd123' } }).target_branch_sha).to eq('abcd123') }
    it { expect(described_class.new({ 'base' => {} }).target_branch_sha).to be_nil }
  end

  describe '#labels' do
    it do
      expect(
        described_class.new({ 'labels' => [{ 'name' => 'test' }, { 'name' => 'test1' }] }).labels
      ).to eq(%w[test test1])
    end

    it { expect(described_class.new({ 'labels' => {} }).labels).to eq([]) }
  end
end
