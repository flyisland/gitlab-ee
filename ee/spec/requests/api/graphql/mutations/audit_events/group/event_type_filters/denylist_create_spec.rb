# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Add denylist event type filters for a group streaming destination', feature_category: :audit_events do
  include GraphqlHelpers

  let_it_be(:destination, freeze: false) { create(:audit_events_group_external_streaming_destination) }
  let_it_be(:group) { destination.group }
  let_it_be(:current_user) { create(:user) }

  let(:event_type_filters) { ['event_type_filters_created'] }
  let(:input) do
    {
      destination_id: global_id_of(destination).to_s,
      event_type_filters: event_type_filters
    }
  end

  let(:mutation) { graphql_mutation(:audit_events_group_destination_denylist_events_add, input) }
  let(:mutation_response) { graphql_mutation_response(:audit_events_group_destination_denylist_events_add) }

  subject(:mutate) { post_graphql_mutation(mutation, current_user: current_user) }

  context 'when feature is licensed' do
    before do
      stub_licensed_features(external_audit_events: true)
    end

    context 'when current user is a group owner' do
      before_all do
        group.add_owner(current_user)
      end

      it 'creates a denylist filter' do
        expect { mutate }.to change { destination.event_type_denylist_filters.count }.by(1)

        expect(mutation_response['errors']).to be_empty
        expect(mutation_response['eventTypeFilters']).to contain_exactly('event_type_filters_created')
      end

      context 'when an event_type_filters argument is empty' do
        let(:event_type_filters) { [] }

        it 'returns an error' do
          mutate

          expect(graphql_errors.first['message']).to include('event type filters must be present')
        end
      end
    end

    context 'when current user is a group maintainer' do
      before_all do
        group.add_maintainer(current_user)
      end

      it_behaves_like 'a mutation on an unauthorized resource'
    end
  end

  context 'when feature is unlicensed' do
    before_all do
      group.add_owner(current_user)
    end

    before do
      stub_licensed_features(external_audit_events: false)
    end

    it_behaves_like 'a mutation on an unauthorized resource'
  end
end
