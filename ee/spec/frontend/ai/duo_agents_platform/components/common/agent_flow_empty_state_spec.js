import { GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AgentFlowEmptyState from 'ee/ai/duo_agents_platform/components/common/agent_flow_empty_state.vue';
import AgentFlowTriggeredUser from 'ee/ai/duo_agents_platform/components/common/agent_flow_triggered_user.vue';
import AgentFlowFailedState from 'ee/ai/duo_agents_platform/components/common/agent_flow_failed_state.vue';
import AgentFlowSessionMessage from 'ee/ai/duo_agents_platform/components/common/agent_flow_session_message.vue';
import { AGENT_PLATFORM_SESSION_RETENTION_LENGTH } from 'ee/ai/duo_agents_platform/constants';

describe('AgentFlowEmptyState', () => {
  let wrapper;

  const defaultProps = {
    createdAt: '2024-01-01T00:00:00Z',
    isLoading: false,
    hasLogs: false,
    updatedAt: '2024-01-15T00:00:00Z',
    status: '',
    userId: '123',
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(AgentFlowEmptyState, {
      propsData: { ...defaultProps, ...props },
      stubs: {
        GlSprintf,
        AgentFlowTriggeredUser: true,
        AgentFlowFailedState: true,
        AgentFlowSessionMessage: true,
      },
    });
  };

  const findRetentionMessage = () => wrapper.find('[data-testid="retention-message-container"]');
  const findEmptyStateList = () => wrapper.find('ul');
  const findSessionMessages = () => wrapper.findAllComponents(AgentFlowSessionMessage);
  const findTriggeredUser = () => wrapper.findComponent(AgentFlowTriggeredUser);
  const findLearnMoreLink = () => wrapper.findComponent(GlLink);
  const findFailedState = () => wrapper.findComponent(AgentFlowFailedState);

  describe('retention message', () => {
    beforeEach(() => {
      const oldDate = new Date();
      oldDate.setDate(oldDate.getDate() - (AGENT_PLATFORM_SESSION_RETENTION_LENGTH + 1));

      createComponent({
        updatedAt: oldDate.toISOString(),
        hasLogs: false,
      });
    });

    it('displays retention message when outside retention period and no logs', () => {
      const retentionMessage = findRetentionMessage();
      expect(retentionMessage.exists()).toBe(true);
      expect(retentionMessage.text()).toContain('Activity deleted after 30 days of inactivity');
    });

    it('displays learn more link', () => {
      expect(findRetentionMessage().text()).toContain('Learn more');
      expect(findLearnMoreLink().attributes()).toMatchObject({
        href: expect.stringContaining('sessions'),
        target: '_blank',
      });
    });

    it('does not display empty state list', () => {
      expect(findEmptyStateList().exists()).toBe(false);
    });
  });

  describe('within retention period', () => {
    describe.each`
      state                 | hasLogs  | status       | itemCount | index | text                  | icon                | iconVariant | timestamp
      ${'creating session'} | ${false} | ${''}        | ${1}      | ${0}  | ${'Creating session'} | ${'status_running'} | ${'subtle'} | ${defaultProps.createdAt}
      ${'created session'}  | ${true}  | ${'SUCCESS'} | ${1}      | ${0}  | ${'Created session'}  | ${'status_success'} | ${'subtle'} | ${defaultProps.createdAt}
      ${'starting job'}     | ${false} | ${'RUNNING'} | ${2}      | ${1}  | ${'Starting job'}     | ${'status_running'} | ${'subtle'} | ${defaultProps.createdAt}
    `(
      '$state state',
      ({ hasLogs, status, itemCount, index, text, icon, iconVariant, timestamp }) => {
        beforeEach(() => {
          createComponent({ hasLogs, status });
        });

        it(`renders ${itemCount} AgentFlowSessionMessage(s) with correct props`, () => {
          expect(findSessionMessages()).toHaveLength(itemCount);
          expect(findSessionMessages().at(index).props()).toMatchObject({
            title: text,
            icon,
            iconVariant,
            timestamp,
          });
        });
      },
    );

    describe('session failed state', () => {
      beforeEach(() => {
        createComponent({ hasLogs: false, status: 'FAILED' });
      });

      it('renders AgentFlowFailedState component', () => {
        expect(findFailedState().exists()).toBe(true);
      });

      it('passes correct props to AgentFlowFailedState', () => {
        expect(findFailedState().props('updatedAt')).toBe(defaultProps.updatedAt);
      });

      it('does not render a failed AgentFlowSessionMessage inline', () => {
        expect(findSessionMessages()).toHaveLength(1);
      });
    });

    describe('loading text', () => {
      describe.each`
        state                 | hasLogs  | status       | index | loadingText
        ${'creating session'} | ${false} | ${''}        | ${0}  | ${'Takes a few seconds...'}
        ${'starting job'}     | ${false} | ${'RUNNING'} | ${1}  | ${'Takes a few minutes...'}
      `('displays loading text when $state', ({ hasLogs, status, index, loadingText }) => {
        it(`shows "${loadingText}" in the slot of the message at index ${index}`, () => {
          createComponent({ hasLogs, status });

          expect(findEmptyStateList().text()).toContain(loadingText);
        });
      });

      it('does not show loading text when session is created', () => {
        createComponent({ hasLogs: true, status: 'SUCCESS' });

        expect(findEmptyStateList().text()).not.toContain('Takes a few');
      });
    });

    describe('triggered user', () => {
      describe.each`
        state                | hasLogs  | status
        ${'created session'} | ${true}  | ${'SUCCESS'}
        ${'starting job'}    | ${false} | ${'RUNNING'}
      `('displays triggered user when $state', ({ hasLogs, status }) => {
        beforeEach(() => {
          createComponent({ hasLogs, status });
        });

        it('shows user component with correct props', () => {
          expect(findTriggeredUser().props()).toMatchObject({
            userId: '123',
            isLoading: false,
          });
        });

        it('shows "by" text', () => {
          expect(wrapper.find('[data-testid="triggered-user-container"]').text()).toContain('by');
        });
      });

      describe('does not display triggered user when creating session', () => {
        beforeEach(() => {
          createComponent({ hasLogs: false, status: '' });
        });

        it('does not show user component', () => {
          expect(findTriggeredUser().exists()).toBe(false);
        });

        it('does not show "by" text', () => {
          expect(wrapper.find('ul').text()).not.toContain('by');
        });
      });
    });

    describe('with logs', () => {
      it('only renders one AgentFlowSessionMessage for the created session', () => {
        createComponent({ hasLogs: true, status: 'SUCCESS' });

        expect(findSessionMessages()).toHaveLength(1);
        expect(findSessionMessages().at(0).props('title')).toContain('Created session');
      });
    });
  });
});
