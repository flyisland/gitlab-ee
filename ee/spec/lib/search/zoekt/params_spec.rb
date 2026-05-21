# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Search::Zoekt::Params, feature_category: :global_search do
  let(:multi_match_double) { instance_double(Search::Zoekt::MultiMatch, max_chunks_size: 42) }
  let(:per_page) { Search::Zoekt::SearchResults::DEFAULT_PER_PAGE }

  describe '#max_file_match_window' do
    it 'returns UNLIMITED' do
      params = described_class.new(limit: 10)
      expect(params.max_file_match_window).to eq(Search::Zoekt::Params::UNLIMITED)
    end
  end

  describe '#max_file_match_results' do
    it 'returns search_limit when multi_match is present' do
      params = described_class.new(limit: 10, multi_match: multi_match_double)
      expect(params.max_file_match_results).to eq(10)
    end

    context 'when FF zoekt_cap_file_match_results is enabled' do
      context 'when offset pagination is disabled' do
        before do
          allow(Search::Zoekt::OffsetPagination).to receive(:active?).and_return(false)
        end

        it 'returns Search::Zoekt::Cache::MAX_PAGES times per_page' do
          params = described_class.new(limit: 10)
          expect(params.max_file_match_results).to eq(Search::Zoekt::Cache::MAX_PAGES * per_page)
        end
      end

      context 'when offset pagination is enabled' do
        before do
          allow(Search::Zoekt::OffsetPagination).to receive(:active?).and_return(true)
        end

        context 'when current_page is more than Search::Zoekt::Cache::MAX_PAGES' do
          let(:page) { Search::Zoekt::Cache::MAX_PAGES.next }

          it 'returns current_page times per_page' do
            params = described_class.new(page: page, per_page: per_page)
            expect(params.max_file_match_results).to eq(per_page)
          end
        end

        context 'when current_page is less than Search::Zoekt::Cache::MAX_PAGES' do
          let(:page) { Search::Zoekt::Cache::MAX_PAGES.pred }

          it 'returns Search::Zoekt::Cache::MAX_PAGES times per_page' do
            params = described_class.new(page: page, per_page: per_page)
            expect(params.max_file_match_results).to eq(Search::Zoekt::Cache::MAX_PAGES * per_page)
          end
        end
      end
    end

    context 'when FF zoekt_cap_file_match_results is disabled' do
      before do
        stub_feature_flags(zoekt_cap_file_match_results: false)
      end

      context 'when offset pagination is disabled' do
        before do
          stub_feature_flags(zoekt_offset_pagination: false)
        end

        it 'returns UNLIMITED' do
          params = described_class.new(limit: 10)
          expect(params.max_file_match_results).to eq(Search::Zoekt::Params::UNLIMITED)
        end
      end

      context 'when offset pagination is enabled' do
        before do
          allow(Search::Zoekt::OffsetPagination).to receive(:active?).and_return(true)
        end

        context 'when on page 1 (within batch window)' do
          it 'returns MAX_PAGES * per_page' do
            params = described_class.new(limit: per_page, page: 1, per_page: per_page)
            expect(params.max_file_match_results).to eq(Search::Zoekt::Cache::MAX_PAGES * per_page)
          end
        end

        context 'when on page 10 (last page of batch window)' do
          it 'returns MAX_PAGES * per_page' do
            params = described_class.new(limit: per_page, page: 10, per_page: per_page)
            expect(params.max_file_match_results).to eq(Search::Zoekt::Cache::MAX_PAGES * per_page)
          end
        end

        context 'when on page 11 (beyond batch window)' do
          it 'returns per_page' do
            params = described_class.new(limit: per_page, page: 11, per_page: per_page)
            expect(params.max_file_match_results).to eq(per_page)
          end
        end

        context 'when on page 50 (deep page)' do
          it 'returns per_page' do
            params = described_class.new(limit: per_page, page: 50, per_page: per_page)
            expect(params.max_file_match_results).to eq(per_page)
          end
        end

        context 'when nodes do not meet the minimum version' do
          before do
            allow(Search::Zoekt::OffsetPagination).to receive(:active?).and_return(false)
          end

          it 'returns UNLIMITED' do
            params = described_class.new(limit: per_page, page: 50, per_page: per_page)
            expect(params.max_file_match_results).to eq(Search::Zoekt::Params::UNLIMITED)
          end
        end
      end
    end
  end

  describe '#file_match_offset' do
    context 'when offset pagination is disabled' do
      before do
        stub_feature_flags(zoekt_offset_pagination: false)
      end

      it 'returns 0' do
        params = described_class.new(limit: per_page, page: 50, per_page: per_page)
        expect(params.file_match_offset).to eq(0)
      end
    end

    context 'when multi_match is present' do
      it 'returns 0' do
        params = described_class.new(limit: per_page, page: 50, per_page: per_page, multi_match: multi_match_double)
        expect(params.file_match_offset).to eq(0)
      end
    end

    context 'when offset pagination is enabled' do
      before do
        allow(Search::Zoekt::OffsetPagination).to receive(:active?).and_return(true)
      end

      context 'when on page 1 (within batch window)' do
        it 'returns 0' do
          params = described_class.new(limit: per_page, page: 1, per_page: per_page)
          expect(params.file_match_offset).to eq(0)
        end
      end

      context 'when on page 10 (last page of batch window)' do
        it 'returns 0' do
          params = described_class.new(limit: per_page, page: 10, per_page: per_page)
          expect(params.file_match_offset).to eq(0)
        end
      end

      context 'when on page 11 (first page beyond batch window)' do
        it 'returns (page - 1) * per_page' do
          params = described_class.new(limit: per_page, page: 11, per_page: per_page)
          expect(params.file_match_offset).to eq(10 * per_page)
        end
      end

      context 'when on page 50' do
        it 'returns (page - 1) * per_page' do
          params = described_class.new(limit: per_page, page: 50, per_page: per_page)
          expect(params.file_match_offset).to eq(49 * per_page)
        end
      end

      context 'when nodes do not meet the minimum version' do
        before do
          allow(Search::Zoekt::OffsetPagination).to receive(:active?).and_return(false)
        end

        it 'returns 0' do
          params = described_class.new(limit: per_page, page: 50, per_page: per_page)
          expect(params.file_match_offset).to eq(0)
        end
      end
    end
  end

  describe '#max_line_match_window' do
    it 'returns ZOEKT_COUNT_LIMIT' do
      stub_const('Search::Zoekt::SearchResults::ZOEKT_COUNT_LIMIT', 123)
      params = described_class.new(limit: 10)
      expect(params.max_line_match_window).to eq(123)
    end
  end

  describe '#max_line_match_results' do
    it 'returns 0 when multi_match is present' do
      params = described_class.new(limit: 10, multi_match: multi_match_double)
      expect(params.max_line_match_results).to eq(0)
    end

    it 'returns search_limit when multi_match is not present' do
      params = described_class.new(limit: 10)
      expect(params.max_line_match_results).to eq(10)
    end
  end

  describe '#max_line_match_results_per_file' do
    context 'when multi_match is passed' do
      it 'factors the max_chunks_size passed in the multi_match' do
        result = described_class.new(limit: 10, multi_match: multi_match_double).max_line_match_results_per_file
        expect(result).to eq(multi_match_double.max_chunks_size * described_class::LINE_MATCHES_FACTOR)
      end
    end

    context 'when multi_match is not passed' do
      it 'factors the MAX_CHUNKS_PER_FILE' do
        result = described_class.new(limit: 10).max_line_match_results_per_file
        expect(result).to eq(Search::Zoekt::MultiMatch::MAX_CHUNKS_PER_FILE * described_class::LINE_MATCHES_FACTOR)
      end
    end
  end
end
