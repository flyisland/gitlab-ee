import { GlIcon, GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import AgentFlowEmptyState from 'ee/ai/duo_agents_platform/components/common/agent_flow_empty_state.vue';
import AgentFlowTriggeredUser from 'ee/ai/duo_agents_platform/components/common/agent_flow_triggered_user.vue';
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
        TimeAgoTooltip: true,
      },
    });
  };

  const findRetentionMessage = () => wrapper.find('[data-testid="retention-message-container"]');
  const findEmptyStateList = () => wrapper.find('ul');
  const findListItems = () => wrapper.findAll('li');
  const findIcons = () => wrapper.findAllComponents(GlIcon);
  const findTimeAgoTooltips = () => wrapper.findAllComponents(TimeAgoTooltip);
  const findTriggeredUser = () => wrapper.findComponent(AgentFlowTriggeredUser);
  const findLearnMoreLink = () => wrapper.findComponent(GlLink);

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
      state                 | hasLogs  | status       | itemCount | index | text                  | icon                | variant     | timestamp
      ${'creating session'} | ${false} | ${''}        | ${1}      | ${0}  | ${'Creating session'} | ${'status_running'} | ${'subtle'} | ${defaultProps.createdAt}
      ${'created session'}  | ${true}  | ${'SUCCESS'} | ${1}      | ${0}  | ${'Created session'}  | ${'status_success'} | ${'subtle'} | ${defaultProps.createdAt}
      ${'starting job'}     | ${false} | ${'RUNNING'} | ${2}      | ${1}  | ${'Starting job'}     | ${'status_running'} | ${'subtle'} | ${defaultProps.createdAt}
      ${'session failed'}   | ${false} | ${'FAILED'}  | ${2}      | ${1}  | ${'Session failed'}   | ${'status_failed'}  | ${'danger'} | ${defaultProps.updatedAt}
    `('$state state', ({ hasLogs, status, itemCount, index, text, icon, variant, timestamp }) => {
      beforeEach(() => {
        createComponent({ hasLogs, status });
      });

      it(`displays ${itemCount} item(s)`, () => {
        expect(findListItems()).toHaveLength(itemCount);
      });

      it('displays correct text', () => {
        expect(findListItems().at(index).text()).toContain(text);
      });

      it('displays correct icon and variant', () => {
        expect(findIcons().at(index).props()).toMatchObject({ name: icon, variant });
      });

      it('displays correct timestamp', () => {
        expect(findTimeAgoTooltips().at(index).props('time')).toBe(timestamp);
      });

      it('displays loading text when provided', () => {
        expect(findTimeAgoTooltips().at(index).props('time')).toBe(timestamp);
      });
    });

    describe('loading text', () => {
      describe.each`
        state                 | hasLogs  | status       | index | loadingText
        ${'creating session'} | ${false} | ${''}        | ${0}  | ${'Takes a few seconds...'}
        ${'starting job'}     | ${false} | ${'RUNNING'} | ${1}  | ${'Takes a few minutes...'}
      `('displays loading text when $state', ({ hasLogs, status, index, loadingText }) => {
        it(`shows "${loadingText}"`, () => {
          createComponent({ hasLogs, status });

          expect(findListItems().at(index).text()).toContain(loadingText);
        });
      });

      describe.each`
        state                | hasLogs  | status       | index
        ${'created session'} | ${true}  | ${'SUCCESS'} | ${0}
        ${'session failed'}  | ${false} | ${'FAILED'}  | ${1}
      `('does not display loading text when $state', ({ hasLogs, status, index }) => {
        it('does not show loading text', () => {
          createComponent({ hasLogs, status });

          expect(findListItems().at(index).text()).not.toContain('Takes a few');
        });
      });
    });

    describe('triggered user', () => {
      describe.each`
        state                | hasLogs  | status
        ${'created session'} | ${true}  | ${'SUCCESS'}
        ${'starting job'}    | ${false} | ${'RUNNING'}
        ${'session failed'}  | ${false} | ${'FAILED'}
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
          expect(findListItems().at(0).text()).not.toContain('by');
        });
      });
    });

    describe('with logs', () => {
      it('only displays created session', () => {
        createComponent({ hasLogs: true, status: 'SUCCESS' });

        expect(findListItems()).toHaveLength(1);
        expect(findListItems().at(0).text()).toContain('Created session');
      });
    });
  });
});
