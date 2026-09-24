# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::HighAvailabilityChecker do
  let(:klass) do
    Class.new do
      include Gitlab::HighAvailabilityChecker
    end
  end

  subject(:instance) { klass.new }

  before do
    allow(Gitlab::Saas).to receive(:feature_available?).and_return(false)
    stub_feature_flags(jh_block_free_ha: true)
  end

  describe '#should_block_instance?' do
    it 'returns false when jh_block_free_ha is disabled' do
      stub_feature_flags(jh_block_free_ha: false)

      expect(instance.should_block_instance?).to be(false)
    end

    it 'returns false when SaaS subscriptions feature is available' do
      allow(Gitlab::Saas).to receive(:feature_available?).with(:gitlab_com_subscriptions).and_return(true)

      expect(instance.should_block_instance?).to be(false)
    end

    it 'returns true when free_version and high_availability are both true' do
      allow(instance).to receive_messages(free_version?: true, high_availability?: true)

      expect(instance.should_block_instance?).to be(true)
    end

    it 'returns false when high_availability is false' do
      allow(instance).to receive_messages(free_version?: true, high_availability?: false)

      expect(instance.should_block_instance?).to be(false)
    end

    it 'rescues errors and returns false' do
      allow(instance).to receive(:free_version?).and_return(true)
      allow(instance).to receive(:high_availability?).and_raise(StandardError, 'boom')

      expect(Gitlab::AppLogger).to receive(:error).with(/HighAvailabilityChecker/)
      expect(instance.should_block_instance?).to be(false)
    end
  end

  describe '#free_version?' do
    context 'when there is no current license' do
      before do
        License.current&.destroy!
      end

      it 'returns true' do
        expect(instance.send(:free_version?)).to be(true)
      end
    end

    context 'when current license is not paid (free plan)' do
      before do
        License.current&.destroy!
        # Create a license with legacy license type (not a paid plan)
        gl_license = create(:gitlab_license, restrictions: { plan: License::LEGACY_LICENSE_TYPE })
        create(:license, data: gl_license.export)
      end

      it 'returns true' do
        expect(instance.send(:free_version?)).to be(true)
      end
    end

    context 'when current license is paid' do
      context 'when grace period has not expired' do
        before do
          License.current&.destroy!
          # Create a paid license that expired 10 days ago (within grace period of 14 days)
          gl_license = create(
            :gitlab_license,
            plan: License::PREMIUM_PLAN,
            starts_at: Date.current - 1.year,
            expires_at: Date.current - 10.days
          )
          create(:license, data: gl_license.export)
        end

        it 'returns false (not considered free version during grace period)' do
          expect(instance.send(:free_version?)).to be(false)
        end
      end

      context 'when grace period has expired' do
        before do
          License.current&.destroy!
          # Create a paid license that expires today
          gl_license = create(
            :gitlab_license,
            restrictions: { plan: License::PREMIUM_PLAN },
            starts_at: 1.year.ago.to_date,
            expires_at: Date.current
          )
          create(:license, data: gl_license.export)

          # Travel to 20 days in the future (beyond grace period of 14 days)
          travel_to(20.days.from_now)
        end

        after do
          travel_back
        end

        it 'returns true (considered free version after grace period expires)' do
          expect(instance.send(:free_version?)).to be(true)
        end
      end

      context 'when license has not expired yet' do
        before do
          License.current&.destroy!
          # Create a paid license that is still valid
          gl_license = create(
            :gitlab_license,
            plan: License::PREMIUM_PLAN,
            starts_at: Date.current - 1.month,
            expires_at: Date.current + 1.month
          )
          create(:license, data: gl_license.export)
        end

        it 'returns false (not considered free version when license is active)' do
          expect(instance.send(:free_version?)).to be(false)
        end
      end
    end

    describe '#redis_sentinels_configured?' do
      let(:redis_wrapper) { instance_double(Gitlab::Redis::Wrapper) }

      before do
        allow(Gitlab::Redis::Wrapper).to receive(:new).and_return(redis_wrapper)
      end

      context 'when Redis Sentinels are configured' do
        before do
          allow(redis_wrapper).to receive(:sentinels?).and_return(true)
        end

        it 'returns true' do
          expect(instance.send(:redis_sentinels_configured?)).to be(true)
        end
      end

      context 'when Redis Sentinels are not configured' do
        before do
          allow(redis_wrapper).to receive(:sentinels?).and_return(false)
        end

        it 'returns false' do
          expect(instance.send(:redis_sentinels_configured?)).to be(false)
        end
      end

      context 'when an error occurs' do
        before do
          allow(redis_wrapper).to receive(:sentinels?).and_raise(StandardError, 'Redis connection failed')
          allow(Gitlab::AppLogger).to receive(:error)
        end

        it 'logs the error and returns false' do
          expect(Gitlab::AppLogger).to receive(:error).with(/HighAvailabilityChecker for redis/)
          expect(instance.send(:redis_sentinels_configured?)).to be(false)
        end
      end
    end

    describe '#gitaly_cluster_configured?' do
      before do
        allow(Gitlab::AppLogger).to receive(:error)
      end

      context 'when Gitaly clusters are configured (>= 1)' do
        before do
          allow(Gitaly::Server).to receive(:gitaly_clusters).and_return(2)
        end

        it 'returns true' do
          expect(instance.send(:gitaly_cluster_configured?)).to be(true)
        end
      end

      context 'when multiple storage repositories are configured' do
        before do
          allow(Gitaly::Server).to receive(:gitaly_clusters).and_return(0)
          allow(Gitlab.config.repositories).to receive(:storages).and_return({
            'default' => { 'gitaly_address' => 'tcp://gitaly1:8075' },
            'storage1' => { 'gitaly_address' => 'tcp://gitaly2:8075' }
          })
        end

        it 'returns true' do
          expect(instance.send(:gitaly_cluster_configured?)).to be(true)
        end
      end

      context 'when no high availability Gitaly configuration is present' do
        before do
          allow(Gitaly::Server).to receive(:gitaly_clusters).and_return(0)
          allow(Gitlab.config.repositories).to receive(:storages).and_return({
            'default' => { 'gitaly_address' => 'tcp://gitaly:8075' }
          })
        end

        it 'returns false' do
          expect(instance.send(:gitaly_cluster_configured?)).to be(false)
        end
      end

      context 'when an error occurs' do
        before do
          allow(Gitaly::Server).to receive(:gitaly_clusters).and_raise(StandardError, 'Gitaly error')
        end

        it 'logs the error and returns false' do
          expect(Gitlab::AppLogger).to receive(:error).with(/HighAvailabilityChecker for gitaly/)
          expect(instance.send(:gitaly_cluster_configured?)).to be(false)
        end
      end
    end

    describe '#postgresql_cluster_configured?' do
      let(:mock_connection) { instance_double(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) }
      let(:mock_db_config) { instance_double(ActiveRecord::DatabaseConfigurations::HashConfig) }
      let(:mock_configuration_hash) { {} }

      before do
        allow(Gitlab::AppLogger).to receive(:error)
        allow(mock_db_config).to receive(:configuration_hash).and_return(mock_configuration_hash)
        allow(ApplicationRecord).to receive_messages(connection_db_config: mock_db_config, connection: mock_connection)
        allow(mock_connection).to receive(:select_value).with("SHOW CLUSTER_NAME").and_return(nil)
      end

      context 'when patroni is configured in db config' do
        let(:mock_configuration_hash) { { patroni: { enabled: true } } }

        it 'returns true' do
          expect(instance.send(:postgresql_cluster_configured?)).to be(true)
        end
      end

      context 'when host contains patroni' do
        let(:mock_configuration_hash) { { host: 'patroni-cluster.example.com' } }

        it 'returns true' do
          expect(instance.send(:postgresql_cluster_configured?)).to be(true)
        end
      end

      context 'when load balancing hosts are configured' do
        let(:mock_configuration_hash) { { load_balancing: { 'hosts' => %w[host1 host2] } } }

        it 'returns true' do
          expect(instance.send(:postgresql_cluster_configured?)).to be(true)
        end
      end

      context 'when cluster name is present' do
        before do
          allow(mock_connection).to receive(:select_value).with("SHOW CLUSTER_NAME").and_return('my-cluster')
        end

        it 'returns true' do
          expect(instance.send(:postgresql_cluster_configured?)).to be(true)
        end
      end

      context 'when no high availability PostgreSQL configuration is present' do
        let(:mock_configuration_hash) { { host: 'localhost' } }

        it 'returns false' do
          expect(instance.send(:postgresql_cluster_configured?)).to be(false)
        end
      end

      context 'when an error occurs' do
        before do
          allow(ApplicationRecord).to receive(:connection_db_config).and_raise(StandardError, 'Database error')
        end

        it 'logs the error and returns false' do
          expect(Gitlab::AppLogger).to receive(:error).with(/HighAvailabilityChecker for postgresql/)
          expect(instance.send(:postgresql_cluster_configured?)).to be(false)
        end
      end
    end
  end

  describe '#high_availability?' do
    context 'when no high availability features are configured' do
      before do
        allow(instance).to receive_messages(redis_sentinels_configured?: false, gitaly_cluster_configured?: false,
          postgresql_cluster_configured?: false)
      end

      it 'returns false' do
        expect(instance.send(:high_availability?)).to be(false)
      end
    end

    context 'when Redis Sentinels are configured' do
      before do
        allow(instance).to receive_messages(redis_sentinels_configured?: true, gitaly_cluster_configured?: false,
          postgresql_cluster_configured?: false)
      end

      it 'returns true' do
        expect(instance.send(:high_availability?)).to be(true)
      end
    end

    context 'when Gitaly cluster is configured' do
      before do
        allow(instance).to receive_messages(redis_sentinels_configured?: false, gitaly_cluster_configured?: true,
          postgresql_cluster_configured?: false)
      end

      it 'returns true' do
        expect(instance.send(:high_availability?)).to be(true)
      end
    end

    context 'when PostgreSQL cluster is configured' do
      before do
        allow(instance).to receive_messages(redis_sentinels_configured?: false, gitaly_cluster_configured?: false,
          postgresql_cluster_configured?: true)
      end

      it 'returns true' do
        expect(instance.send(:high_availability?)).to be(true)
      end
    end

    context 'when multiple high availability features are configured' do
      before do
        allow(instance).to receive_messages(redis_sentinels_configured?: true, gitaly_cluster_configured?: true,
          postgresql_cluster_configured?: true)
      end

      it 'returns true' do
        expect(instance.send(:high_availability?)).to be(true)
      end
    end
  end
end
