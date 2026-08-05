import { GlEmptyState, GlSprintf } from '@gitlab/ui';
import { MountingPortal } from 'portal-vue';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import { stubComponent } from 'helpers/stub_component';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import ServiceSidePanel from 'ee/cd/components/service_side_panel.vue';
import cdServiceQuery from 'ee/cd/graphql/cd_service.query.graphql';
import ArtifactSourceCard from 'ee/cd/components/artifact_source_card.vue';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import DynamicPanel from '~/vue_shared/components/dynamic_panel.vue';
import { makeService } from './mock_data';

Vue.use(VueApollo);

const defaultServiceId = String(getIdFromGraphQLId(makeService().id));

const buildResponse = (service) => ({
  data: { organization: { id: 'gid://gitlab/Organization/1', cdService: service } },
});

// The scalar service fields have no backend yet, so they are @client and resolved
// locally — map a resolver per field to the service under test.
const buildResolvers = (service) => ({
  CdService: {
    sync: () => service?.sync,
    health: () => service?.health,
    lastDeployed: () => service?.lastDeployed,
    deployedBy: () => service?.deployedBy,
    serviceType: () => service?.serviceType,
    environments: () => service?.environments ?? [],
  },
});

describe('ServiceSidePanel', () => {
  let wrapper;
  let queryHandler;

  const findPortal = () => wrapper.findComponent(MountingPortal);
  const findPanel = () => wrapper.findComponent(DynamicPanel);
  const findEmptyState = () => wrapper.findComponent(GlEmptyState);
  const findBackButton = () => wrapper.findByTestId('back-button');
  const findDetailTitle = () => wrapper.findByTestId('detail-title');
  const findDetailMode = () => wrapper.findByTestId('detail-mode');
  const findDetailSourceRef = () => wrapper.findByTestId('detail-source-ref');
  const findDetailLastDeployed = () => wrapper.findByTestId('detail-last-deployed');
  const findArtifactSourceCards = () => wrapper.findAllComponents(ArtifactSourceCard);
  const findArtifactSourcesEmpty = () => wrapper.findByTestId('artifact-sources-empty');
  const findTimeAgo = () => wrapper.findComponent(TimeAgo);

  const createComponent = ({ serviceId = defaultServiceId, service = makeService() } = {}) => {
    queryHandler = jest.fn().mockResolvedValue(buildResponse(service));
    wrapper = shallowMountExtended(ServiceSidePanel, {
      apolloProvider: createMockApollo([[cdServiceQuery, queryHandler]], buildResolvers(service)),
      propsData: { serviceId },
      stubs: {
        DynamicPanel,
        GlSprintf,
        MountingPortal: stubComponent(MountingPortal, { name: 'MountingPortal' }),
        TimeAgo,
      },
    });
  };

  describe('when the service resolves', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('runs the query for the resolved service', () => {
      expect(queryHandler).toHaveBeenCalledTimes(1);
    });

    it('renders MountingPortal targeting #contextual-panel-portal', () => {
      expect(findPortal().attributes('mount-to')).toBe('#contextual-panel-portal');
    });

    it('renders the DynamicPanel', () => {
      expect(findPanel().exists()).toBe(true);
    });

    it('renders the service name in the header', () => {
      expect(findDetailTitle().text()).toBe('api-server');
    });

    it('renders the detail body', () => {
      expect(findDetailMode().exists()).toBe(true);
    });

    it('does not render the empty state', () => {
      expect(findEmptyState().exists()).toBe(false);
    });

    it('renders the back button', () => {
      expect(findBackButton().exists()).toBe(true);
    });

    it('emits "close" when the back button is clicked', () => {
      findBackButton().vm.$emit('click');

      expect(wrapper.emitted('close')).toHaveLength(1);
    });

    it('emits "close" when the panel emits close', () => {
      findPanel().vm.$emit('close');

      expect(wrapper.emitted('close')).toHaveLength(1);
    });

    it('renders health and sync badges in the header', async () => {
      createComponent({
        service: makeService({ health: 'ok' }),
      });
      await waitForPromises();

      expect(wrapper.findByTestId('detail-health-badge').text()).toBe('Healthy');
      expect(wrapper.findByTestId('detail-sync-badge').text()).toBe('Synced');
    });

    it('renders the source ref', () => {
      expect(findDetailSourceRef().text()).toBe('registry.example.com/api-server');
      expect(findDetailSourceRef().classes()).toContain('gl-font-monospace');
    });

    it('renders ArtifactSourceCard components', () => {
      expect(findArtifactSourceCards()).toHaveLength(1);
    });

    it('passes artifact source data to ArtifactSourceCard', () => {
      expect(findArtifactSourceCards().at(0).props('artifactSource')).toMatchObject({
        id: 'source-1',
      });
    });

    it('does not render the empty artifact sources message', () => {
      expect(findArtifactSourcesEmpty().exists()).toBe(false);
    });
  });

  describe('last deployed text', () => {
    it('renders last deployed with time and user', async () => {
      createComponent();
      await waitForPromises();

      expect(findDetailLastDeployed().exists()).toBe(true);
      expect(findTimeAgo().props('time')).toBe('2024-06-10T08:00:00Z');
      expect(findDetailLastDeployed().text()).toContain('admin');
    });

    it('renders last deployed without user when deployedBy is absent', async () => {
      createComponent({
        service: makeService({ deployedBy: null }),
      });
      await waitForPromises();

      expect(findDetailLastDeployed().exists()).toBe(true);
      expect(findTimeAgo().props('time')).toBe('2024-06-10T08:00:00Z');
      expect(findDetailLastDeployed().text()).not.toContain('admin');
    });

    it('hides last deployed when lastDeployed is absent', async () => {
      createComponent({
        service: makeService({ lastDeployed: null }),
      });
      await waitForPromises();

      expect(findDetailLastDeployed().exists()).toBe(false);
    });
  });

  describe('with no artifact sources', () => {
    beforeEach(async () => {
      createComponent({
        service: makeService({ artifactSources: { nodes: [] } }),
      });
      await waitForPromises();
    });

    it('renders the empty artifact sources message', () => {
      expect(findArtifactSourcesEmpty().text()).toBe('No artifact sources configured.');
    });

    it('does not render ArtifactSourceCard components', () => {
      expect(findArtifactSourceCards()).toHaveLength(0);
    });
  });

  describe('when the service is not found', () => {
    beforeEach(async () => {
      createComponent({ service: null });
      await waitForPromises();
    });

    it('renders the empty state', () => {
      expect(findEmptyState().exists()).toBe(true);
    });

    it('does not render the detail body', () => {
      expect(findDetailMode().exists()).toBe(false);
    });

    it('does not render the detail title', () => {
      expect(findDetailTitle().exists()).toBe(false);
    });

    it('still renders the back button', () => {
      expect(findBackButton().exists()).toBe(true);
    });

    it('emits "close" when the back button is clicked', () => {
      findBackButton().vm.$emit('click');

      expect(wrapper.emitted('close')).toHaveLength(1);
    });
  });

  describe('sync badge visibility', () => {
    it('hides sync badge when sync is null', async () => {
      createComponent({
        service: makeService({ sync: null }),
      });
      await waitForPromises();

      expect(wrapper.findByTestId('detail-sync-badge').exists()).toBe(false);
    });

    it('shows sync badge when sync has a known value', async () => {
      createComponent({
        service: makeService({ sync: 'synced' }),
      });
      await waitForPromises();

      expect(wrapper.findByTestId('detail-sync-badge').exists()).toBe(true);
      expect(wrapper.findByTestId('detail-sync-badge').text()).toBe('Synced');
    });
  });

  describe('when serviceId is null', () => {
    beforeEach(async () => {
      createComponent({ serviceId: null });
      await waitForPromises();
    });

    it('skips the query', () => {
      expect(queryHandler).not.toHaveBeenCalled();
    });

    it('renders the empty state', () => {
      expect(findEmptyState().exists()).toBe(true);
    });

    it('does not render the detail body', () => {
      expect(findDetailMode().exists()).toBe(false);
    });
  });
});
