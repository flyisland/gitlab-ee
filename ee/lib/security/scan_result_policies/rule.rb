# frozen_string_literal: true

module Security
  module ScanResultPolicies
    class Rule
      include ::Gitlab::Utils::StrongMemoize

      SCANNER_OVERRIDE_ATTRIBUTES = %i[
        vulnerability_attributes severity_levels vulnerabilities_allowed vulnerability_states
      ].freeze

      def initialize(rule)
        @rule = rule || {}
      end

      def type
        rule[:type]
      end

      def branches
        rule[:branches]
      end

      def branch_type
        rule[:branch_type]
      end

      def scanners
        rule[:scanners]
      end

      def vulnerabilities_allowed
        rule[:vulnerabilities_allowed]
      end

      def severity_levels
        rule[:severity_levels]
      end

      def vulnerability_states
        rule[:vulnerability_states]
      end

      def commits
        rule[:commits]
      end

      def branch_exceptions
        rule[:branch_exceptions] || []
      end

      def vulnerability_attributes
        rule[:vulnerability_attributes] || {}
      end

      def vulnerability_age
        rule[:vulnerability_age] || {}
      end

      def match_on_inclusion_license
        rule[:match_on_inclusion_license]
      end

      def license_types
        rule[:license_types] || []
      end

      def license_states
        rule[:license_states] || []
      end

      def licenses
        rule[:licenses] || {}
      end

      def scanner_configurations
        raw_scanners.map { |scanner| build_scanner_config(scanner, use_overrides: true) }
      end
      strong_memoize_attr :scanner_configurations

      def has_enrichment_filters?
        all_vulnerability_attributes.any? do |attrs|
          attrs.key?(:known_exploited) || attrs.key?(:epss_score)
        end
      end

      def has_scanner_overrides?
        raw_scanners.any? do |scanner|
          next false unless hash_like?(scanner)

          scanner_hash = scanner.to_h.deep_symbolize_keys
          SCANNER_OVERRIDE_ATTRIBUTES.any? { |attr| scanner_hash[attr].present? }
        end
      end

      private

      attr_reader :rule

      def raw_scanners
        scanners || []
      end

      def all_vulnerability_attributes
        scanner_configurations.map(&:vulnerability_attributes) + [vulnerability_attributes]
      end
      strong_memoize_attr :all_vulnerability_attributes

      def build_scanner_config(scanner, use_overrides:)
        if hash_like?(scanner) && use_overrides
          scanner_hash = scanner.to_h.deep_symbolize_keys
          ScannerConfig.new(
            type: scanner_hash[:type],
            vulnerability_attributes: scanner_hash[:vulnerability_attributes] || vulnerability_attributes,
            severity_levels: scanner_hash[:severity_levels] || severity_levels,
            vulnerabilities_allowed: scanner_hash[:vulnerabilities_allowed] || vulnerabilities_allowed,
            vulnerability_states: scanner_hash[:vulnerability_states] || vulnerability_states
          )
        else
          ScannerConfig.new(
            type: hash_like?(scanner) ? scanner.to_h.deep_symbolize_keys[:type] : scanner.to_s,
            vulnerability_attributes: vulnerability_attributes,
            severity_levels: severity_levels,
            vulnerabilities_allowed: vulnerabilities_allowed,
            vulnerability_states: vulnerability_states
          )
        end
      end

      def hash_like?(scanner)
        scanner.is_a?(Hash)
      end
    end
  end
end
