# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SQL::Pattern do
  describe '.select_fuzzy_terms' do
    subject(:select_fuzzy_terms) { Issue.select_fuzzy_terms(query) }

    context 'with Chinese word shorter than 3 chars' do
      let(:query) { '一' }

      it 'returns empty array' do
        expect(select_fuzzy_terms).to match_array('一')
      end
    end

    context 'with two Chinese words both less than 3 chars' do
      let(:query) { '一 二' }

      it 'returns array containing two words' do
        expect(select_fuzzy_terms).to match_array(%w[一 二])
      end
    end

    context 'with two Chinese words divided by two spaces both less than 3 chars' do
      let(:query) { '一  二' }

      it 'returns array containing two words' do
        expect(select_fuzzy_terms).to match_array(%w[一 二])
      end
    end

    context 'with two words one is Chinese and another is English' do
      let(:query) { '一a' }

      it 'returns array containing two words' do
        expect(select_fuzzy_terms).to match_array(%w[一a])
      end
    end

    context 'with two words one is Chinese and another is English, and English words more than 3 chars' do
      let(:query) { '一 abc' }

      it 'returns array containing two words' do
        expect(select_fuzzy_terms).to match_array(%w[一 abc])
      end
    end

    context 'with two words one is Chinese and another is English, and English words less than 3 chars' do
      let(:query) { '一 a' }

      it 'returns array containing two words' do
        expect(select_fuzzy_terms).to match_array(%w[一])
      end
    end

    context 'with a word equal to 3 chars' do
      let(:query) { 'foo' }

      it 'returns array containing a word' do
        expect(select_fuzzy_terms).to match_array(['foo'])
      end
    end

    context 'with a word shorter than 3 chars' do
      let(:query) { 'fo' }

      it 'returns empty array' do
        expect(select_fuzzy_terms).to be_empty
      end
    end

    context 'with two words both equal to 3 chars' do
      let(:query) { 'foo baz' }

      it 'returns array containing two words' do
        expect(select_fuzzy_terms).to match_array(%w[foo baz])
      end
    end

    context 'with two words divided by two spaces both equal to 3 chars' do
      let(:query) { 'foo  baz' }

      it 'returns array containing two words' do
        expect(select_fuzzy_terms).to match_array(%w[foo baz])
      end
    end

    context 'with two words equal to 3 chars and shorter than 3 chars' do
      let(:query) { 'foo ba' }

      it 'returns array containing a word' do
        expect(select_fuzzy_terms).to match_array(['foo'])
      end
    end
  end
end
