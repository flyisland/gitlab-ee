# frozen_string_literal: true

module JH
  module Ci
    module CreatePipelineService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(_, **options, &block)
        return super if params[:ci_config_path].nil?

        # Use Project Model's validation logic
        project = ::Project.new(ci_config_path: params[:ci_config_path])
        project.valid?
        return super unless project.errors[:ci_config_path].present?

        pipeline = ::Ci::Pipeline.new
        project.errors[:ci_config_path].each do |error_message|
          pipeline.errors.add(:ci_config_path, error_message)
        end

        ServiceResponse.error(message: 'ci_config_path is invalid', payload: pipeline)
      end

      override :extra_options
      def extra_options(**options)
        return super if params[:ci_config_path].nil?

        super.merge(ci_config_path: params[:ci_config_path])
      end
    end
  end
end
