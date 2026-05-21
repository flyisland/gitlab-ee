import { shallowMount } from '@vue/test-utils';
import { GlIcon } from '@gitlab/ui';
import ActivityLogs from 'ee/ai/duo_agents_platform/components/common/activity_logs.vue';
import LogEntry from 'ee/ai/duo_agents_platform/components/common/log_entry.vue';
import { getTimeago } from '~/lib/utils/datetime_utility';
import { mockItems } from './mock';

jest.mock('~/lib/utils/datetime_utility');

describe('ActivityLogs', () => {
  let wrapper;

  const findAllListItems = () => wrapper.findAll('li');
  const findAllIcons = () => wrapper.findAllComponents(GlIcon);
  const findAllLogEntries = () => wrapper.findAllComponents(LogEntry);

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

  describe('LogEntry component integration', () => {
    beforeEach(() => {
      wrapper = createWrapper();
    });

    it('renders LogEntry for each item', () => {
      expect(findAllLogEntries()).toHaveLength(3);
    });

    it('passes correct props to first LogEntry', () => {
      expect(findAllLogEntries().at(0).props()).toEqual({
        item: mockItems[0],
        index: 0,
        last: false,
        canResumeWorkflow: false,
        canUpdateWorkflow: false,
      });
    });

    it('passes correct props to second LogEntry', () => {
      expect(findAllLogEntries().at(1).props()).toEqual({
        item: mockItems[1],
        index: 1,
        last: false,
        canResumeWorkflow: false,
        canUpdateWorkflow: false,
      });
    });

    it('passes correct props to third LogEntry', () => {
      expect(findAllLogEntries().at(2).props()).toEqual({
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
