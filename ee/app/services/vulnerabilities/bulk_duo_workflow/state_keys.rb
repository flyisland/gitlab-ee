# frozen_string_literal: true

module Vulnerabilities
  module BulkDuoWorkflow
    module StateKeys
      private

      attr_reader :project, :workflow_name

      def key(type)
        "#{base_key}:#{type}"
      end

      def base_key
        "vulnerabilities:bulk_duo_workflow:{#{project.id}:#{workflow_name}}"
      end
    end
  end
end
