import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlAlert, GlKeysetPagination, GlLoadingIcon } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import SessionAuditEventsList from 'ee/agent_artifacts/components/session_audit_events_list.vue';
import waitForPromises from 'helpers/wait_for_promises';

Vue.use(VueApollo);

const MOCK_WORKFLOW_ID = 'gid://gitlab/Ai::DuoWorkflows::Workflow/1';

const mockAuthor = {
  id: 'gid://gitlab/User/1',
  name: 'Scott Hampton',
  username: 'shampton',
  avatarUrl: 'https://gitlab.com/uploads/-/system/user/avatar/1/avatar.png',
  webPath: '/shampton',
  __typename: 'UserCore',
};

const mockAuditEventsData = {
  nodes: [
    {
      id: 'event-1',
      eventType: 'tool_execution',
      createdAt: '2026-05-04T10:30:00Z',
      metadata: { toolName: 'file_write', action: 'created file' },
      author: mockAuthor,
      __typename: 'AuditEvent',
    },
    {
      id: 'event-2',
      eventType: 'tool_execution',
      createdAt: '2026-05-04T10:31:00Z',
      metadata: { toolName: 'read_file', action: 'read file' },
      author: mockAuthor,
      __typename: 'AuditEvent',
    },
  ],
  pageInfo: {
    hasNextPage: false,
    hasPreviousPage: false,
    startCursor: 'event-1',
    endCursor: 'event-2',
    __typename: 'PageInfo',
  },
  __typename: 'AuditEventConnection',
};

describe('SessionAuditEventsList', () => {
  let wrapper;

  const createComponent = ({
    auditEventsResolver = jest.fn().mockReturnValue(mockAuditEventsData),
    sessionId = MOCK_WORKFLOW_ID,
  } = {}) => {
    const resolvers = {
      Query: {
        aiDuoWorkflow: () => ({ id: sessionId, __typename: 'AiDuoWorkflow' }),
      },
      AiDuoWorkflow: {
        auditEvents: auditEventsResolver,
      },
    };

    const apolloProvider = createMockApollo([], resolvers);

    wrapper = mountExtended(SessionAuditEventsList, {
      apolloProvider,
      propsData: {
        sessionId,
      },
    });
  };

  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findAlert = () => wrapper.findComponent(GlAlert);
  const findTimeline = () => wrapper.findByTestId('audit-events-timeline');
  const findEventItems = () => wrapper.findAll('.timeline-entry');
  const findEmptyState = () => wrapper.findByTestId('empty-state');
  const findPagination = () => wrapper.findComponent(GlKeysetPagination);
  const findTitle = () => wrapper.find('h5');

  it('renders the section title', async () => {
    createComponent();
    await waitForPromises();

    expect(findTitle().text()).toBe('Audit events');
  });

  describe('when loading', () => {
    beforeEach(() => {
      createComponent({ auditEventsResolver: jest.fn() });
    });

    it('shows loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(true);
    });

    it('does not show the timeline', () => {
      expect(findTimeline().exists()).toBe(false);
    });

    it('does not show an error alert', () => {
      expect(findAlert().exists()).toBe(false);
    });
  });

  describe('when query errors', () => {
    beforeEach(async () => {
      createComponent({ auditEventsResolver: jest.fn().mockRejectedValue(new Error('failed')) });
      await waitForPromises();
    });

    it('shows an error alert', () => {
      expect(findAlert().exists()).toBe(true);
      expect(findAlert().text()).toBe('Failed to load audit events.');
    });

    it('does not show loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });

    it('does not show the timeline', () => {
      expect(findTimeline().exists()).toBe(false);
    });
  });

  describe('when data is loaded', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('hides loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });

    it('renders the timeline with events', () => {
      expect(findTimeline().exists()).toBe(true);
      expect(findEventItems()).toHaveLength(2);
    });

    it('renders event type for each event', () => {
      const eventTypes = wrapper.findAllByTestId('event-type');
      expect(eventTypes.at(0).text()).toBe('tool_execution');
      expect(eventTypes.at(1).text()).toBe('tool_execution');
    });

    it('renders event date for each event', () => {
      const eventDates = wrapper.findAllByTestId('event-date');
      expect(eventDates.at(0).text()).toContain('2026');
    });

    it('renders author name for each event', () => {
      const authors = wrapper.findAllByTestId('event-author');
      expect(authors.at(0).text()).toBe('Scott Hampton');
    });

    it('renders author link for each event', () => {
      const authors = wrapper.findAllByTestId('event-author');
      expect(authors.at(0).attributes('href')).toBe('/shampton');
    });
  });

  describe('empty state', () => {
    beforeEach(async () => {
      const emptyData = {
        nodes: [],
        pageInfo: {
          hasNextPage: false,
          hasPreviousPage: false,
          startCursor: null,
          endCursor: null,
          __typename: 'PageInfo',
        },
        __typename: 'AuditEventConnection',
      };
      createComponent({ auditEventsResolver: jest.fn().mockReturnValue(emptyData) });
      await waitForPromises();
    });

    it('shows empty state message', () => {
      expect(findEmptyState().exists()).toBe(true);
      expect(findEmptyState().text()).toBe('No audit events found.');
    });

    it('does not show the timeline', () => {
      expect(findTimeline().exists()).toBe(false);
    });
  });

  describe('pagination', () => {
    describe('when pages are available', () => {
      let auditEventsResolver;

      beforeEach(async () => {
        const paginatedData = {
          ...mockAuditEventsData,
          pageInfo: {
            ...mockAuditEventsData.pageInfo,
            hasNextPage: true,
          },
        };
        auditEventsResolver = jest.fn().mockReturnValue(paginatedData);
        createComponent({ auditEventsResolver });
        await waitForPromises();
      });

      it('renders pagination', () => {
        expect(findPagination().exists()).toBe(true);
      });

      it('fetches next page when pagination emits next', async () => {
        findPagination().vm.$emit('next', 'event-2');
        await waitForPromises();

        expect(auditEventsResolver).toHaveBeenCalledTimes(2);
        expect(auditEventsResolver).toHaveBeenLastCalledWith(
          expect.anything(),
          expect.objectContaining({ after: 'event-2' }),
          expect.anything(),
          expect.anything(),
        );
      });

      it('fetches previous page when pagination emits prev', async () => {
        findPagination().vm.$emit('prev', 'event-1');
        await waitForPromises();

        expect(auditEventsResolver).toHaveBeenCalledTimes(2);
        expect(auditEventsResolver).toHaveBeenLastCalledWith(
          expect.anything(),
          expect.objectContaining({ before: 'event-1' }),
          expect.anything(),
          expect.anything(),
        );
      });
    });

    describe('when no pages are available', () => {
      it('does not render pagination', async () => {
        createComponent();
        await waitForPromises();

        expect(findPagination().exists()).toBe(false);
      });
    });
  });
});
