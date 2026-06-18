# frozen_string_literal: true

module DependencyManagement
  module SecurityUpdate
    class OpenRemediationsFinder
      # Initializes the finder for finding open remediation merge requests
      #
      # @param project [Project] The project to search within
      def initialize(project:)
        @project = project
      end

      # Executes the finder and returns open merge requests
      # created by the dependency management service account
      #
      # @return [ActiveRecord::Relation] Relation of open merge requests
      def execute
        scope
      end

      private

      attr_reader :project

      def scope
        service_account = project.dependency_management_service_account
        return MergeRequest.none unless service_account

        MergeRequest
          .of_projects(project)
          .authored(service_account)
          .opened
      end
    end
  end
end
