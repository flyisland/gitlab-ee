import { GlSkeletonLoader } from '@gitlab/ui';
import AgentSessionInboxTab from 'ee/ai/duo_agents_platform/panel/agent_session_inbox_tab.vue';
import AgentFlowList from 'ee/ai/duo_agents_platform/components/common/agent_flow_list.vue';
import AgentSessionInboxItem from 'ee/ai/duo_agents_platform/panel/agent_session_inbox_item.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { mockAgentFlows, mockInboxPageInfo } from '../../mocks';

describe('AgentSessionInboxTab', () => {
  let wrapper;

  const SLOTTED_EMPTY_STATE = {
    'empty-state': '<div data-testid="slotted-empty-state">Nothing here</div>',
  };

  const createWrapper = ({ slots = SLOTTED_EMPTY_STATE, ...props } = {}) => {
    wrapper = shallowMountExtended(AgentSessionInboxTab, {
      propsData: {
        testidPrefix: 'needs-decision',
        workflows: mockAgentFlows,
        pageInfo: mockInboxPageInfo,
        ...props,
      },
      slots,
      stubs: { AgentFlowList },
    });
  };

  const findList = () => wrapper.findComponent(AgentFlowList);
  const findSlottedEmptyState = () => wrapper.findByTestId('slotted-empty-state');

  describe('when loading', () => {
    beforeEach(() => createWrapper({ loading: true }));

    it('renders skeletons under a testid derived from the prefix', () => {
      expect(wrapper.findByTestId('needs-decision-loading').exists()).toBe(true);
      expect(wrapper.findAllComponents(GlSkeletonLoader)).toHaveLength(3);
    });

    it('renders neither the list nor the empty state', () => {
      expect(findList().exists()).toBe(false);
      expect(findSlottedEmptyState().exists()).toBe(false);
    });
  });

  describe('when empty and the tab supplies its own empty state', () => {
    beforeEach(() => createWrapper({ showEmptyState: true, workflows: [] }));

    it('renders the slot instead of the list', () => {
      expect(findSlottedEmptyState().exists()).toBe(true);
      expect(findList().exists()).toBe(false);
    });
  });

  describe('when empty and the tab supplies no empty state', () => {
    beforeEach(() =>
      createWrapper({ testidPrefix: 'all', workflows: [], showEmptyState: true, slots: {} }),
    );

    it("falls back to the list's own empty state", () => {
      expect(findList().props('showEmptyState')).toBe(true);
      expect(findSlottedEmptyState().exists()).toBe(false);
    });
  });

  describe('when there are sessions to show', () => {
    beforeEach(() => createWrapper());

    it('forwards the list props, including a prefixed testid', () => {
      expect(wrapper.findComponentByTestId('needs-decision-flow-list').exists()).toBe(true);
      expect(findList().props()).toMatchObject({
        workflows: mockAgentFlows,
        workflowsPageInfo: mockInboxPageInfo,
        showEmptyState: false,
      });
      expect(findList().props('showProjectInfo')).toBe(false);
    });

    it('renders one redesigned row per workflow, with the workflow bound', () => {
      const rows = wrapper.findAllComponents(AgentSessionInboxItem);

      expect(rows).toHaveLength(mockAgentFlows.length);
      expect(rows.at(0).props('item')).toEqual(mockAgentFlows[0]);
    });

    it.each(['next-page', 'prev-page'])('re-emits %s from the list', async (event) => {
      await findList().vm.$emit(event);

      expect(wrapper.emitted(event)).toHaveLength(1);
    });
  });
});
