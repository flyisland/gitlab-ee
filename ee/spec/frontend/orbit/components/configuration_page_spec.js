import { GlToggle, GlTable, GlBadge } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { createAlert } from '~/alert';
import OrbitConfiguration from 'ee/orbit/components/configuration_page.vue';
import ComponentHealthCard from 'ee/orbit/components/component_health_card.vue';
import ToolCard from 'ee/orbit/components/tool_card.vue';
import ownedNamespacesQuery from 'ee/orbit/graphql/queries/owned_namespaces.query.graphql';
import orbitUpdateMutation from 'ee/orbit/graphql/mutations/orbit_update.mutation.graphql';
import * as orbitApi from 'ee/orbit/api/orbit_api';

Vue.use(VueApollo);

jest.mock('~/alert');
jest.mock('ee/orbit/api/orbit_api');

const mockNamespaces = [
  {
    __typename: 'Group',
    id: 'gid://gitlab/Group/1',
    name: 'Test Group',
    fullName: 'Test Group',
    fullPath: 'test-group',
    avatarUrl: null,
    knowledgeGraphEnabled: true,
  },
  {
    __typename: 'Group',
    id: 'gid://gitlab/Group/2',
    name: 'Other Group',
    fullName: 'Other Group',
    fullPath: 'other-group',
    avatarUrl: null,
    knowledgeGraphEnabled: false,
  },
];

const mockQueryResponse = {
  data: {
    groups: {
      __typename: 'GroupConnection',
      nodes: mockNamespaces,
    },
  },
};

const mockMutationResponse = (enabled = true) => ({
  data: {
    orbitUpdate: {
      __typename: 'OrbitUpdatePayload',
      group: {
        __typename: 'Group',
        id: 'gid://gitlab/Group/1',
        name: 'Test Group',
        fullPath: 'test-group',
        knowledgeGraphEnabled: enabled,
      },
      errors: [],
    },
  },
});

const mockStatusResponse = {
  data: {
    status: 'healthy',
    version: '0.5.0',
    timestamp: '2026-03-02T12:00:00Z',
    components: [
      { name: 'clickhouse', status: 'healthy' },
      { name: 'indexer', status: 'healthy' },
    ],
  },
};

const mockToonDescription = `Execute graph queries using a DSL.

<toon>
query:
  type: string
  description: The query to execute
</toon>`;

const mockToolsResponse = {
  data: [
    { name: 'query_graph', description: mockToonDescription },
    { name: 'get_graph_entities', description: 'List the schema' },
  ],
};

describe('OrbitConfiguration', () => {
  let wrapper;
  let queryHandler;
  let mutationHandler;

  const createComponent = () => {
    queryHandler = queryHandler || jest.fn().mockResolvedValue(mockQueryResponse);
    mutationHandler = mutationHandler || jest.fn().mockResolvedValue(mockMutationResponse());

    wrapper = mount(OrbitConfiguration, {
      apolloProvider: createMockApollo([
        [ownedNamespacesQuery, queryHandler],
        [orbitUpdateMutation, mutationHandler],
      ]),
    });
  };

  const findTable = () => wrapper.findComponent(GlTable);
  const findToggles = () => wrapper.findAllComponents(GlToggle);
  const findHealthCards = () => wrapper.findAllComponents(ComponentHealthCard);
  const findToolCards = () => wrapper.findAllComponents(ToolCard);

  beforeEach(() => {
    orbitApi.fetchOrbitStatus.mockResolvedValue(mockStatusResponse);
    orbitApi.fetchOrbitTools.mockResolvedValue(mockToolsResponse);
    queryHandler = null;
    mutationHandler = null;
  });

  describe('status section', () => {
    describe('when status is healthy', () => {
      beforeEach(async () => {
        createComponent();
        await waitForPromises();
      });

      it('renders cluster version and healthy badge', () => {
        expect(wrapper.text()).toContain('0.5.0');
        expect(wrapper.findComponent(GlBadge).exists()).toBe(true);
      });

      it('renders component health cards', () => {
        const cards = findHealthCards();
        expect(cards).toHaveLength(2);
      });
    });

    describe('when status fetch fails', () => {
      beforeEach(async () => {
        orbitApi.fetchOrbitStatus.mockRejectedValue(new Error('Network error'));
        createComponent();
        await waitForPromises();
      });

      it('shows error alert via createAlert', () => {
        expect(createAlert).toHaveBeenCalledWith(
          expect.objectContaining({ message: expect.stringContaining('Unable to load') }),
        );
      });
    });

    describe('when status is unknown', () => {
      beforeEach(async () => {
        orbitApi.fetchOrbitStatus.mockResolvedValue({
          data: { status: 'unknown', version: '-', components: [] },
        });
        createComponent();
        await waitForPromises();
      });

      it('renders "No connection" badge with danger variant', () => {
        const badge = wrapper.findComponent(GlBadge);
        expect(badge.text()).toBe('No connection');
        expect(badge.props('variant')).toBe('danger');
      });
    });

    describe('when status is unhealthy', () => {
      beforeEach(async () => {
        orbitApi.fetchOrbitStatus.mockResolvedValue({
          data: { status: 'unhealthy', version: '0.5.0', components: [] },
        });
        createComponent();
        await waitForPromises();
      });

      it('renders "Unhealthy" badge', () => {
        const badge = wrapper.findComponent(GlBadge);
        expect(badge.text()).toBe('Unhealthy');
      });
    });

    describe('when components array is empty', () => {
      beforeEach(async () => {
        orbitApi.fetchOrbitStatus.mockResolvedValue({
          data: { status: 'healthy', version: '0.5.0', components: [] },
        });
        createComponent();
        await waitForPromises();
      });

      it('does not render components section', () => {
        expect(wrapper.text()).not.toContain('Components');
        expect(findHealthCards()).toHaveLength(0);
      });
    });
  });

  describe('settings section', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('renders indexes table with namespaces', () => {
      expect(findTable().exists()).toBe(true);
      expect(wrapper.text()).toContain('Test Group');
      expect(wrapper.text()).toContain('Other Group');
    });

    it('renders a toggle for each namespace', () => {
      expect(findToggles()).toHaveLength(2);
    });

    it('calls orbitUpdate mutation when toggle changes', async () => {
      findToggles().at(1).vm.$emit('change', true);
      await waitForPromises();

      expect(mutationHandler).toHaveBeenCalledWith({
        input: {
          groupPath: 'other-group',
          enabled: true,
        },
      });
    });

    it('shows indexing status after enabling a namespace', async () => {
      findToggles().at(1).vm.$emit('change', true);
      await waitForPromises();

      expect(wrapper.text()).toContain('Indexing…');
    });
  });

  describe('settings section error handling', () => {
    it('shows error when mutation returns errors', async () => {
      const errorResponse = {
        data: {
          orbitUpdate: {
            __typename: 'OrbitUpdatePayload',
            group: null,
            errors: ['Permission denied'],
          },
        },
      };
      mutationHandler = jest.fn().mockResolvedValue(errorResponse);
      createComponent();
      await waitForPromises();

      findToggles().at(0).vm.$emit('change', false);
      await waitForPromises();

      expect(createAlert).toHaveBeenCalledWith(
        expect.objectContaining({ message: expect.stringContaining('Failed to update') }),
      );
    });

    it('shows error when mutation network request fails', async () => {
      createComponent();
      await waitForPromises();

      mutationHandler.mockRejectedValue(new Error('Network error'));
      findToggles().at(0).vm.$emit('change', false);
      await waitForPromises();

      expect(createAlert).toHaveBeenCalledWith(
        expect.objectContaining({ message: expect.stringContaining('Failed to update') }),
      );
    });

    it('shows alert when namespace query fails', async () => {
      queryHandler = jest.fn().mockRejectedValue(new Error('fail'));
      createComponent();
      await waitForPromises();

      expect(createAlert).toHaveBeenCalledWith(
        expect.objectContaining({ message: expect.stringContaining('Failed to load') }),
      );
    });
  });

  describe('tools section', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('renders tool cards from fetchOrbitTools API', () => {
      expect(orbitApi.fetchOrbitTools).toHaveBeenCalled();
      const cards = findToolCards();
      expect(cards).toHaveLength(2);
    });

    it('passes sample prompts to tool cards', () => {
      const cards = findToolCards();
      expect(cards.at(0).props('samplePrompt')).toBe('What issues are blocking the login feature?');
    });

    it('does not render tools section when tools API fails', async () => {
      orbitApi.fetchOrbitTools.mockRejectedValue(new Error('fail'));
      createComponent();
      await waitForPromises();

      expect(wrapper.text()).not.toContain('Tools');
      expect(findToolCards()).toHaveLength(0);
    });
  });
});
