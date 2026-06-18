# frozen_string_literal: true

module Search
  module Zoekt
    class Query
      include Gitlab::Utils::StrongMemoize

      EXACT_SYNTAX_FILTERS = %w[c case f file lang sym].freeze
      SEGMENT_REGEX = %r{"[^"]*"|"[^"]*\z|[^"]+}
      SUPPORTED_SYNTAX_FILTERS = (EXACT_SYNTAX_FILTERS + AdvancedCodeSearchFilterTranspiler::ADVANCED_CODE_SEARCH_FILTERS).freeze

      attr_reader :query, :source

      def initialize(query, source: nil)
        raise ArgumentError, 'query argument can not be nil' unless query

        @source = source&.to_sym
        @query = query
      end

      def formatted_query(search_mode)
        mode = search_mode.to_sym
        raise ArgumentError, 'Not a valid search_mode' unless %i[exact regex].include?(mode)

        term = keyword_segments.map { |seg| format_segment(seg, mode) }.join(' ').strip
        return term if filters.empty?

        transformed_filters = filters.map do |filter|
          next filter unless source == :api # transpilation is supported only for api

          AdvancedCodeSearchFilterTranspiler.new(filter).transpile
        end

        term.present? ? "#{term} #{transformed_filters.join(' ')}" : transformed_filters.join(' ')
      end

      private

      def segments
        @segments ||= query.scan(SEGMENT_REGEX)
      end

      def keyword_segments
        segments.filter_map do |seg|
          if quoted?(seg)
            strip_quotes(seg).empty? ? nil : seg
          else
            stripped = seg.gsub(query_matcher_regex, ' ').squeeze(' ').strip
            stripped.empty? ? nil : stripped
          end
        end
      end

      def filters
        @filters ||= segments.flat_map { |seg| quoted?(seg) ? [] : seg.scan(query_matcher_regex) }
      end

      def format_segment(segment, mode)
        if quoted?(segment)
          inner = strip_quotes(segment)
          mode == :exact ? RE2::Regexp.escape(inner) : inner
        else
          mode == :exact ? RE2::Regexp.escape(segment) : segment
        end
      end

      def quoted?(segment)
        segment.length > 1 && segment.start_with?('"')
      end

      def strip_quotes(segment)
        inner = segment[1..]
        inner = inner[0..-2] if inner.end_with?('"')
        inner
      end

      # Requires a left boundary so `testlang:ruby` is not split into
      # `test` + `lang:ruby`.
      def query_matcher_regex
        Regexp.union(available_syntax_filters.map { |filter| /(?<!\S)-?#{filter}:\S+/ })
      end
      strong_memoize_attr(:query_matcher_regex)

      def available_syntax_filters
        extra = ::Search::Zoekt.feature_available?(:repo_filter_search) ? %w[repo] : []
        SUPPORTED_SYNTAX_FILTERS + extra
      end
      strong_memoize_attr(:available_syntax_filters)
    end
  end
end
