# frozen_string_literal: true

module JH
  module Projects
    module GraphsController
      extend ::Gitlab::Utils::Override
      extend ActiveSupport::Concern

      prepended do
        before_action do
          push_to_gon_attributes(:features, :lines_of_code, lines_of_code_enabled?)
        end
      end

      override :show
      def show
        return super unless lines_of_code_enabled?

        @ref_type = ref_type

        respond_to do |format|
          format.html
          format.json do
            commits = @project.repository.commits(@ref, limit: 6000, skip_merges: true)
            log = commits.map do |commit|
              ::Commits::FetchEffectiveLinesCountService.new(@project, commit).execute
            end

            render json: ::Gitlab::Json.dump(log)
          end
        end
      end

      private

      def lines_of_code_enabled?
        ::Feature.enabled?(:lines_of_code, @project) && \
          @project&.feature_available?(:real_lines_of_code)
      end
    end
  end
end
