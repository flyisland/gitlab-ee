# frozen_string_literal: true

# When testing experiments that defines control and candidate variants,
# use the 'defines control and candidate variants' shared example from
# ee/spec/support/shared_examples/experiments/default_experiment_variants_shared_examples.rb
# After adding tests, verify rubocop passes by running: rubocop --only ExperimentsTestCoverage
module EE
  module ApplicationExperiment
    extend ActiveSupport::Concern

    class_methods do
      extend ::Gitlab::Utils::Override

      override :available?
      def available?
        ::Gitlab::Saas.feature_available?(:experimentation)
      end
    end
  end
end
