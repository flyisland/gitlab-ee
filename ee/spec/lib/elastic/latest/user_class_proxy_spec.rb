# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::Latest::UserClassProxy, :elasticsearch_settings_enabled, feature_category: :global_search do
  subject(:user_class_proxy) { described_class.new(User, use_separate_indices: true) }

  let(:query) { 'bob' }
  let(:options) { { search_level: 'global' } }
  let_it_be(:user) { create(:user) }
  let_it_be_with_reload(:project) { create(:project) }
  let_it_be_with_reload(:group) { create(:group) }
  let(:elastic_search) { user_class_proxy.elastic_search(query, options: options) }
  let(:response) do
    Elasticsearch::Model::Response::Response.new(User, Elasticsearch::Model::Searching::SearchRequest.new(User, '*'))
  end

  describe '#elastic_search' do
    it 'calls ApplicationClassProxy.search once' do
      expect(user_class_proxy).to receive(:search).once

      elastic_search
    end

    describe 'methods being called' do
      before do
        allow(user_class_proxy).to receive(:search).and_return(response)
      end

      it 'calls fuzzy_query_hash and forbidden_states_filter' do
        expect(user_class_proxy).to receive(:fuzzy_query_hash).and_call_original.once
        expect(user_class_proxy).to receive(:forbidden_states_filter).and_call_original.once
        expect(Search::Elastic::Filters).to receive(:by_user_accessible_namespaces).and_call_original.once
        expect(user_class_proxy).not_to receive(:namespace_query)
        expect(user_class_proxy).not_to receive(:global_autocomplete_filter)

        elastic_search
      end

      context 'when the query contains simple query string syntax characters' do
        let(:query) { 'bo*' }

        it 'calls basic_query_hash and forbidden_states_filter' do
          expect(user_class_proxy).to receive(:basic_query_hash).and_call_original.once
          expect(user_class_proxy).to receive(:forbidden_states_filter).and_call_original.once
          expect(Search::Elastic::Filters).to receive(:by_user_accessible_namespaces).and_call_original.once
          expect(user_class_proxy).not_to receive(:namespace_query)
          expect(user_class_proxy).not_to receive(:global_autocomplete_filter)

          elastic_search
        end
      end
    end

    context 'when the query does not contain simple query string syntax characters', :elastic_delete_by_query do
      describe 'query' do
        let(:options) { { search_level: 'global' } }

        it 'has fuzzy queries and filters for forbidden state' do
          elastic_search.response

          assert_named_queries(
            'must:bool:should:fuzzy:name',
            'must:bool:should:fuzzy:username',
            'must:bool:should:fuzzy:public_email',
            'filter:not_forbidden_state'
          )
        end

        context 'with admin passed in arguments' do
          let(:options) { { admin: true, search_level: 'global' } }

          it 'does not have the forbidden state filter and includes email for the query search' do
            elastic_search.response

            assert_named_queries(
              'must:bool:should:fuzzy:name',
              'must:bool:should:fuzzy:username',
              'must:bool:should:fuzzy:email',
              'must:bool:should:fuzzy:public_email'
            )
          end
        end

        context 'with count_only passed in arguments' do
          let(:options) { { count_only: true, search_level: 'global' } }

          it 'only has filters' do
            elastic_search.response

            assert_named_queries(
              'filter:bool:should:fuzzy:name',
              'filter:bool:should:fuzzy:username',
              'filter:bool:should:fuzzy:public_email',
              'filter:not_forbidden_state'
            )
          end
        end
      end
    end

    context 'when the query contains simple query string syntax characters', :elastic_delete_by_query do
      let(:query) { 'bo*' }
      let(:options) { { search_level: 'global' } }

      describe 'query' do
        it 'has a simple query string and filters for forbidden state' do
          elastic_search.response

          assert_named_queries(
            'user:match:search_terms',
            'filter:not_forbidden_state'
          )
        end
      end
    end
  end

  describe '#forbidden_states_filter' do
    let(:query_hash) { user_class_proxy.forbidden_states_filter(base_query_hash, options) }
    let(:base_query_hash) { { query: { bool: { filter: [] } } } }
    let(:options) { {} }

    it 'has a term with forbidden_state eq false' do
      filters = query_hash.dig(:query, :bool, :filter)
      expect(filters.count).to eq(1)
      filter_query = filters.first

      expect(filter_query).to have_key(:term)
      expect(filter_query[:term]).to include({ in_forbidden_state: hash_including(value: false) })
    end

    context 'when the user is an admin' do
      let(:options) { { admin: true } }

      it 'returns query_hash unchanged' do
        expect(query_hash).to eq(base_query_hash)
      end
    end
  end
end
