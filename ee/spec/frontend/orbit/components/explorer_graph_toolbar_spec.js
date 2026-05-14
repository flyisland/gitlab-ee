import { shallowMount } from '@vue/test-utils';
import ExplorerGraphToolbar from 'ee/orbit/components/explorer_graph_toolbar.vue';

describe('ExplorerGraphToolbar', () => {
  let wrapper;

  const defaultProps = {
    searchQuery: '',
    dimensionMode: '3d',
  };

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(ExplorerGraphToolbar, {
      propsData: { ...defaultProps, ...props },
    });
  };

  const findSearchInput = () => wrapper.find('[data-testid="graph-search-input"]');
  const findExpandBtn = () => wrapper.find('[data-testid="graph-expand-btn"]');
  const findDimensionSelect = () => wrapper.find('[data-testid="dimension-select"]');

  describe('rendering', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('renders search input', () => {
      expect(findSearchInput().exists()).toBe(true);
    });

    it('renders expand button', () => {
      expect(findExpandBtn().exists()).toBe(true);
    });

    it('renders dimension dropdown', () => {
      expect(findDimensionSelect().exists()).toBe(true);
    });
  });

  describe('events', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('emits toggle-expand on expand button click', () => {
      findExpandBtn().vm.$emit('click');

      expect(wrapper.emitted('toggle-expand')).toHaveLength(1);
    });

    it('emits select-dimension on dimension selection', () => {
      findDimensionSelect().vm.$emit('select', '2d');

      expect(wrapper.emitted('select-dimension')[0]).toEqual(['2d']);
    });
  });

  describe('expand state', () => {
    it('shows maximize icon when not expanded', () => {
      createWrapper({ expanded: false });

      expect(findExpandBtn().attributes('icon')).toBe('maximize');
    });

    it('shows minimize icon when expanded', () => {
      createWrapper({ expanded: true });

      expect(findExpandBtn().attributes('icon')).toBe('minimize');
    });
  });
});
