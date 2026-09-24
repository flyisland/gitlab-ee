# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitee::Representation::Repo do
  describe '#owner_and_slug' do
    it { expect(described_class.new({ 'full_name' => 'ben/test' }).owner_and_slug).to eq(%w[ben test]) }
  end

  describe '#owner' do
    it { expect(described_class.new({ 'full_name' => 'ben/test' }).owner).to eq('ben') }
  end

  describe '#slug' do
    it { expect(described_class.new({ 'full_name' => 'ben/test' }).slug).to eq('test') }
  end

  describe '#clone_url' do
    context 'when token is present' do
      it 'builds url' do
        data = { 'html_url' => 'https://gitee.com/test/test.git' }
        expect(described_class.new(data).clone_url('abc')).to eq('https://oauth2:abc@gitee.com/test/test.git')
      end
    end

    context 'when token is not present' do
      it 'builds url' do
        data = { 'html_url' => 'https://gitee.com/test/test.git' }
        expect(described_class.new(data).clone_url).to eq('https://gitee.com/test/test.git')
      end
    end
  end

  describe '#description' do
    it { expect(described_class.new({ 'description' => 'desc' }).description).to eq('desc') }
  end

  describe '#full_name' do
    it { expect(described_class.new({ 'full_name' => 'test_full' }).full_name).to eq('test_full') }
  end

  describe '#issues_enabled?' do
    it { expect(described_class.new({ 'has_issues' => false }).issues_enabled?).to be(false) }
    it { expect(described_class.new({ 'has_issues' => true }).issues_enabled?).to be(true) }
  end

  describe '#name' do
    it { expect(described_class.new({ 'name' => 'test' }).name).to eq('test') }
  end

  describe '#has_wiki?' do
    it { expect(described_class.new({ 'has_wiki' => false }).has_wiki?).to be(false) }
    it { expect(described_class.new({ 'has_wiki' => true }).has_wiki?).to be(true) }
  end

  describe '#visibility_level' do
    it { expect(described_class.new({ 'private' => true }).visibility_level).to eq(0) }
    it { expect(described_class.new({ 'private' => false }).visibility_level).to eq(20) }
  end

  describe '#to_s' do
    it { expect(described_class.new({ 'full_name' => 'test' }).to_s).to eq('test') }
    it { expect(described_class.new({ 'full_name' => nil }).to_s).to be_nil }
  end
end
