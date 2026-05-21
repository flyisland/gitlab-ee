# frozen_string_literal: true

module Gitlab
  module Duo
    module CodeReview
      class CustomInstructionsResolver
        def initialize(project)
          @project = project
        end

        def execute(merge_request)
          file_paths = merge_request.diffs.diff_files.map(&:file_path)
          return [] if file_paths.empty?

          instructions = fetch_all_instructions(merge_request.target_branch_sha)
          return [] if instructions.empty?

          filter_instructions(instructions, file_paths)
        end

        private

        attr_reader :project

        def ancestor_duo_template_projects
          project
            .group
            .self_and_ancestors(hierarchy_order: :asc)
            .with_duo_template_project
            .map(&:namespace_template_setting)
            .map(&:duo_template_project)
        end

        def fetch_all_instructions(ref)
          (fetch_ancestor_groups_instructions + fetch_project_instructions(ref)).compact.flatten
        end

        def fetch_ancestor_groups_instructions
          ancestor_duo_template_projects.uniq.filter_map do |duo_template_project|
            parse_repo_instructions(duo_template_project, duo_template_project.default_branch_or_main)
          rescue StandardError => e
            Gitlab::ErrorTracking.track_exception(
              e,
              project_id: project.id,
              duo_template_project_id: duo_template_project.id
            )

            []
          end
        end

        def fetch_project_instructions(ref)
          parse_repo_instructions(project, ref)
        rescue StandardError => e
          Gitlab::ErrorTracking.track_exception(e, project_id: project.id, ref: ref)
          []
        end

        def parse_repo_instructions(project, ref)
          raw_instructions = project.repository.code_review_custom_instructions_for(ref)

          return [] unless raw_instructions

          yaml_content = Gitlab::Config::Loader::Yaml.new(raw_instructions).load_raw!
          instructions = yaml_content['instructions']

          instructions.map do |instruction|
            excludes, includes = Array(instruction['fileFilters']).partition { |p| p.start_with?('!') }
            location = ::Gitlab::Routing.url_helpers.project_blob_url(
              project, File.join(ref, ::Repository::CODE_REVIEW_CUSTOM_INSTRUCTIONS_FILE_PATH)
            )

            ::Gitlab::Duo::CodeReview::CustomInstruction.new(
              name: instruction['name'],
              instructions: instruction['instructions'],
              include_patterns: includes,
              exclude_patterns: excludes.map { |p| p.delete_prefix('!') },
              location: location
            )
          end
        end

        def filter_instructions(instructions, file_paths)
          result = ::Ai::FileExclusionService.new(project).execute(file_paths)

          # Return all instructions if file exclusion result is invalid.
          # This ensures we don't accidentally exclude valid instructions due to service errors.
          return instructions if result.error?

          filtered_file_paths = result.payload.filter_map do |file_result|
            file_result[:path] unless file_result[:excluded]
          end

          instructions.select do |instruction|
            filtered_file_paths.any? { |path| instruction.apply_to?(path) }
          end
        end
      end
    end
  end
end
