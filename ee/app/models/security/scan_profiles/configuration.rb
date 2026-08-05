# frozen_string_literal: true

module Security
  module ScanProfiles
    module Configuration
      DEFAULTS_BY_TYPE = {
        dependency_scanning_post_processing:
          Defaults::DependencyScanningPostProcessing::VALUES
      }.freeze

      def self.defaults_for(scan_type)
        return {} if scan_type.blank?

        DEFAULTS_BY_TYPE.fetch(scan_type.to_sym, {})
      end

      def self.for(profile, project: nil)
        return {} unless profile

        config = defaults_for(profile.scan_type)
          .deep_merge((profile.configuration || {}).deep_symbolize_keys)

        config = apply_duo_overrides(config, project) if profile.post_processing? && project

        config
      end

      def self.apply_duo_overrides(config, project)
        return config unless resolve_dependency_bump_enabled?(project)

        auto_remediation = (config[:auto_remediation] || {}).merge(upgrade_policy: 'major')
        config.merge(auto_remediation: auto_remediation)
      end
      private_class_method :apply_duo_overrides

      def self.resolve_dependency_bump_enabled?(project)
        return false unless project

        project.duo_dependency_bump_breaking_changes_available?
      end
      private_class_method :resolve_dependency_bump_enabled?
    end
  end
end
