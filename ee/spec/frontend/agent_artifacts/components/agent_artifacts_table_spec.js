import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlKeysetPagination, GlTruncate, GlLoadingIcon, GlAlert } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import AgentArtifactsTable from 'ee/agent_artifacts/components/agent_artifacts_table.vue';
import waitForPromises from 'helpers/wait_for_promises';
import { mockAiItems } from '../mock_data';

Vue.use(VueApollo);

describe('AgentArtifactsTable', () => {
  let wrapper;

  const createComponent = ({
    aiItemsResolver = jest.fn().mockReturnValue(mockAiItems),
    filter = {},
  } = {}) => {
    const resolvers = {
      Query: {
        aiItems: aiItemsResolver,
      },
    };

    const apolloProvider = createMockApollo([], resolvers);

    wrapper = mountExtended(AgentArtifactsTable, {
      apolloProvider,
      propsData: {
        filter,
      },
      stubs: {
        GlTruncate,
      },
    });
  };

  const findPagination = () => wrapper.findComponent(GlKeysetPagination);

  describe('when loading', () => {
    beforeEach(() => {
      createComponent({ aiItemsResolver: jest.fn() });
    });

    it('shows the table with busy state', () => {
      expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(true);
    });
  });

  describe('when data is loaded', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('displays ai items', () => {
      const truncate = wrapper.findByTestId('ai-item-name').findComponent(GlTruncate);
      expect(truncate.props('text')).toBe('False Positive Detection');
    });

    it('renders session links', () => {
      const sessionLinks = wrapper.findAllByTestId('session-link');
      expect(sessionLinks).toHaveLength(2);
      expect(sessionLinks.at(0).attributes('href')).toBe(mockAiItems.nodes[0].session.webPath);
      expect(sessionLinks.at(0).text()).toBe('#1908');
    });

    it('displays audit events count', () => {
      const auditCounts = wrapper.findAllByTestId('audit-events-count');
      expect(auditCounts).toHaveLength(2);
      expect(auditCounts.at(0).text()).toBe(`${mockAiItems.nodes[0].auditEvents.count}`);
    });

    it('displays formatted credits', () => {
      const credits = wrapper.findAllByTestId('credits-used');
      expect(credits.at(0).text()).toBe('1,247');
    });

    it('renders project links', () => {
      const { project } = mockAiItems.nodes[0];
      const projectLinks = wrapper.findAllByTestId('project-link');
      expect(projectLinks).toHaveLength(2);
      expect(projectLinks.at(0).attributes('href')).toBe(project.webPath);
      const truncate = projectLinks.at(0).findComponent(GlTruncate);
      expect(truncate.props('text')).toBe(project.name);
    });

    it('displays formatted start time', () => {
      const startTimes = wrapper.findAllByTestId('start-time');
      expect(startTimes).toHaveLength(2);
      expect(startTimes.at(0).text()).toContain('2026-03-05');
      expect(startTimes.at(0).text()).toContain('22:14:17');
    });

    it('displays last message from latestCheckpoint', () => {
      const lastMessages = wrapper.findAllByTestId('ai-item-last-message');
      expect(lastMessages).toHaveLength(2);
      expect(lastMessages.at(0).text()).toBe(
        'Post Duo Code Review to merge request !228929 in project 278964',
      );
      expect(lastMessages.at(1).text()).toBe(
        'Post Duo Code Review to merge request !228931 in project 278965',
      );
    });
  });

  describe('pagination', () => {
    describe('when pages available', () => {
      let aiItemsResolver;

      beforeEach(async () => {
        aiItemsResolver = jest.fn().mockReturnValue(mockAiItems);
        createComponent({ aiItemsResolver });
        await waitForPromises();
      });

      it('renders pagination', () => {
        expect(findPagination().exists()).toBe(true);
      });

      it('fetches next page when pagination emits next', async () => {
        findPagination().vm.$emit('next', mockAiItems.pageInfo.endCursor);
        await waitForPromises();

        expect(aiItemsResolver).toHaveBeenCalledTimes(2);
      });

      it('fetches previous page when pagination emits prev', async () => {
        findPagination().vm.$emit('prev', mockAiItems.pageInfo.startCursor);
        await waitForPromises();

        expect(aiItemsResolver).toHaveBeenCalledTimes(2);
      });
    });

    describe('when no pages available', () => {
      it('does not render pagination', async () => {
        const aiItemsWithoutPages = {
          ...mockAiItems,
          pageInfo: {
            hasNextPage: false,
            hasPreviousPage: false,
          },
        };
        createComponent({
          aiItemsResolver: jest.fn().mockReturnValue(aiItemsWithoutPages),
        });
        await waitForPromises();

        expect(findPagination().exists()).toBe(false);
      });
    });
  });

  describe('empty state', () => {
    beforeEach(async () => {
      const emptyAiItems = {
        count: 0,
        nodes: [],
        pageInfo: {
          hasNextPage: false,
          hasPreviousPage: false,
        },
      };
      createComponent({
        aiItemsResolver: jest.fn().mockReturnValue(emptyAiItems),
      });
      await waitForPromises();
    });

    it('shows empty state message', () => {
      expect(wrapper.text()).toContain('No agent artifacts found.');
    });
  });

  describe('error state', () => {
    beforeEach(async () => {
      createComponent({
        aiItemsResolver: jest.fn().mockRejectedValue(new Error('GraphQL error')),
      });
      await waitForPromises();
    });

    it('shows error alert', () => {
      const alert = wrapper.findComponent(GlAlert);
      expect(alert.exists()).toBe(true);
      expect(alert.text()).toContain('Failed to load agent artifacts.');
    });
  });

  describe('row click handling', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('emits row-click event when a row is clicked', async () => {
      const rows = wrapper.findAllByTestId('agent-artifacts-table-row');
      await rows.at(0).trigger('click');

      expect(wrapper.emitted('row-click')).toHaveLength(1);
      expect(wrapper.emitted('row-click')[0][0]).toEqual(mockAiItems.nodes[0]);
    });
  });

  describe('filtering', () => {
    it('passes filter to GraphQL query', async () => {
      const aiItemsResolver = jest.fn().mockReturnValue(mockAiItems);
      const filter = { name: 'Test Agent' };

      createComponent({ aiItemsResolver, filter });
      await waitForPromises();

      expect(aiItemsResolver).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining(filter),
        expect.anything(),
        expect.anything(),
      );
    });

    it('passes not filter to GraphQL query', async () => {
      const aiItemsResolver = jest.fn().mockReturnValue(mockAiItems);
      const filter = { not: { name: 'Excluded Agent' } };

      createComponent({ aiItemsResolver, filter });
      await waitForPromises();

      expect(aiItemsResolver).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining(filter),
        expect.anything(),
        expect.anything(),
      );
    });

    it('resets pagination when filter changes', async () => {
      const aiItemsResolver = jest.fn().mockReturnValue(mockAiItems);

      createComponent({ aiItemsResolver, filter: { name: 'Initial' } });
      await waitForPromises();

      findPagination().vm.$emit('next', mockAiItems.pageInfo.endCursor);
      await waitForPromises();

      expect(aiItemsResolver).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({ after: mockAiItems.pageInfo.endCursor }),
        expect.anything(),
        expect.anything(),
      );

      await wrapper.setProps({ filter: { name: 'Updated' } });
      await waitForPromises();

      expect(aiItemsResolver).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({ after: null, before: null }),
        expect.anything(),
        expect.anything(),
      );
    });
  });
});
