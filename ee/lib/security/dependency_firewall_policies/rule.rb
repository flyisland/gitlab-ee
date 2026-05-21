# frozen_string_literal: true

module Security
  module DependencyFirewallPolicies
    class Rule
      ACTION_ALLOWED = :allowed
      ACTION_DENIED = :denied
      ACTION_WARNED = :warned

      REASON_EXCEPTION = :exception
      REASON_EVALUATION = :evaluation
      REASON_NO_MATCHES = :no_matches

      def initialize(rule_hash)
        @rule = rule_hash || {}
      end

      def license_rule?
        type == "license"
      end

      def purl_excepted?(package)
        purl_with_version = purl_string(package)
        purl_without_version = purl_string(package, include_version: false)

        package_purl = proc do |e_purl|
          (e_purl.split('/').last.include?('@') ? purl_with_version : purl_without_version).eql?(e_purl)
        end

        exception_purls.any?(package_purl)
      end

      def type
        rule[:type]
      end

      def evaluate(package, licenses)
        return unless license_rule?

        licenses = Array(licenses)
        return result(ACTION_DENIED) if licenses.empty?
        return result(ACTION_ALLOWED, REASON_EXCEPTION) if purl_excepted?(package)

        return result(ACTION_DENIED)  if licenses_denied?(licenses)
        return result(ACTION_ALLOWED) if licenses_allowed?(licenses)

        # if this is a denial rule and licenses did not match, allow
        # if this is an allowed rule and licenses did not match, block
        result(denied.present? ? ACTION_ALLOWED : ACTION_DENIED)
      end

      def denied_license_names
        denied.map { |license| license[:name] } # rubocop:disable Rails/Pluck -- Not a ActiveRecord object
      end

      def allowed_license_names
        allowed.map { |license| license[:name] } # rubocop:disable Rails/Pluck -- Not a ActiveRecord object
      end

      private

      attr_reader :rule

      def result(action, reason = REASON_EVALUATION)
        { action: action, reason: reason }
      end

      def exception_purls
        exceptions.map { |exception| exception[:purl] } # rubocop:disable Rails/Pluck -- Not a ActiveRecord object
      end

      def purl_string(package, include_version: true)
        base = "pkg:#{package[:purl_type]}/#{package[:name]}"
        return base if package[:version].blank? || !include_version

        "#{base}@#{package[:version]}"
      end

      def denied
        rule[:denied] || []
      end

      def allowed
        rule[:allowed] || []
      end

      def exceptions
        rule[:exceptions] || []
      end

      def licenses_denied?(licenses)
        denied_names = denied_license_names
        return false if denied_names.empty?

        # Return true if any license is in the denied list
        (denied_names & licenses).any?
      end

      def licenses_allowed?(licenses)
        licenses = Array(licenses)
        allowed_names = allowed_license_names
        return false if allowed_names.empty?

        # Return true if all licenses are in the allowed list
        (licenses - allowed_names).empty?
      end
    end
  end
end
