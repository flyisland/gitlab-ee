import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import ExplorerTabBar from 'ee/orbit/components/explorer_tab_bar.vue';
import { TAB_GRAPH, TAB_TABLE } from 'ee/orbit/constants';

describe('ExplorerTabBar', () => {
  let wrapper;

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(ExplorerTabBar, {
      propsData: { activeTab: TAB_GRAPH, ...props },
    });
  };

  const findTabButtons = () => wrapper.findAllComponents(GlButton);

  describe('default state', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('renders two tab buttons', () => {
      expect(findTabButtons()).toHaveLength(2);
    });

    it('marks graph tab as selected', () => {
      expect(wrapper.find('[data-testid="tab-graph"]').attributes('selected')).toBe('true');
    });
  });

  describe('when table tab is active', () => {
    beforeEach(() => {
      createWrapper({ activeTab: TAB_TABLE });
    });

    it('marks table tab as selected', () => {
      expect(wrapper.find('[data-testid="tab-table"]').attributes('selected')).toBe('true');
    });
  });

  describe('tab click events', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('emits update:active-tab with TAB_GRAPH when graph tab clicked', () => {
      wrapper.find('[data-testid="tab-graph"]').vm.$emit('click');

      expect(wrapper.emitted('update:active-tab')[0]).toEqual([TAB_GRAPH]);
    });

    it('emits update:active-tab with TAB_TABLE when table tab clicked', () => {
      wrapper.find('[data-testid="tab-table"]').vm.$emit('click');

      expect(wrapper.emitted('update:active-tab')[0]).toEqual([TAB_TABLE]);
    });
  });

  describe('resource links', () => {
    it('does not show resource links by default', () => {
      createWrapper();

      expect(wrapper.find('[data-testid="resource-links-label"]').exists()).toBe(false);
    });

    it('shows resource links when showResourceLinks is true', () => {
      createWrapper({ showResourceLinks: true, learnMorePath: '/docs' });

      expect(wrapper.find('[data-testid="resource-links-label"]').exists()).toBe(true);
    });
  });
});
