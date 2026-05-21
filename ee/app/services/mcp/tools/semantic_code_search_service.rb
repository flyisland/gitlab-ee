# frozen_string_literal: true

module Mcp
  module Tools
    class SemanticCodeSearchService < CustomService
      include ::Gitlab::Utils::StrongMemoize
      extend ::Gitlab::Utils::Override
      include ::Ai::ActiveContext::Concerns::CodePostProcessing

      ACTIVE_CONTEXT_QUERY = ::Ai::ActiveContext::Queries
      REQUIRED_ABILITY = :read_code

      # Register version 0.1.0
      register_version '0.1.0', {
        description: <<~DESC.strip,
          Code search using natural language.

          Returns ranked code snippets with file paths and matching content for natural-language queries.

          Primary use cases:
          - When you do not know the exact symbol or file path
          - To see how a behavior or feature is implemented across the codebase
          - To discover related implementations (clients, jobs, feature flags, background workers)

          How to use:
          - Provide a concise, specific query (1–2 sentences) with concrete keywords like endpoint, class, or framework names
          - Add directory_path to narrow scope, e.g., "app/services/" or "ee/app/workers/"
          - Prefer precise intent over broad terms (e.g., "rate limiting middleware for REST API" instead of "rate limit")

          Example queries:
          - semantic_query: "JWT verification middleware" with directory_path: "app/"
          - semantic_query: "CI pipeline triggers downstream jobs" with directory_path: "lib/"
          - semantic_query: "feature flag to disable email notifications" (no directory_path)

          Output:
          - Ranked snippets with file paths and the matched content for each hit
          - Each result includes a score field (0.0 to 1.0) indicating semantic similarity to your query
            - Higher scores mean the code is more relevant; results are sorted by score descending
            - Scores above 0.8 typically indicate strong matches; below 0.5 may be tangentially related
          - Results include an overall confidence level (high/medium/low/unknown) based on score distribution:
            - HIGH: Strong match with clear winner - answer directly with confidence
            - MEDIUM: Multiple reasonable matches - present results but consider alternatives
            - LOW: Ambiguous or weak matches - consider asking user for clarification
            - UNKNOWN: Confidence cannot be determined (e.g., storage backend doesn't provide scores)
          - Results are grouped by file path with sequential line ranges merged
            - Each file group shows all relevant code regions from that file
            - Group score is the maximum score among all snippets in that file
        DESC
        input_schema: {
          type: 'object',
          properties: {
            semantic_query: {
              type: 'string',
              minLength: 1,
              maxLength: 1000,
              description: "A brief natural language query about the code you want to find in the project " \
                "(e.g.: 'authentication middleware', 'database connection logic', or 'API error handling')."
            },
            project_id: {
              type: 'string',
              description: 'Either a project id or project path.'
            },
            directory_path: {
              type: 'string',
              minLength: 1,
              maxLength: 100,
              description: 'Optional directory path to scope the search (e.g., "app/services/").'
            },
            knn: {
              type: 'integer',
              default: 64,
              minimum: 1,
              maximum: 100,
              description: "Number of nearest neighbors used internally. " \
                "This controls search precision vs. speed - higher values find more diverse results but take longer."
            },
            limit: {
              type: 'integer',
              default: 20,
              minimum: 1,
              maximum: 100,
              description: 'Maximum number of results to return.'
            }
          },
          required: %w[semantic_query project_id],
          additionalProperties: false
        },
        annotations: {
          readOnlyHint: true
        }
      }

      def available?
        current_user.present? && ACTIVE_CONTEXT_QUERY::Code.available?
      end

      override :ability
      def auth_ability
        REQUIRED_ABILITY
      end

      override :auth_target
      def auth_target(params)
        project_id = params.dig(:arguments, :project_id)

        raise ArgumentError, "#{name}: project not found, the params received: #{params.inspect}" if project_id.nil?

        find_project(project_id)
      end

      protected

      # Version 0.1.0 implementation
      def perform_0_1_0(arguments = {})
        limit = arguments[:limit] || 20
        knn = arguments[:knn] || 64
        semantic_query = arguments[:semantic_query]
        project_id = arguments[:project_id]
        directory_path = arguments[:directory_path]
        project = find_project(project_id)

        result = codebase_query(semantic_query).filter(
          project_or_id: project,
          path: directory_path,
          knn_count: knn,
          limit: limit,
          exclude_fields: %w[id source type embeddings_v1 reindexing],
          extract_source_segments: true,
          build_file_url: true
        )

        return failure_response(result, project_id) unless result.success?

        filtered_results = filter_excluded_results(result.to_a, project)
        formatted_text_output, structured_data = post_process_results(filtered_results)

        ::Mcp::Tools::Response.success(formatted_text_output, structured_data)
      end

      # Fallback to 0.1.0 behavior for any unimplemented versions
      override :perform_default
      def perform_default(arguments = {})
        perform_0_1_0(arguments)
      end

      private

      def failure_response(result, project_id)
        error_message = result.error_message(target_class: "Project", target_id: project_id)

        ::Mcp::Tools::Response.error(
          "Tool execution failed: Unable to perform semantic search, #{error_message}.",
          error_message
        )
      end

      def codebase_query(semantic_query)
        @codebase_query ||= ACTIVE_CONTEXT_QUERY::Code.new(search_term: semantic_query, user: current_user)
      end

      def post_process_results(filtered_results)
        confidence = compute_confidence_level(extract_scores(filtered_results))
        grouped = group_results_by_file(filtered_results)

        [
          build_text_content(grouped, confidence: confidence),
          build_structured_data(grouped, confidence: confidence)
        ]
      end

      def build_text_content(grouped_results, confidence:)
        text_output = format_grouped_text(grouped_results)
        text_output = "Confidence: #{confidence.to_s.upcase}\n\n#{text_output}" if confidence

        [{ type: 'text', text: text_output }]
      end

      def build_structured_data(grouped_results, confidence:)
        metadata = { count: grouped_results.length, has_more: false }
        metadata[:confidence] = confidence if confidence

        { items: grouped_results, metadata: metadata }
      end

      def format_grouped_text(grouped_results)
        lines = grouped_results.map.with_index(1) do |group, idx|
          score_str = group[:score] ? format(' (score: %.4f)', group[:score]) : ''

          ranges_text = group[:snippet_ranges].map do |range|
            "[Lines #{range[:start_line]}-#{range[:end_line]}]\n#{range[:content]}"
          end.join("\n")

          "#{idx}. #{group[:path]}#{score_str}\n#{ranges_text}"
        end

        lines.join("\n\n")
      end
    end
  end
end
