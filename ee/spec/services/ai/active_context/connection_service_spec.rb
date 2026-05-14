# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::ActiveContext::ConnectionService, feature_category: :global_search do
  let(:elastic_helper) { instance_double(Gitlab::Elastic::Helper) }

  before do
    allow(Gitlab::Elastic::Helper).to receive(:default).and_return(elastic_helper)
  end

  describe '.connect_to_advanced_search_cluster' do
    context 'when distribution is opensearch' do
      before do
        allow(elastic_helper).to receive(:matching_distribution?).with(:opensearch).and_return(true)
        allow(elastic_helper).to receive(:matching_distribution?).with(:elasticsearch).and_return(false)
      end

      it 'creates an active opensearch connection with use_advanced_search_config option' do
        described_class.connect_to_advanced_search_cluster

        connection = Ai::ActiveContext::Connection.find_by(name: 'opensearch_advanced_search')

        expect(connection).to be_present
        expect(connection.adapter_class).to eq('ActiveContext::Databases::Opensearch::Adapter')
        expect(connection.use_advanced_search_config_option).to be true
        expect(connection).to be_active
      end
    end

    context 'when distribution is elasticsearch' do
      before do
        allow(elastic_helper).to receive(:matching_distribution?).with(:opensearch).and_return(false)
        allow(elastic_helper).to receive(:matching_distribution?).with(:elasticsearch).and_return(true)
      end

      it 'creates an active elasticsearch connection with use_advanced_search_config option' do
        described_class.connect_to_advanced_search_cluster

        connection = Ai::ActiveContext::Connection.find_by(name: 'elasticsearch_advanced_search')

        expect(connection).to be_present
        expect(connection.adapter_class).to eq('ActiveContext::Databases::Elasticsearch::Adapter')
        expect(connection.use_advanced_search_config_option).to be true
        expect(connection).to be_active
      end
    end

    context 'when distribution is neither opensearch nor elasticsearch' do
      before do
        allow(elastic_helper).to receive(:matching_distribution?).with(:opensearch).and_return(false)
        allow(elastic_helper).to receive(:matching_distribution?).with(:elasticsearch).and_return(false)
      end

      it 'raises a ConnectionError and does not create a connection' do
        expect do
          described_class.connect_to_advanced_search_cluster
        end.to raise_error(described_class::ConnectionError, 'Connection invalid')
          .and not_change { Ai::ActiveContext::Connection.count }
      end
    end
  end

  describe '.connect_to_custom_elasticsearch_cluster' do
    let(:url) { 'https://example.com:9200' }
    let(:username) { 'elastic' }
    let(:password) { 'secret' }

    it 'creates an active connection with elasticsearch adapter and stores credentials' do
      described_class.connect_to_custom_elasticsearch_cluster(url: url, username: username, password: password)

      connection = Ai::ActiveContext::Connection.find_by(name: 'elasticsearch_custom')

      expect(connection).to be_present
      expect(connection.adapter_class).to eq('ActiveContext::Databases::Elasticsearch::Adapter')
      expect(connection).to be_active
      expect(connection.options['url']).to match_array([{ scheme: 'https', host: 'example.com', port: 9200,
                                                          path: '', user: 'elastic', password: 'secret' }])
      expect(connection.options['username']).to eq(username)
      expect(connection.options['password']).to eq(password)
    end

    it 'raises ActiveRecord::RecordInvalid when URL scheme is invalid' do
      expect do
        described_class.connect_to_custom_elasticsearch_cluster(url: 'ftp://es.example.com')
      end.to raise_error(ActiveRecord::RecordInvalid, /only supports valid HTTP/)
    end
  end

  describe 'switching between connection types' do
    let_it_be(:custom_url) { 'https://custom.example.com:9200' }

    before do
      allow(elastic_helper).to receive(:matching_distribution?).with(:opensearch).and_return(false)
      allow(elastic_helper).to receive(:matching_distribution?).with(:elasticsearch).and_return(true)
    end

    context 'when no previous connection with the same name exists' do
      it 'creates a new connection without deactivating any previous one' do
        expect { described_class.connect_to_custom_elasticsearch_cluster(url: custom_url) }
          .to change { Ai::ActiveContext::Connection.count }.by(1)
      end
    end

    context 'when an existing active connection with the same name exists' do
      let_it_be(:existing_connection) do
        create(:ai_active_context_connection,
          name: 'elasticsearch_custom',
          adapter_class: 'ActiveContext::Databases::Elasticsearch::Adapter',
          options: { url: custom_url },
          active: true)
      end

      let(:new_username) { 'admin' }

      it 'updates the existing connection options in place' do
        described_class.connect_to_custom_elasticsearch_cluster(url: custom_url, username: new_username)

        expect(existing_connection.reload.read_attribute(:options)['username']).to eq(new_username)
      end

      it 'does not create a new connection' do
        expect { described_class.connect_to_custom_elasticsearch_cluster(url: custom_url, username: new_username) }
          .not_to change { Ai::ActiveContext::Connection.count }
      end

      it 'does not deactivate the existing connection' do
        expect(existing_connection).not_to receive(:deactivate!)

        described_class.connect_to_custom_elasticsearch_cluster(url: custom_url, username: new_username)
      end

      context 'when password is the mask value' do
        before do
          existing_connection.update!(options: { url: custom_url, password: 'secret' })
        end

        it 'preserves the existing password' do
          described_class.connect_to_custom_elasticsearch_cluster(
            url: custom_url,
            password: Ai::ActiveContext::Connection::MASKED_PASSWORD
          )

          expect(existing_connection.reload.read_attribute(:options)['password']).to eq('secret')
        end
      end
    end

    context 'when switching from Advanced Search to custom cluster' do
      let_it_be(:previous_connection) do
        create(:ai_active_context_connection,
          name: 'elasticsearch_advanced_search',
          adapter_class: 'ActiveContext::Databases::Elasticsearch::Adapter',
          options: { use_advanced_search_config: true },
          active: true)
      end

      it 'deactivates the previous connection and creates a new active one' do
        expect { described_class.connect_to_custom_elasticsearch_cluster(url: custom_url) }
          .to change { Ai::ActiveContext::Connection.count }.by(1)

        expect(Ai::ActiveContext::Connection.active.name).to eq('elasticsearch_custom')
        expect(previous_connection.reload).not_to be_active
      end

      it 'enqueues cleanup for the previous connection' do
        expect(Ai::ActiveContext::ConnectionCleanupWorker).to receive(:perform_async).with(previous_connection.id)

        described_class.connect_to_custom_elasticsearch_cluster(url: custom_url)

        expect(previous_connection.reload).not_to be_active
      end
    end

    context 'when switching from custom cluster to Advanced Search' do
      let_it_be(:previous_connection) do
        create(:ai_active_context_connection,
          name: 'elasticsearch_custom',
          adapter_class: 'ActiveContext::Databases::Elasticsearch::Adapter',
          options: { url: custom_url },
          active: true)
      end

      it 'deactivates the previous connection and enqueues its cleanup' do
        expect(Ai::ActiveContext::ConnectionCleanupWorker).to receive(:perform_async).with(previous_connection.id)

        described_class.connect_to_advanced_search_cluster

        expect(previous_connection.reload).not_to be_active
      end

      it 'creates a new active connection' do
        described_class.connect_to_advanced_search_cluster

        expect(Ai::ActiveContext::Connection.active).to be_present
        expect(Ai::ActiveContext::Connection.active).not_to eq(previous_connection)
      end
    end
  end

  describe '.disable_connection' do
    it 'schedules a DisableWorker job' do
      expect(Ai::ActiveContext::DisableWorker).to receive(:perform_in).with(1.minute)

      described_class.disable_connection
    end
  end
end
