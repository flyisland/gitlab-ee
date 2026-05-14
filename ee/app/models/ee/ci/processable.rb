# frozen_string_literal: true

module EE
  module Ci
    module Processable
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      override :dependency_variables
      def dependency_variables
        ::Security::ExecutionPolicy::VariablesOverride
          .new(project: project, job_options: options)
          .apply_variables_override(super, source: :dotenv)
      end
    end
  end
end
