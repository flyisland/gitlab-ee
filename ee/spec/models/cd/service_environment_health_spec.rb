# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::ServiceEnvironmentHealth, feature_category: :continuous_delivery do
  let_it_be(:application) { create(:cd_application) }
  let_it_be(:service) { create(:cd_service, application: application) }
  let_it_be(:environment) { create(:cd_environment) }

  describe 'factory' do
    it 'creates a valid service environment health using factory defaults' do
      expect(create(:cd_service_environment_health)).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:service).required }
    it { is_expected.to belong_to(:environment).required }
    it { is_expected.to belong_to(:organization).required }
  end

  describe 'enums' do
    it 'defines health enum' do
      is_expected.to define_enum_for(:health).with_values(
        unknown: 0,
        healthy: 1,
        degraded: 2,
        failed: 3
      )
    end
  end

  describe 'validations' do
    subject { build(:cd_service_environment_health, service: service, environment: environment) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:observed_at) }

    it 'rejects a second health row for the same service and environment' do
      create(:cd_service_environment_health, service: service, environment: environment)

      duplicate = build(:cd_service_environment_health, service: service, environment: environment)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:environment_id]).to be_present
    end
  end

  describe 'sharding key' do
    subject { build(:cd_service_environment_health, service: service, environment: environment) }

    it { is_expected.to populate_sharding_key(:organization_id).with(service.organization_id) }
  end

  describe 'HEALTH_SEVERITY_ORDER' do
    it 'assigns a severity rank to every known health value' do
      expect(described_class::HEALTH_SEVERITY_ORDER).to match_array(described_class.healths.keys)
    end
  end

  describe '.ordered_by_severity' do
    it 'orders failed, degraded, healthy, unknown from worst to best' do
      healthy_env = create(:cd_environment, organization: application.organization)
      degraded_env = create(:cd_environment, organization: application.organization)
      failed_env = create(:cd_environment, organization: application.organization)
      unknown_env = create(:cd_environment, organization: application.organization)

      healthy = create(:cd_service_environment_health, service: service, environment: healthy_env, health: :healthy)
      degraded = create(:cd_service_environment_health, service: service, environment: degraded_env,
        health: :degraded)
      failed = create(:cd_service_environment_health, service: service, environment: failed_env, health: :failed)
      unknown = create(:cd_service_environment_health, service: service, environment: unknown_env, health: :unknown)

      expect(described_class.where(service: service).ordered_by_severity)
        .to eq([failed, degraded, healthy, unknown])
    end

    context 'when a row has a health value not present in HEALTH_SEVERITY_ORDER' do
      it 'sorts it after all known values' do
        stub_const('Cd::ServiceEnvironmentHealth::HEALTH_SEVERITY_ORDER', %w[failed])

        failed_env = create(:cd_environment, organization: application.organization)
        healthy_env = create(:cd_environment, organization: application.organization)

        failed = create(:cd_service_environment_health, service: service, environment: failed_env, health: :failed)
        healthy = create(:cd_service_environment_health, service: service, environment: healthy_env,
          health: :healthy)

        expect(described_class.where(service: service).ordered_by_severity).to eq([failed, healthy])
      end
    end
  end

  describe '.worst_health_by_application' do
    let_it_be(:other_application) { create(:cd_application) }

    def report_health(target_service, health)
      create(:cd_service_environment_health,
        service: target_service,
        environment: create(:cd_environment, organization: target_service.organization),
        health: health)
    end

    it 'returns the worst health across each application, keyed by application id' do
      degraded_service = create(:cd_service, application: application)
      report_health(service, :healthy)
      report_health(degraded_service, :degraded)
      report_health(create(:cd_service, application: other_application), :failed)

      expect(described_class.worst_health_by_application([application.id, other_application.id]))
        .to eq(application.id => 'degraded', other_application.id => 'failed')
    end

    it 'omits applications with no reported health' do
      expect(described_class.worst_health_by_application([application.id])).to eq({})
    end

    context 'with unknown health' do
      it 'does not let unknown override a known health signal' do
        report_health(service, :healthy)
        report_health(create(:cd_service, application: application), :unknown)

        expect(described_class.worst_health_by_application([application.id]))
          .to eq(application.id => 'healthy')
      end

      it 'rolls up to unknown only when every service is unknown' do
        report_health(service, :unknown)
        report_health(create(:cd_service, application: application), :unknown)

        expect(described_class.worst_health_by_application([application.id]))
          .to eq(application.id => 'unknown')
      end
    end
  end
end
