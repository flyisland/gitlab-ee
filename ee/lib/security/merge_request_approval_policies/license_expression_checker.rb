# frozen_string_literal: true

module Security
  module MergeRequestApprovalPolicies
    # Evaluates denylist license policy violations for reports that may contain SPDX
    # compound expressions (e.g. "MIT AND Apache-2.0") rather than plain license names.
    #
    # Supports AND, OR, WITH, and PLUS expressions, single-identifier licenses, and
    # LicenseRef/DocumentRef matching rules (including LicenseRef wildcard).
    class LicenseExpressionChecker
      include Gitlab::Utils::StrongMemoize

      LICENSE_REF_PREFIX = 'LicenseRef-'
      DOCUMENT_REF_PREFIX = 'DocumentRef-'
      LICENSE_REF_WILDCARD = 'LicenseRef-*'
      LICENSE_REF_PREFIX_DOWNCASE = LICENSE_REF_PREFIX.downcase.freeze
      DOCUMENT_REF_PREFIX_DOWNCASE = DOCUMENT_REF_PREFIX.downcase.freeze
      SPDX_VERSION_SUFFIX_PATTERN = /(?<version>\d+(?:\.\d+)+)\z/
      PLUS_SUFFIX_PATTERN = /\A(?<base>.+)\+\z/

      # Pre-computes value-derived data once per license value so that
      # downcased and resolved_id are not recomputed on every denied-name iteration.
      ValueMatchInfo = Data.define(:value, :downcased, :resolved_id) do
        def license_ref?
          downcased.start_with?(LICENSE_REF_PREFIX_DOWNCASE)
        end

        def document_ref?
          downcased.start_with?(DOCUMENT_REF_PREFIX_DOWNCASE)
        end
      end

      def initialize(project, report, target_branch_report, approval_policy_source)
        @project = project
        @report = report
        @target_branch_report = target_branch_report
        @approval_policy_source = approval_policy_source
      end

      def denied_licenses_with_dependencies
        policy_denied_licenses = policy_licenses["denied"]
        return unless policy_denied_licenses.present?

        licenses_violating_policy = check_denied_licenses(policy_denied_licenses)
        return unless licenses_violating_policy.present?

        license_dependencies_map(licenses_violating_policy)
      end

      private

      attr_reader :project, :report, :target_branch_report, :approval_policy_source

      def policy_licenses
        approval_policy_source&.licenses || {}
      end

      def license_dependencies_map(licenses_violating_policy)
        licenses_violating_policy_map = Hash.new { |h, k| h[k] = Set.new }

        licenses_violating_policy.each do |license|
          licenses_violating_policy_map[license.name] += license.dependencies.map(&:name)
        end

        licenses_violating_policy_map.deep_transform_values(&:to_a)
      end

      def check_denied_licenses(policy_denied_licenses)
        denied_names = policy_denied_licenses.pluck("name") # rubocop: disable CodeReuse/ActiveRecord -- Not an ActiveRecord

        licenses_to_check.select do |license|
          expression = parse_expression(license.name)
          violates_policy?(expression.node, denied_names)
        end
      end

      def violates_policy?(node, denied_names)
        case node.type
        when :and
          violates_and_node?(node, denied_names)
        when :or
          violates_or_node?(node, denied_names)
        when :with
          violates_with_node?(node, denied_names)
        when :id
          violates_id_node?(node, denied_names)
        when :literal
          violates_literal_node?(node, denied_names)
        when :plus
          violates_plus_node?(node, denied_names)
        else
          # Fall back to literal match on the raw value for unknown node types.
          denied_names.include?(node.value.to_s)
        end
      end

      def violates_and_node?(node, denied_names)
        node.children.any? { |child| violates_policy?(child, denied_names) }
      end

      def violates_or_node?(node, denied_names)
        node.children.all? { |child| violates_policy?(child, denied_names) }
      end

      def violates_with_node?(node, denied_names)
        base_node, exception_node = node.children
        operator_keyword = node.value
        full_expression = "#{base_node.value} #{operator_keyword} #{exception_node.value}"

        violates_policy?(base_node, denied_names) ||
          denied_match?(full_expression, denied_names)
      end

      def violates_id_node?(node, denied_names)
        return true if denied_match?(node.value, denied_names)

        report_base_info = value_match_info(node.value)
        denied_names.any? do |policy_name|
          next false unless policy_name.end_with?('+')

          policy_plus_covers_report_base?(policy_name, node.value, report_base_info)
        end
      end

      def violates_literal_node?(node, denied_names)
        denied_names.include?(node.value)
      end

      def violates_plus_node?(node, denied_names)
        if license_ref_identifier?(node.value) || document_ref_identifier?(node.value)
          return denied_names.any? { |policy_name| matches_policy_name?(value_match_info(node.value), policy_name) }
        end

        report_base = node.value.delete_suffix('+')
        report_base_info = value_match_info(report_base)
        denied_names.any? { |policy_name| policy_plus_covers_report_base?(policy_name, report_base, report_base_info) }
      end

      # Checks whether a policy name covers a given report base identifier.
      # `policy_name` may or may not carry a `+` suffix depending on the call site:
      # - From `violates_id_node?`: always `+`-suffixed (enforced by the caller's guard),
      #   so the first two early returns below are no-ops there.
      # - From `violates_plus_node?`: may be plain or `+`-suffixed.
      def policy_plus_covers_report_base?(policy_name, report_base, report_base_info)
        return false if license_ref_identifier?(policy_name) || document_ref_identifier?(policy_name)
        return true if policy_name == report_base
        return true if matches_policy_name?(report_base_info, policy_name)

        policy_match = policy_name.match(PLUS_SUFFIX_PATTERN)
        return false unless policy_match

        policy_base = policy_match[:base]

        return true if spdx_version(policy_base).nil? && policy_base == report_base

        spdx_version_gte?(report_base, policy_base)
      end

      def spdx_version_gte?(report_base, policy_base)
        report_version = spdx_version(report_base)
        policy_version = spdx_version(policy_base)
        return false unless report_version && policy_version

        report_prefix = report_base.delete_suffix("-#{report_version}")
        policy_prefix = policy_base.delete_suffix("-#{policy_version}")
        return false unless report_prefix == policy_prefix

        report_parts = report_version.split('.').map(&:to_i)
        policy_parts = policy_version.split('.').map(&:to_i)
        length = [report_parts.length, policy_parts.length].max

        report_parts.fill(0, report_parts.length...length)
        policy_parts.fill(0, policy_parts.length...length)

        (report_parts <=> policy_parts) >= 0
      end

      def spdx_version(value)
        value.match(SPDX_VERSION_SUFFIX_PATTERN)&.[](:version)
      end

      def denied_match?(value, denied_names)
        info = value_match_info(value)
        denied_names.any? { |policy_name| matches_policy_name?(info, policy_name) }
      end

      def value_match_info(value)
        ValueMatchInfo.new(
          value: value,
          downcased: value.to_s.downcase,
          resolved_id: resolve_id(value)
        )
      end

      def matches_policy_name?(info, policy_name)
        if policy_name.casecmp(LICENSE_REF_WILDCARD) == 0
          info.license_ref?
        elsif case_insensitive_identifier_match?(policy_name, info)
          true
        else
          info.resolved_id == policy_name
        end
      end

      def case_insensitive_identifier_match?(policy_name, info)
        info.value.casecmp(policy_name) == 0 &&
          ((license_ref_identifier?(policy_name) && info.license_ref?) ||
            (document_ref_identifier?(policy_name) && info.document_ref?))
      end

      def license_ref_identifier?(value)
        value.to_s.downcase.start_with?(LICENSE_REF_PREFIX_DOWNCASE)
      end

      def document_ref_identifier?(value)
        value.to_s.downcase.start_with?(DOCUMENT_REF_PREFIX_DOWNCASE)
      end

      # Policies store display names (e.g. "MIT License") but SPDX expressions contain IDs
      # (e.g. "MIT"). Unknown identifiers are kept as-is.
      def resolve_id(id)
        spdx_catalogue_map[id] || id
      end

      def parse_expression(name)
        ::Gitlab::SPDX::ExpressionParser.new(name).parse
      end

      def spdx_catalogue_map
        Gitlab::SPDX::Catalogue.latest_active_licenses.to_h { |l| [l.id, l.name] }
      end
      strong_memoize_attr :spdx_catalogue_map

      def licenses_to_check
        if only_newly_detected?
          diff = target_branch_report.diff_with_including_new_dependencies_for_unchanged_licenses(report)
          diff[:added]
        elsif include_newly_detected?
          report.licenses + target_branch_report.licenses
        else
          target_branch_report.licenses
        end
      end
      strong_memoize_attr :licenses_to_check

      def only_newly_detected?
        license_states == [ApprovalProjectRule::NEWLY_DETECTED]
      end

      def include_newly_detected?
        license_states.include?(ApprovalProjectRule::NEWLY_DETECTED)
      end

      def license_states
        approval_policy_source&.license_states || []
      end
      strong_memoize_attr :license_states
    end
  end
end
