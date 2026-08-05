import { GlEmptyState, GlLoadingIcon } from '@gitlab/ui';
import { MountingPortal } from 'portal-vue';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import { stubComponent } from 'helpers/stub_component';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import ReleaseSidePanel from 'ee/cd/components/release_side_panel.vue';
import TriggerDeployment from 'ee/cd/components/trigger_deployment.vue';
import cdVersionSetQuery from 'ee/cd/graphql/cd_version_set.query.graphql';
import DynamicPanel from '~/vue_shared/components/dynamic_panel.vue';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import { buildVersionSetQueryResponse } from './mock_data';

Vue.use(VueApollo);

describe('ReleaseSidePanel', () => {
  let wrapper;
  let defaultQueryHandler;

  // `api-server` appears twice (a multi-source service), `worker` once.
  const release = {
    id: 'gid://gitlab/Cd::VersionSet/1',
    name: 'v1_1_0',
    createdAt: '2024-06-01T00:00:00Z',
    application: { id: 'gid://gitlab/Cd::Application/5', name: 'payments-platform' },
    rollouts: { nodes: [{ id: 'gid://gitlab/Cd::Rollout/1', state: 'IN_PROGRESS' }] },
    versionSetEntries: {
      nodes: [
        {
          id: 'gid://gitlab/Cd::VersionSetEntry/1',
          service: { id: 'gid://gitlab/Cd::Service/10', name: 'api-server' },
          version: { id: 'gid://gitlab/Cd::Version/1', name: 'v2_4_1' },
        },
        {
          id: 'gid://gitlab/Cd::VersionSetEntry/2',
          service: { id: 'gid://gitlab/Cd::Service/10', name: 'api-server' },
          version: { id: 'gid://gitlab/Cd::Version/9', name: 'v3_0_0' },
        },
        {
          id: 'gid://gitlab/Cd::VersionSetEntry/3',
          service: { id: 'gid://gitlab/Cd::Service/20', name: 'worker' },
          version: { id: 'gid://gitlab/Cd::Version/2', name: 'v1_9_0' },
        },
      ],
    },
  };

  const findPortal = () => wrapper.findComponent(MountingPortal);
  const findPanel = () => wrapper.findComponent(DynamicPanel);
  const findEmptyState = () => wrapper.findComponent(GlEmptyState);
  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findTitle = () => wrapper.findByTestId('release-title');
  const findStatusBadge = () => wrapper.findByTestId('release-status-badge');
  const findCreated = () => wrapper.findByTestId('release-created');
  const findApplication = () => wrapper.findByTestId('release-application');
  const findServicesTitle = () => wrapper.findByTestId('services-title');
  const findServiceRows = () => wrapper.findAllByTestId('service-row');
  const findTriggerDeployment = () => wrapper.findComponent(TriggerDeployment);

  beforeEach(() => {
    defaultQueryHandler = jest.fn().mockResolvedValue(buildVersionSetQueryResponse(release));
  });

  const createComponent = ({ releaseId = '1', queryHandler = defaultQueryHandler } = {}) => {
    wrapper = shallowMountExtended(ReleaseSidePanel, {
      apolloProvider: createMockApollo([[cdVersionSetQuery, queryHandler]]),
      propsData: { id: '5', releaseId },
      stubs: {
        DynamicPanel,
        MountingPortal: stubComponent(MountingPortal, { name: 'MountingPortal' }),
      },
    });
  };

  describe('when the release is found', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('fetches the version set by id', () => {
      expect(defaultQueryHandler).toHaveBeenCalledWith({ id: 'gid://gitlab/Cd::VersionSet/1' });
    });

    it('renders MountingPortal targeting #contextual-panel-portal', () => {
      expect(findPortal().attributes('mount-to')).toBe('#contextual-panel-portal');
    });

    it('shows the Release label and the release name in the header', () => {
      expect(wrapper.text()).toContain('Release');
      expect(findTitle().text()).toBe('v1_1_0');
    });

    it('emits close when the panel emits close', () => {
      findPanel().vm.$emit('close');

      expect(wrapper.emitted('close')).toHaveLength(1);
    });

    it('renders the rollout status badge', () => {
      expect(findStatusBadge().text()).toBe('In progress');
    });

    it('renders the created date via TimeAgo', () => {
      expect(findCreated().findComponent(TimeAgo).props('time')).toBe('2024-06-01T00:00:00Z');
    });

    it('renders the application name', () => {
      expect(findApplication().text()).toBe('payments-platform');
    });

    it('renders the "Services in this release" title', () => {
      expect(findServicesTitle().text()).toBe('Services in this release');
    });

    it('lists a service/version row per entry, repeating a multi-source service', () => {
      const rows = findServiceRows();

      expect(rows).toHaveLength(3);
      expect(rows.at(0).text()).toContain('api-server');
      expect(rows.at(0).text()).toContain('v2_4_1');
      expect(rows.at(1).text()).toContain('api-server');
      expect(rows.at(1).text()).toContain('v3_0_0');
      expect(rows.at(2).text()).toContain('worker');
      expect(rows.at(2).text()).toContain('v1_9_0');
    });

    it('does not render the not-found empty state', () => {
      expect(findEmptyState().exists()).toBe(false);
    });

    it('passes the organization, version set, and release name to TriggerDeployment', () => {
      expect(findTriggerDeployment().props()).toMatchObject({
        organizationId: 'gid://gitlab/Organization/1',
        versionSetId: 'gid://gitlab/Cd::VersionSet/1',
        releaseName: 'v1_1_0',
      });
    });

    describe('when TriggerDeployment emits deploy-triggered', () => {
      beforeEach(() => {
        findTriggerDeployment().vm.$emit('deploy-triggered');
      });

      it('re-emits deploy-triggered', () => {
        expect(wrapper.emitted('deploy-triggered')).toHaveLength(1);
      });
    });
  });

  describe('while loading', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(true);
    });

    it('does not render the not-found empty state', () => {
      expect(findEmptyState().exists()).toBe(false);
    });
  });

  describe('when the release is not found', () => {
    beforeEach(async () => {
      createComponent({
        queryHandler: jest.fn().mockResolvedValue(buildVersionSetQueryResponse(null)),
      });
      await waitForPromises();
    });

    it('renders the not-found empty state', () => {
      expect(findEmptyState().props('title')).toBe('Release not found');
    });

    it('does not render the release title', () => {
      expect(findTitle().exists()).toBe(false);
    });
  });

  describe('when the query errors', () => {
    const error = new Error('boom');

    beforeEach(async () => {
      jest.spyOn(Sentry, 'captureException').mockImplementation();
      createComponent({ queryHandler: jest.fn().mockRejectedValue(error) });
      await waitForPromises();
    });

    it('captures the exception in Sentry', () => {
      expect(Sentry.captureException).toHaveBeenCalledWith(error);
    });

    it('renders the not-found empty state', () => {
      expect(findEmptyState().props('title')).toBe('Release not found');
    });
  });
});
