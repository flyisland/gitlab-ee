import { GlAvatar, GlLink, GlSkeletonLoader } from '@gitlab/ui';
import VueApollo from 'vue-apollo';
import Vue from 'vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { useConfigurePathHelpers } from 'helpers/configure_path_helpers';
import AgentSessionRow from 'ee/ai/shared/widgets/agent_session_row.vue';
import AgentStatusIcon from 'ee/ai/shared/widgets/agent_status_icon.vue';
import getUserQuery from 'ee/ai/shared/widgets/graphql/get_user.query.graphql';

Vue.use(VueApollo);

const PROJECT_FULL_PATH = 'namespace/project';
const USER_GID = 'gid://gitlab/User/99';
const MOCK_USER = {
  __typename: 'UserCore',
  id: USER_GID,
  name: 'Jane Doe',
  username: 'janedoe',
  avatarUrl: 'https://gitlab.com/uploads/user/avatar/99/avatar.png',
  webUrl: 'https://gitlab.com/janedoe',
  webPath: '/janedoe',
};

const buildSession = (overrides = {}) => ({
  id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/42',
  status: 'RUNNING',
  humanStatus: 'Running',
  workflowDefinition: 'my_flow',
  updatedAt: '2024-01-15T10:00:00Z',
  userId: USER_GID,
  project: { fullPath: PROJECT_FULL_PATH },
  ...overrides,
});

describe('AgentSessionRow', () => {
  let wrapper;

  useConfigurePathHelpers();

  const createComponent = (
    session,
    getUserHandler = jest.fn().mockResolvedValue({ data: { user: MOCK_USER } }),
  ) => {
    const apolloProvider = createMockApollo([[getUserQuery, getUserHandler]]);
    wrapper = shallowMountExtended(AgentSessionRow, {
      propsData: { session },
      apolloProvider,
    });
  };

  const findStatusIcon = () => wrapper.findComponent(AgentStatusIcon);
  const findDefinition = () => wrapper.findByTestId('session-definition');
  const findSessionId = () => wrapper.findByTestId('session-id');
  const findSessionIdLink = () => wrapper.findComponent(GlLink);
  const findDisplayLabel = () => wrapper.findByTestId('session-display-label');
  const findCtaButton = () => wrapper.findByTestId('session-cta-button');
  const findAvatarLink = () => wrapper.findByTestId('session-triggered-user');
  const findAvatar = () => wrapper.findComponent(GlAvatar);
  const findSkeletonLoader = () => wrapper.findComponent(GlSkeletonLoader);

  describe('status icon', () => {
    it('passes status and humanStatus to AgentStatusIcon', () => {
      createComponent(buildSession({ status: 'PAUSED', humanStatus: 'Paused' }));

      expect(findStatusIcon().props('status')).toBe('PAUSED');
      expect(findStatusIcon().props('humanStatus')).toBe('Paused');
    });
  });

  describe('session ID', () => {
    it('renders the numeric id as a link when project fullPath is available', () => {
      createComponent(buildSession());

      expect(findSessionIdLink().text()).toBe('#42');
    });

    it('renders the id as plain text when project fullPath is not available', () => {
      createComponent(buildSession({ project: null }));

      expect(findSessionIdLink().exists()).toBe(false);
      expect(findSessionId().text()).toBe('#42');
    });
  });

  describe('workflow definition', () => {
    it('humanizes the workflowDefinition', () => {
      createComponent(buildSession({ workflowDefinition: 'my_flow' }));

      expect(findDefinition().text()).toBe('My flow');
    });
  });

  describe('display label', () => {
    it.each(['INPUT_REQUIRED', 'PLAN_APPROVAL_REQUIRED', 'TOOL_CALL_APPROVAL_REQUIRED'])(
      'shows "Awaiting your input" for %s',
      (status) => {
        createComponent(buildSession({ status }));

        expect(findDisplayLabel().text()).toBe('Awaiting your input');
      },
    );

    it('shows humanStatus for non-awaiting-input statuses', () => {
      createComponent(buildSession({ status: 'RUNNING', humanStatus: 'Running' }));

      expect(findDisplayLabel().text()).toBe('Running');
    });
  });

  describe('CTA button', () => {
    it.each(['INPUT_REQUIRED', 'PLAN_APPROVAL_REQUIRED', 'TOOL_CALL_APPROVAL_REQUIRED'])(
      'renders with confirm/secondary style when sessionUrl is available and status is %s',
      (status) => {
        createComponent(buildSession({ status }));

        expect(findCtaButton().exists()).toBe(true);
        expect(findCtaButton().text()).toBe('View details');
        expect(findCtaButton().attributes('variant')).toBe('confirm');
        expect(findCtaButton().attributes('category')).toBe('tertiary');
      },
    );

    it('links to the session URL when awaiting input', () => {
      createComponent(buildSession({ status: 'INPUT_REQUIRED' }));

      expect(findCtaButton().attributes('href')).toContain(PROJECT_FULL_PATH);
    });

    it('does not render when project fullPath is absent', () => {
      createComponent(buildSession({ project: null, status: 'INPUT_REQUIRED' }));

      expect(findCtaButton().exists()).toBe(false);
    });

    it('does not render when session is not awaiting input', () => {
      createComponent(buildSession({ status: 'RUNNING' }));

      expect(findCtaButton().exists()).toBe(false);
    });
  });

  describe('user avatar', () => {
    it('shows a skeleton loader while the user is being fetched', () => {
      createComponent(buildSession(), jest.fn().mockReturnValue(new Promise(() => {})));

      expect(findSkeletonLoader().exists()).toBe(true);
      expect(findAvatarLink().exists()).toBe(false);
    });

    it('renders GlAvatarLink with the correct attributes once loaded', async () => {
      createComponent(buildSession());
      await waitForPromises();

      expect(findAvatarLink().attributes('href')).toBe(MOCK_USER.webPath);
      expect(findAvatarLink().attributes('title')).toBe(MOCK_USER.name);
      expect(findAvatarLink().attributes('data-user-id')).toBe('99');
      expect(findAvatarLink().attributes('data-username')).toBe(MOCK_USER.username);
    });

    it('renders GlAvatar with the correct props once loaded', async () => {
      createComponent(buildSession());
      await waitForPromises();

      expect(findAvatar().props('src')).toBe(MOCK_USER.avatarUrl);
      expect(findAvatar().props('entityName')).toBe(MOCK_USER.name);
      expect(findAvatar().props('size')).toBe(16);
    });

    it('does not render when userId is absent', () => {
      createComponent(buildSession({ userId: null }));

      expect(findAvatarLink().exists()).toBe(false);
      expect(findSkeletonLoader().exists()).toBe(false);
    });
  });
});
