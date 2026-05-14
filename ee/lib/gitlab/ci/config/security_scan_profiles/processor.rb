# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module SecurityScanProfiles
        class Processor
          DEFAULT_APPLICATION_SECURITY_STAGE = 'application-security-testing'
          DEFAULT_BUILD_STAGE = 'build'
          DEFAULT_STAGES = Gitlab::Ci::Config::Entry::Stages.default

          def initialize(config, context, ref, source)
            @config = config.deep_dup
            @context = context
            @project = context.project
            @ref = ref
            @source = source
          end

          def perform
            return config unless process_scan_profiles?
            return config unless valid_stages_config?

            ensure_workflow_exists
            apply_scan_profiles

            config
          end

          private

          attr_reader :project, :context, :ref, :source, :config

          def process_scan_profiles?
            eligibility_service&.eligible?
          end

          def valid_stages_config?
            config[:stages].blank? || Entry::Stages.new(config[:stages]).valid?
          end

          def ensure_workflow_exists
            config[:workflow] = { rules: [{ when: 'always' }] } if config.empty?
          end

          def apply_scan_profiles
            defined_stages = config[:stages].presence || DEFAULT_STAGES.clone
            merge_scans_from_profiles(config, defined_stages)
            finalize_stages(defined_stages)
          end

          def finalize_stages(defined_stages)
            config[:stages] = cleanup_stages(defined_stages + config.fetch(:stages, []))
            config.delete(:stages) if config[:stages].blank?
          end

          def cleanup_stages(stages)
            stages.uniq!
            return if stages == DEFAULT_STAGES

            stages
          end

          def merge_scans_from_profiles(merged_config, defined_stages)
            return if profile_templates[:pipeline_scan].blank?

            unless defined_stages.include?(DEFAULT_APPLICATION_SECURITY_STAGE)
              insert_stage_after_or_prepend(defined_stages, DEFAULT_APPLICATION_SECURITY_STAGE,
                ['.pre', DEFAULT_BUILD_STAGE])
            end

            pipeline_scans = profile_templates[:pipeline_scan]
            pipeline_scans.each_value do |value|
              next if value.frozen?

              value[:stage] = DEFAULT_APPLICATION_SECURITY_STAGE
            end

            merged_config.deep_merge!(pipeline_scans)
            prioritize_glas!(merged_config)
          end

          def profile_templates
            @profile_templates ||= ::Security::SecurityOrchestrationPolicies::ScanPipelineService
             .new(context)
             .execute(all_profiles)
          end

          def all_profiles
            eligibility_service.applicable_profiles_triggers.map do |trigger|
              {
                scan: trigger.scan_profile.scan_type,
                template: trigger.scan_profile.ci_template_name
              }
            end
          end

          def eligibility_service
            @eligibility_service ||= context.scan_profile_eligibility_service
          end

          def insert_stage_after_or_prepend(stages, insert_stage_name, after_stages)
            stage_index = after_stages.filter_map { |stage| stages.index(stage) }.max

            if stage_index.nil?
              stages.unshift(insert_stage_name)
            else
              stages.insert(stage_index + 1, insert_stage_name)
            end
          end

          def prioritize_glas!(config)
            config[:variables] = (config[:variables] || {}).merge(
              { 'GITLAB_ADVANCED_SAST_ENABLED' => 'true' },
              # to allow MR pipelines to run GLAS. For additional details see:
              # https://docs.gitlab.com/user/application_security/detect/security_configuration/#use-security-scanning-tools-with-merge-request-pipelines
              { 'AST_ENABLE_MR_PIPELINES' => 'true' }
            )
            config
          end
        end
      end
    end
  end
end
