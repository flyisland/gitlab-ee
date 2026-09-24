# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Issue do
  describe 'validations' do
    it_behaves_like "content validation with project", :issue, :title
    it_behaves_like "content validation with project", :issue, :description
  end

  describe '#contains_chinese?' do
    it 'returns false if not contains Chinese' do
      expect(described_class.contains_chinese?("Test title name")).to be(false)
    end

    it 'returns true if contains Chinese' do
      expect(described_class.contains_chinese?("测试标题")).to be(true)
      expect(described_class.contains_chinese?("测试 title")).to be(true)
      expect(described_class.contains_chinese?("Test标题")).to be(true)
    end
  end

  describe '#to_branch_name' do
    where(:issue_id, :title, :expected_title) do
      [
        [123, 'Hello World!', "123-hello-world"],
        [123, 'Hello 你好:)', "123-hello-ni-hao"],
        [123, 'Hello 你好 Hermès ❤', "123-hello-ni-hao-hermes"]
      ]
    end

    with_them do
      it 'returns expected branch name' do
        expect(described_class.to_branch_name(issue_id, title)).to eq expected_title
      end
    end
  end
end
