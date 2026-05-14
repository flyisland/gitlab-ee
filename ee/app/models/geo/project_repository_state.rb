# frozen_string_literal: true

module Geo
  class ProjectRepositoryState < ApplicationRecord
    include ::Geo::VerificationStateDefinition

    belongs_to :project_repository, inverse_of: :project_repository_state
    belongs_to :project

    validates :verification_state, :project_repository, presence: true
    validates :project_repository, uniqueness: true

    before_validation :set_project_from_project_repository
    before_validation :prevent_concurrent_inserts

    private

    def set_project_from_project_repository
      self.project_id ||= project_repository&.project_id
    end

    # This method will block while another database transaction attempts to insert the same data.
    # After the lock is released by the other transaction, the uniqueness validation may fail
    # with record not unique validation error.
    #
    # Without this block the uniqueness validation wouldn't be able to detect duplicated
    # records as transactions can't see each other's changes.
    def prevent_concurrent_inserts
      lock_key = ['project_repository_states', project_repository_id].join('-')
      lock_expression = "hashtext(#{connection.quote(lock_key)})"
      connection.execute("SELECT pg_advisory_xact_lock(#{lock_expression})") # rubocop:disable Database/AvoidUsingConnectionExecute -- Advisory locks require direct SQL; no ActiveRecord abstraction exists
    end
  end
end
