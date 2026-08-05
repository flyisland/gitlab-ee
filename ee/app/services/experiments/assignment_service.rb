# frozen_string_literal: true

module Experiments
  class AssignmentService
    include Gitlab::Experiment::Dsl

    def initialize(experiment_name:, current_user:, context_params: {})
      @experiment_name = experiment_name.to_s
      @context_params = context_params.to_h.symbolize_keys
      @current_user = current_user
    end

    def read
      result = resolve_context
      return result if result.error?

      context = result.payload[:context]
      exp = experiment(experiment_name.to_sym, **context)
      cached_variant = exp.cache.read

      ServiceResponse.success(payload: {
        experiment: experiment_name,
        variant: cached_variant,
        context_key: exp.cache_key,
        cached: cached_variant.present?
      })
    end

    private

    attr_reader :experiment_name, :context_params, :current_user

    def resolve_context
      ContextResolver.new(
        experiment_name: experiment_name,
        context_params: context_params,
        current_user: current_user
      ).resolve
    end
  end
end
