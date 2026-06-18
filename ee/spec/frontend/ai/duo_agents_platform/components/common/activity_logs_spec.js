import { shallowMount } from '@vue/test-utils';
import { GlIcon } from '@gitlab/ui';
import ActivityLogs from 'ee/ai/duo_agents_platform/components/common/activity_logs.vue';
import DelegationEntry from 'ee/ai/duo_agents_platform/components/common/delegation_entry.vue';
import LogEntry from 'ee/ai/duo_agents_platform/components/common/log_entry.vue';
import {
  MESSAGE_SUB_TYPE_DELEGATION,
  MESSAGE_SUB_TYPE_DELEGATION_RETURNS,
} from 'ee/ai/duo_agents_platform/constants';
import { getTimeago } from '~/lib/utils/datetime_utility';
import { mockItems, mockMixedItemsWithDelegation } from './mock';

jest.mock('~/lib/utils/datetime_utility');

describe('ActivityLogs', () => {
  let wrapper;

  const findAllListItems = () => wrapper.findAll('li');
  const findAllIcons = () => wrapper.findAllComponents(GlIcon);
  const findAllLogEntries = () => wrapper.findAllComponents(LogEntry);
  const findAllDelegationEntries = () => wrapper.findAllComponents(DelegationEntry);
  const findAllIconWrappers = () => wrapper.findAll('[data-testid="activity-log-icon-wrapper"]');

  const mockTimeago = {
    format: jest.fn(),
  };

  const createWrapper = (props = {}) => {
    return shallowMount(ActivityLogs, {
      propsData: {
        items: mockItems,
        canResumeWorkflow: false,
        canUpdateWorkflow: false,
        ...props,
      },
    });
  };

  beforeEach(() => {
    getTimeago.mockReturnValue(mockTimeago);
    mockTimeago.format.mockReturnValue('2 minutes ago');
  });

  describe('props validation', () => {
    describe('when an item has empty string content', () => {
      let consoleErrorSpy;

      beforeEach(() => {
        consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
        wrapper = createWrapper({
          items: [
            {
              id: 99,
              content: '',
              messageType: 'tool',
              status: 'success',
              timestamp: '2023-01-01T10:20:00Z',
            },
          ],
        });
      });

      afterEach(() => {
        consoleErrorSpy.mockRestore();
      });

      it('mounts without logging a validator failure', () => {
        expect(wrapper.exists()).toBe(true);
        expect(consoleErrorSpy).not.toHaveBeenCalled();
      });
    });
  });

  describe('LogEntry component integration', () => {
    beforeEach(() => {
      wrapper = createWrapper();
    });

    it('renders LogEntry for each item', () => {
      expect(findAllLogEntries()).toHaveLength(3);
    });

    it('passes correct props to first LogEntry', () => {
      expect(findAllLogEntries().at(0).props()).toMatchObject({
        item: mockItems[0],
        index: 0,
        last: false,
        canResumeWorkflow: false,
        canUpdateWorkflow: false,
      });
    });

    it('passes correct props to second LogEntry', () => {
      expect(findAllLogEntries().at(1).props()).toMatchObject({
        item: mockItems[1],
        index: 1,
        last: false,
        canResumeWorkflow: false,
        canUpdateWorkflow: false,
      });
    });

    it('passes correct props to third LogEntry', () => {
      expect(findAllLogEntries().at(2).props()).toMatchObject({
        item: mockItems[2],
        index: 2,
        last: true,
        canResumeWorkflow: false,
        canUpdateWorkflow: false,
      });
    });
  });

  describe('list rendering', () => {
    beforeEach(() => {
      wrapper = createWrapper();
    });

    it('renders correct number of list items', () => {
      expect(findAllListItems()).toHaveLength(3);
    });

    it('updates list when items prop changes', async () => {
      expect(findAllListItems()).toHaveLength(3);

      const newItems = [
        ...mockItems,
        {
          id: 4,
          content: 'New item',
          messageType: 'tool',
          status: 'success',
          timestamp: '2023-01-01T10:15:00Z',
        },
      ];

      await wrapper.setProps({ items: newItems });

      expect(findAllListItems()).toHaveLength(4);
      expect(findAllLogEntries()).toHaveLength(4);
    });
  });

  describe('when component is mounted', () => {
    beforeEach(() => {
      wrapper = createWrapper();
    });

    it('renders correct number of icons', () => {
      expect(findAllIcons()).toHaveLength(3);
    });

    it('assigns play icon to first item', () => {
      expect(findAllIcons().at(0).props('name')).toBe('play');
    });
  });

  describe('delegation routing', () => {
    beforeEach(() => {
      wrapper = createWrapper({ items: mockMixedItemsWithDelegation });
    });

    it('renders DelegationEntry for delegation/return items and LogEntry for regular items', () => {
      expect(findAllListItems()).toHaveLength(5);
      expect(findAllDelegationEntries()).toHaveLength(3);
      expect(findAllLogEntries()).toHaveLength(2);
    });

    it('renders flat icon wrapper for delegation items', () => {
      // items[1] = delegation, items[2] = return, items[4] = failure return
      expect(findAllIconWrappers().at(1).classes()).not.toContain('gl-rounded-full');
      expect(findAllIconWrappers().at(2).classes()).not.toContain('gl-rounded-full');
      expect(findAllIconWrappers().at(4).classes()).not.toContain('gl-rounded-full');
    });

    it('keeps circle icon wrapper for regular items', () => {
      // items[0] and items[3] are regular tool entries
      expect(findAllIconWrappers().at(0).classes()).toContain('gl-rounded-full');
      expect(findAllIconWrappers().at(3).classes()).toContain('gl-rounded-full');
    });
  });

  describe('subagent indentation', () => {
    const itemsWithNesting = [
      mockItems[0], // index 0: top-level (depth 0)
      {
        // index 1: delegation (depth 0, children get depth 1)
        id: 201,
        content: '',
        messageType: 'agent',
        messageSubType: MESSAGE_SUB_TYPE_DELEGATION,
        status: 'success',
        timestamp: '2023-01-01T10:01:00Z',
        componentName: 'supervisor',
        toolInfo: JSON.stringify({
          name: 'delegate_task',
          args: { subagent_name: 'developer', subsession_id: 1, prompt: 'fix it' },
        }),
      },
      {
        // index 2: subagent tool action (depth 1 — indented)
        id: 202,
        content: 'Read file',
        messageType: 'tool',
        status: 'success',
        timestamp: '2023-01-01T10:02:00Z',
        componentName: 'developer',
        subsessionId: '1',
      },
      {
        // index 3: subagent tool action (depth 1 — indented)
        id: 203,
        content: 'Edit file',
        messageType: 'tool',
        status: 'success',
        timestamp: '2023-01-01T10:03:00Z',
        componentName: 'developer',
        subsessionId: '1',
      },
      {
        // index 4: return (depth 0)
        id: 204,
        content: 'Done',
        messageType: 'agent',
        messageSubType: MESSAGE_SUB_TYPE_DELEGATION_RETURNS,
        status: 'success',
        timestamp: '2023-01-01T10:04:00Z',
        componentName: 'developer',
        subsessionId: '1',
      },
      {
        // index 5: back to top-level (depth 0)
        id: 205,
        content: 'Create MR',
        messageType: 'tool',
        status: 'success',
        timestamp: '2023-01-01T10:05:00Z',
        componentName: 'supervisor',
      },
    ];

    beforeEach(() => {
      wrapper = createWrapper({ items: itemsWithNesting });
    });

    it('does not indent top-level entries', () => {
      const items = findAllListItems();

      expect(items.at(0).classes()).not.toContain('gl-pl-8');
      expect(items.at(1).classes()).not.toContain('gl-pl-8');
      expect(items.at(5).classes()).not.toContain('gl-pl-8');
    });

    it('indents entries between delegation and return with gl-pl-8', () => {
      const items = findAllListItems();

      expect(items.at(2).classes()).toContain('gl-pl-8');
      expect(items.at(3).classes()).toContain('gl-pl-8');
    });

    it('does not indent the return entry itself', () => {
      const items = findAllListItems();

      expect(items.at(4).classes()).not.toContain('gl-pl-8');
    });
  });

  describe('subagent indentation at depth 2', () => {
    const itemsWithDeepNesting = [
      mockItems[0], // index 0: top-level (depth 0)
      {
        // index 1: outer delegation (depth 0 → depth becomes 1)
        id: 301,
        content: '',
        messageType: 'agent',
        messageSubType: MESSAGE_SUB_TYPE_DELEGATION,
        status: 'success',
        timestamp: '2023-01-01T10:01:00Z',
        componentName: 'supervisor',
        toolInfo: JSON.stringify({
          name: 'delegate_task',
          args: { subagent_name: 'developer', subsession_id: 1, prompt: 'do it' },
        }),
      },
      {
        // index 2: inner delegation (depth 1 → depth becomes 2)
        id: 302,
        content: '',
        messageType: 'agent',
        messageSubType: MESSAGE_SUB_TYPE_DELEGATION,
        status: 'success',
        timestamp: '2023-01-01T10:02:00Z',
        componentName: 'developer',
        toolInfo: JSON.stringify({
          name: 'delegate_task',
          args: { subagent_name: 'researcher', subsession_id: 2, prompt: 'research' },
        }),
      },
      {
        // index 3: deeply nested tool action (depth 2)
        id: 303,
        content: 'Search docs',
        messageType: 'tool',
        status: 'success',
        timestamp: '2023-01-01T10:03:00Z',
        componentName: 'researcher',
        subsessionId: '2',
      },
      {
        // index 4: inner return (depth 1)
        id: 304,
        content: 'Research done',
        messageType: 'agent',
        messageSubType: MESSAGE_SUB_TYPE_DELEGATION_RETURNS,
        status: 'success',
        timestamp: '2023-01-01T10:04:00Z',
        componentName: 'researcher',
        subsessionId: '2',
      },
      {
        // index 5: outer return (depth 0)
        id: 305,
        content: 'Done',
        messageType: 'agent',
        messageSubType: MESSAGE_SUB_TYPE_DELEGATION_RETURNS,
        status: 'success',
        timestamp: '2023-01-01T10:05:00Z',
        componentName: 'developer',
        subsessionId: '1',
      },
    ];

    beforeEach(() => {
      wrapper = createWrapper({ items: itemsWithDeepNesting });
    });

    it('indents nested subagent entries at depth 2 with gl-pl-16', () => {
      const items = findAllListItems();

      expect(items.at(3).classes()).toContain('gl-pl-16');
    });

    it('indents depth-1 entries with gl-pl-8', () => {
      const items = findAllListItems();

      expect(items.at(2).classes()).toContain('gl-pl-8');
    });

    it('does not indent the top-level and outermost return entries', () => {
      const items = findAllListItems();

      // index 0: top-level (depth 0)
      expect(items.at(0).classes()).not.toContain('gl-pl-8');
      expect(items.at(0).classes()).not.toContain('gl-pl-16');
      // index 5: outer return (depth 0 after decrement from 1)
      expect(items.at(5).classes()).not.toContain('gl-pl-8');
      expect(items.at(5).classes()).not.toContain('gl-pl-16');
    });

    it('indents the inner return at depth 1 with gl-pl-8', () => {
      const items = findAllListItems();

      // index 4: inner return gets depth max(0, 2-1)=1
      expect(items.at(4).classes()).toContain('gl-pl-8');
    });
  });

  describe('when items change', () => {
    beforeEach(() => {
      wrapper = createWrapper();
    });

    it('update the props passed to the SVG component', async () => {
      expect(findAllListItems()).toHaveLength(3);

      const newItems = [
        {
          id: 5,
          content: 'Another new item',
          messageType: 'assistant',
          status: 'success',
          timestamp: '2023-01-01T10:20:00Z',
        },
      ];

      await wrapper.setProps({ items: newItems });

      expect(findAllListItems()).toHaveLength(1);
    });
  });
});
