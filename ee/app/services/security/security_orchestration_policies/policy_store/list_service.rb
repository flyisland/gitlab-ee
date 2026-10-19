# frozen_string_literal: true

module Security
  module SecurityOrchestrationPolicies
    module PolicyStore
      class ListService < BaseService
        # The port speaks offset, not page number: this is the boundary that translates
        # the REST-facing "page N of size M" request into that, so the repository never
        # needs to know what a page is. GraphQL cursors already carry an offset and pass
        # it straight through.
        MAX_PAGE = 1_000
        MAX_OFFSET = ::Gitlab::PolicyStore::Ports::PolicyRepository::MAX_OFFSET

        # The REST/GraphQL-facing sentinel for "no lifecycle_state filter", so a caller
        # can request every policy in one page without a boolean losing that third state.
        ALL_LIFECYCLE_STATES = 'all'

        def initialize(
          container:, current_user:, trigger_type: nil, ids: nil,
          lifecycle_state: ::Gitlab::PolicyStore::Ports::PolicyRepository::DEFAULT_LIFECYCLE_STATE, page: nil,
          per_page: ::Gitlab::PolicyStore::Ports::PolicyRepository::DEFAULT_PER_PAGE, offset: nil)
          super(container: container, current_user: current_user)

          # A caller passes a page (REST) or an offset (GraphQL cursor), never both:
          # with an offset the page is unknown and the payload reports it as nil.
          raise ArgumentError, 'page and offset are mutually exclusive' if page && offset

          @trigger_type = trigger_type
          @ids = ids
          @requested_lifecycle_state = lifecycle_state
          @per_page = per_page.to_i.clamp(1, ::Gitlab::PolicyStore::Ports::PolicyRepository::MAX_PER_PAGE)
          @page = offset.nil? ? (page || 1).to_i.clamp(1, MAX_PAGE) : nil
          @offset = offset.nil? ? (@page - 1) * @per_page : offset.to_i.clamp(0, MAX_OFFSET)
        end

        def execute
          return forbidden_error unless authorized?(:read_govern_policy)
          return experiment_not_active_error unless experiment_active?

          result_page = ::Gitlab::PolicyStore.list(
            organization_id: organization.id, trigger_type: trigger_type, namespace_ids: readable_namespace_ids,
            lifecycle_state: lifecycle_state, ids: ids,
            offset: @offset, per_page: @per_page
          )

          ServiceResponse.success(payload: {
            policies: result_page.items, page: @page, offset: @offset, per_page: result_page.per_page,
            has_next_page: result_page.has_next_page?
          })
        rescue ::Gitlab::PolicyStore::ValidationError => error
          ServiceResponse.error(message: error.message, reason: :invalid)
        end

        private

        attr_reader :trigger_type, :ids, :requested_lifecycle_state

        def lifecycle_state
          requested_lifecycle_state == ALL_LIFECYCLE_STATES ? nil : requested_lifecycle_state
        end
      end
    end
  end
end
