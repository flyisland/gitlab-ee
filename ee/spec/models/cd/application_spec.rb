# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::Application, feature_category: :continuous_delivery do
  describe 'associations' do
    it { is_expected.to belong_to(:organization).required }
    it { is_expected.to have_many(:services) }
    it { is_expected.to have_many(:version_sets) }
    it { is_expected.to have_many(:rollouts) }
    it { is_expected.to have_many(:application_flow_definitions) }

    it 'orders application_flow_definitions by version descending' do
      application = create(:cd_application)
      # Created in ascending version order so the assertion proves the
      # association returns them version-descending.
      first = create(:cd_application_flow_definition, application: application)
      second = create(:cd_application_flow_definition, application: application)

      expect(application.application_flow_definitions).to eq([second, first])
    end
  end

  describe 'validations' do
    subject { create(:cd_application) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:organization_id) }

    describe 'name format' do
      it { is_expected.to allow_value('my-app').for(:name) }
      it { is_expected.to allow_value('my_app').for(:name) }
      it { is_expected.to allow_value('MyApp').for(:name) }
      it { is_expected.to allow_value('app1').for(:name) }
      it { is_expected.to allow_value('1app').for(:name) }
      it { is_expected.not_to allow_value('-app').for(:name) }
      it { is_expected.not_to allow_value('app-').for(:name) }
      it { is_expected.not_to allow_value('my app').for(:name) }
      it { is_expected.not_to allow_value('app/name').for(:name) }
      it { is_expected.not_to allow_value('app.name').for(:name) }
      it { is_expected.not_to allow_value('app!').for(:name) }
    end

    it { is_expected.to validate_length_of(:description).is_at_most(2000) }

    describe 'sharding key' do
      it 'is invalid without an organization' do
        application = build(:cd_application, organization: nil)

        expect(application).not_to be_valid
      end
    end
  end

  describe '.for_organization' do
    it 'returns applications belonging to the given organization' do
      application = create(:cd_application)
      create(:cd_application)

      expect(described_class.for_organization(application.organization_id)).to contain_exactly(application)
    end
  end

  describe '.in_organization' do
    let_it_be(:organization) { create(:organization) }
    let_it_be(:other_organization) { create(:organization) }
    let_it_be(:org_application) { create(:cd_application, organization: organization) }
    let_it_be(:other_org_application) { create(:cd_application, organization: other_organization) }

    it 'returns applications belonging to the organization' do
      expect(described_class.in_organization(organization)).to contain_exactly(org_application)
    end
  end

  describe '.search' do
    let_it_be(:organization) { create(:organization) }
    let_it_be(:payments) do
      create(:cd_application, organization: organization, name: 'payments-platform',
        description: 'Handles billing and invoices')
    end

    let_it_be(:web) do
      create(:cd_application, organization: organization, name: 'web-frontend',
        description: 'Customer facing UI')
    end

    def search(term)
      described_class.in_organization(organization).search(term)
    end

    it 'matches on name' do
      expect(search('payments')).to contain_exactly(payments)
    end

    it 'matches on description' do
      expect(search('invoices')).to contain_exactly(payments)
    end

    it 'is case-insensitive' do
      expect(search('PAYMENTS')).to contain_exactly(payments)
    end

    it 'returns nothing when nothing matches' do
      expect(search('nonexistent')).to be_empty
    end

    it 'treats LIKE wildcards as literal characters rather than matching everything' do
      expect(search('%')).to be_empty
    end
  end

  describe '#environments' do
    let_it_be(:organization) { create(:organization) }
    let_it_be(:application) { create(:cd_application, organization: organization) }
    let_it_be(:version_set) { create(:cd_version_set, application: application) }

    context 'when the application has no rollouts' do
      it 'returns no environments' do
        expect(application.environments).to be_empty
      end
    end

    context 'when the application has rolled out to environments' do
      it 'returns the distinct environments targeted by its rollouts' do
        staging = create(:cd_environment, :staging, organization: organization)
        production = create(:cd_environment, :production, organization: organization)
        rollout = create(:cd_rollout, version_set: version_set, application: application)
        create(:cd_rollout_environment, rollout: rollout, environment: staging, position: 1)
        create(:cd_rollout_environment, rollout: rollout, environment: production, position: 2)

        expect(application.environments).to contain_exactly(staging, production)
      end

      it 'does not duplicate an environment targeted by multiple rollouts' do
        environment = create(:cd_environment, organization: organization)
        # Only one non-terminal rollout is allowed per application at a time,
        # so the first rollout must reach a terminal state before the second
        # can be created.
        first_rollout = create(:cd_rollout, version_set: version_set, application: application,
          state: :completed, workflow_ref: 'wf-1')
        second_rollout = create(:cd_rollout, version_set: version_set, application: application)
        create(:cd_rollout_environment, rollout: first_rollout, environment: environment)
        create(:cd_rollout_environment, rollout: second_rollout, environment: environment)

        expect(application.environments).to contain_exactly(environment)
      end
    end

    context 'when another application has rolled out to an environment' do
      it 'does not return that environment' do
        other_application = create(:cd_application, organization: organization)
        other_version_set = create(:cd_version_set, application: other_application)
        environment = create(:cd_environment, organization: organization)
        other_rollout = create(:cd_rollout, version_set: other_version_set, application: other_application)
        create(:cd_rollout_environment, rollout: other_rollout, environment: environment)

        expect(application.environments).to be_empty
      end
    end

    context 'when the application has more rollouts than RECENT_ROLLOUTS_LIMIT' do
      it 'ignores environments only targeted by rollouts outside the limit' do
        stub_const('Cd::Application::RECENT_ROLLOUTS_LIMIT', 2)

        old_environment = create(:cd_environment, organization: organization)
        recent_environment = create(:cd_environment, organization: organization)

        old_rollout = create(:cd_rollout, version_set: version_set, application: application,
          state: :completed, workflow_ref: 'wf-1')
        create(:cd_rollout_environment, rollout: old_rollout, environment: old_environment)
        create(:cd_rollout, version_set: version_set, application: application,
          state: :completed, workflow_ref: 'wf-2')
        create(:cd_rollout, version_set: version_set, application: application,
          state: :completed, workflow_ref: 'wf-3')
        recent_rollout = create(:cd_rollout, version_set: version_set, application: application)
        create(:cd_rollout_environment, rollout: recent_rollout, environment: recent_environment)

        expect(application.environments).to contain_exactly(recent_environment)
      end
    end
  end

  describe '#deployments' do
    let_it_be(:organization) { create(:organization) }
    let_it_be(:application) { create(:cd_application, organization: organization) }
    let_it_be(:version_set) { create(:cd_version_set, application: application) }
    let_it_be(:environment) { create(:cd_environment, organization: organization) }
    let_it_be(:service) { create(:cd_service, application: application) }

    context 'when the application has no deployments' do
      it 'returns none' do
        expect(application.deployments).to be_empty
      end
    end

    context 'when the application has deployments across its rollouts' do
      it 'returns all deployments for the application' do
        rollout = create(:cd_rollout, version_set: version_set, application: application)
        rollout_environment = create(:cd_rollout_environment, rollout: rollout, environment: environment)
        deployment = create(:cd_deployment, service: service, rollout_environment: rollout_environment)

        expect(application.deployments).to contain_exactly(deployment)
      end
    end

    context 'when another application has deployments' do
      it 'does not return that deployment' do
        other_application = create(:cd_application, organization: organization)
        other_version_set = create(:cd_version_set, application: other_application)
        other_service = create(:cd_service, application: other_application)
        other_rollout = create(:cd_rollout, version_set: other_version_set, application: other_application)
        other_rollout_environment = create(:cd_rollout_environment, rollout: other_rollout, environment: environment)
        create(:cd_deployment, service: other_service, rollout_environment: other_rollout_environment)

        expect(application.deployments).to be_empty
      end
    end

    context 'when the application has more rollouts than RECENT_ROLLOUTS_LIMIT' do
      it 'ignores deployments from rollouts outside the limit' do
        stub_const('Cd::Application::RECENT_ROLLOUTS_LIMIT', 1)

        old_rollout = create(:cd_rollout, version_set: version_set, application: application,
          state: :completed, workflow_ref: 'wf-1')
        old_rollout_environment = create(:cd_rollout_environment, rollout: old_rollout, environment: environment)
        create(:cd_deployment, service: service, rollout_environment: old_rollout_environment)

        recent_rollout = create(:cd_rollout, version_set: version_set, application: application)
        recent_rollout_environment = create(:cd_rollout_environment, rollout: recent_rollout, environment: environment)
        recent_deployment = create(:cd_deployment, service: service, rollout_environment: recent_rollout_environment)

        expect(application.deployments).to contain_exactly(recent_deployment)
      end
    end
  end

  describe '#last_deployed_at' do
    let_it_be(:organization) { create(:organization) }
    let_it_be(:application) { create(:cd_application, organization: organization) }
    let_it_be(:version_set) { create(:cd_version_set, application: application) }
    let_it_be(:environment) { create(:cd_environment, organization: organization) }
    let_it_be(:service) { create(:cd_service, application: application) }

    context 'when the application has no deployments' do
      it 'returns nil' do
        expect(application.last_deployed_at).to be_nil
      end
    end

    context 'when the application has multiple finished deployments' do
      it 'returns the most recent finished_at timestamp' do
        rollout = create(:cd_rollout, version_set: version_set, application: application)
        rollout_environment = create(:cd_rollout_environment, rollout: rollout, environment: environment)
        other_environment = create(:cd_environment, organization: organization)
        other_rollout_environment = create(:cd_rollout_environment, rollout: rollout, environment: other_environment)
        create(:cd_deployment, service: service, rollout_environment: rollout_environment,
          finished_at: 2.days.ago)
        most_recent = create(:cd_deployment, service: service, rollout_environment: other_rollout_environment,
          finished_at: 1.hour.ago)

        expect(application.last_deployed_at).to be_within(1.second).of(most_recent.finished_at)
      end
    end

    context 'when the most recently finished deployment belongs to a rollout outside RECENT_ROLLOUTS_LIMIT' do
      it 'ignores it' do
        stub_const('Cd::Application::RECENT_ROLLOUTS_LIMIT', 1)

        old_rollout = create(:cd_rollout, version_set: version_set, application: application,
          state: :completed, workflow_ref: 'wf-1')
        old_rollout_environment = create(:cd_rollout_environment, rollout: old_rollout, environment: environment)
        create(:cd_deployment, service: service, rollout_environment: old_rollout_environment,
          finished_at: 1.minute.ago)

        recent_rollout = create(:cd_rollout, version_set: version_set, application: application)
        recent_rollout_environment = create(:cd_rollout_environment, rollout: recent_rollout, environment: environment)
        create(:cd_deployment, service: service, rollout_environment: recent_rollout_environment, finished_at: nil)

        expect(application.last_deployed_at).to be_nil
      end
    end
  end
end
