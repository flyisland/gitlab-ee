# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitee::Representation::PullRequestComment do
  describe '#iid' do
    it { expect(described_class.new('id' => 1).iid).to eq(1) }
  end

  describe '#file_path' do
    it { expect(described_class.new('path' => '/path').file_path).to eq('/path') }
  end

  describe '#author_name' do
    it { expect(described_class.new('user' => { 'name' => 'Tom' }).author_name).to eq('Tom') }
    it { expect(described_class.new({}).author_name).to be_nil }
  end

  describe '#inline?' do
    it { expect(described_class.new('comment_type' => 'diff_comment').inline?).to be(true) }
    it { expect(described_class.new('comment_type' => 'pr_comment').inline?).to be(false) }
  end

  describe '#has_parent?' do
    it { expect(described_class.new('in_reply_to_id' => 1).has_parent?).to be(true) }
    it { expect(described_class.new('in_reply_to_id' => nil).has_parent?).to be(false) }
  end

  describe '#parent_id' do
    it { expect(described_class.new('in_reply_to_id' => 1).parent_id).to eq(1) }
    it { expect(described_class.new('in_reply_to_id' => nil).parent_id).to be_nil }
  end

  describe '#new_pos' do
    it { expect(described_class.new('new_line' => 1).new_pos).to eq(1) }
    it { expect(described_class.new('new_line' => nil).new_pos).to be_nil }
  end

  describe '#old_pos' do
    it { expect(described_class.new('old_line' => 1).old_pos).to eq(1) }
    it { expect(described_class.new('old_line' => nil).old_pos).to be_nil }
  end
end
