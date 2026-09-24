# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::EffectiveLines::Counter do
  let(:content) do
    <<-CONTENT
 test class
+ test code
+#{'  '}
+   test code
-   test
-#{' '}
 test code
-#{' '}
- test code
    CONTENT
  end

  let(:counter) { described_class.new(content) }

  describe '#additions' do
    it 'returns the number of effective additions' do
      expect(counter.additions).to eq(2)
    end
  end

  describe '#deletions' do
    it 'returns the number of effective deletions' do
      expect(counter.deletions).to eq(2)
    end
  end
end
