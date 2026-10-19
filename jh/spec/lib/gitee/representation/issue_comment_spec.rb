# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitee::Representation::IssueComment do
  describe '#iid' do
    it { expect(described_class.new('id' => 11).iid).to eq(11) }
    it { expect(described_class.new({}).iid).to be_nil }
  end

  describe '#author' do
    it { expect(described_class.new('user' => { 'name' => 'Tom' }).author).to eq('Tom') }
    it { expect(described_class.new({}).author).to be_nil }
  end

  describe '#note' do
    it { expect(described_class.new('body' => 'Text').note).to eq('Text') }
    it { expect(described_class.new({}).note).to be_nil }
  end

  describe '#created_at' do
    it { expect(described_class.new('created_at' => Time.zone.today).created_at).to eq(Time.zone.today) }
  end

  describe '#updated_at' do
    it { expect(described_class.new('updated_at' => Time.zone.today).updated_at).to eq(Time.zone.today) }
  end

  describe '#has_parent?' do
    it { expect(described_class.new('in_reply_to_id' => 1).has_parent?).to be(true) }
    it { expect(described_class.new('in_reply_to_id' => nil).has_parent?).to be(false) }
  end

  describe '#parent_id' do
    it { expect(described_class.new('in_reply_to_id' => 1).parent_id).to eq(1) }
    it { expect(described_class.new('in_reply_to_id' => nil).parent_id).to be_nil }
  end
end
