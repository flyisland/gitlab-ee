import { GlLink } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AgentSessionInboxItem from 'ee/ai/duo_agents_platform/panel/agent_session_inbox_item.vue';
import AgentStatusIcon from 'ee/ai/shared/widgets/agent_status_icon.vue';
import { AGENTS_PLATFORM_SHOW_ROUTE } from 'ee/ai/duo_agents_platform/router/constants';
import { buildInboxRowItem } from '../../mocks';

describe('AgentSessionInboxItem', () => {
  let wrapper;
  let mockRouter;

  beforeEach(() => {
    mockRouter = { push: jest.fn() };
  });

  const createWrapper = (item = buildInboxRowItem()) => {
    wrapper = shallowMountExtended(AgentSessionInboxItem, {
      propsData: { item },
      mocks: { $router: mockRouter },
    });
  };

  const findLink = () => wrapper.findComponent(GlLink);
  const findStatusIcon = () => wrapper.findComponent(AgentStatusIcon);
  const findStatusLabel = () => wrapper.findByTestId('item-status-label');
  const findTitle = () => wrapper.findByTestId('item-title');
  const findUpdatedDate = () => wrapper.findComponentByTestId('item-updated-date');
  const findMetadata = () => wrapper.findByTestId('item-metadata');

  describe('status label overrides', () => {
    it.each([
      ['INPUT_REQUIRED', 'Waiting for input'],
      ['PLAN_APPROVAL_REQUIRED', 'Approval gate'],
      ['TOOL_CALL_APPROVAL_REQUIRED', 'Confirm action'],
      ['STOPPED', 'Canceled'],
    ])('renders the renamed label for %s', (status, expectedLabel) => {
      createWrapper(buildInboxRowItem({ status, humanStatus: status.toLowerCase() }));

      expect(findStatusLabel().text()).toBe(expectedLabel);
    });

    it('falls through to formatAgentStatus(humanStatus) for an unmapped status', () => {
      createWrapper(buildInboxRowItem({ status: 'RUNNING', humanStatus: 'running' }));

      expect(findStatusLabel().text()).toBe('Running');
    });

    it('renders "Unknown" for an unmapped status with a null humanStatus', () => {
      createWrapper(buildInboxRowItem({ status: 'RUNNING', humanStatus: null }));

      expect(findStatusLabel().text()).toBe('Unknown');
    });

    it('passes the resolved label to AgentStatusIcon so the aria-label matches visible text', () => {
      createWrapper(buildInboxRowItem({ status: 'INPUT_REQUIRED', humanStatus: 'input required' }));

      expect(findStatusIcon().props('humanStatus')).toBe('Waiting for input');
    });
  });

  describe('status colour (semantic token)', () => {
    it.each([
      ['CREATED', 'gl-text-status-neutral'],
      ['RUNNING', 'gl-text-status-info'],
      ['FINISHED', 'gl-text-status-success'],
      ['PAUSED', 'gl-text-status-neutral'],
      ['STOPPED', 'gl-text-status-danger'],
      ['INPUT_REQUIRED', 'gl-text-status-warning'],
      ['PLAN_APPROVAL_REQUIRED', 'gl-text-status-warning'],
      ['TOOL_CALL_APPROVAL_REQUIRED', 'gl-text-status-warning'],
      ['FAILED', 'gl-text-status-danger'],
      ['UNKNOWN_FUTURE_STATUS', 'gl-text-status-neutral'],
    ])('applies %s → %s', (status, expectedClass) => {
      createWrapper(buildInboxRowItem({ status }));

      expect(findStatusLabel().classes()).toContain(expectedClass);
    });
  });

  describe('row content', () => {
    beforeEach(() => createWrapper());

    it('renders the session title', () => {
      expect(findTitle().text()).toBe('Fix the login bug');
    });

    it('tooltips the title with its session ID', () => {
      expect(findTitle().attributes('title')).toBe('Fix the login bug #42');
    });

    it('renders the age as a TimeAgoTooltip', () => {
      expect(findUpdatedDate().props('time')).toBe('2024-01-01T00:00:00Z');
    });

    it('renders the metadata line with numeric ID, flow name, and project name', () => {
      const text = findMetadata().text();

      expect(text).toContain('42');
      expect(text).toContain('Software development');
      expect(text).toContain('Test Project');
    });
  });

  describe('when project is null', () => {
    beforeEach(() => createWrapper(buildInboxRowItem({ project: null })));

    it('renders the metadata line without the project name, and does not throw', () => {
      expect(findMetadata().exists()).toBe(true);
    });
  });

  describe.each([null, ''])('when the title is %p', (title) => {
    beforeEach(() => createWrapper(buildInboxRowItem({ title })));

    it('renders no title text', () => {
      expect(findTitle().text()).toBe('');
    });

    it('tooltips the session ID alone, rather than interpolating the empty title', () => {
      expect(findTitle().attributes('title')).toBe('#42');
    });
  });

  describe('navigation', () => {
    beforeEach(() => createWrapper());

    it('calls preventDefault and router.push on a plain click', async () => {
      const event = { metaKey: false, ctrlKey: false, shiftKey: false, preventDefault: jest.fn() };
      await findLink().vm.$emit('click', event);

      expect(event.preventDefault).toHaveBeenCalledTimes(1);
      expect(mockRouter.push).toHaveBeenCalledWith({
        name: AGENTS_PLATFORM_SHOW_ROUTE,
        params: { id: 42 },
      });
    });

    describe.each(['metaKey', 'ctrlKey', 'shiftKey'])('when %s is pressed', (modifier) => {
      let event;

      beforeEach(async () => {
        event = {
          metaKey: false,
          ctrlKey: false,
          shiftKey: false,
          [modifier]: true,
          preventDefault: jest.fn(),
        };
        await findLink().vm.$emit('click', event);
      });

      it('leaves the default alone, so the browser opens the href in a new tab', () => {
        expect(event.preventDefault).not.toHaveBeenCalled();
      });

      it('does not navigate inside the panel', () => {
        expect(mockRouter.push).not.toHaveBeenCalled();
      });
    });
  });
});
