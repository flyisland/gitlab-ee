# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Search::Elastic::SbomOccurrenceRefIndexHelper, feature_category: :dependency_management do
  describe '.indexing_allowed?' do
    before do
      allow(Gitlab::CurrentSettings).to receive(:elasticsearch_indexing?).and_return(indexing)
    end

    context 'when elasticsearch indexing is enabled' do
      let(:indexing) { true }

      it 'returns true' do
        expect(described_class.indexing_allowed?).to be(true)
      end
    end

    context 'when elasticsearch indexing is disabled' do
      let(:indexing) { false }

      it 'returns false' do
        expect(described_class.indexing_allowed?).to be(false)
      end
    end
  end
end
