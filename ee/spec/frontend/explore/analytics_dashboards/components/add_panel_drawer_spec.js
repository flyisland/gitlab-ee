import { GlDrawer } from '@gitlab/ui';
import { nextTick } from 'vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AddPanelDrawer from 'ee/explore/analytics_dashboards/components/add_panel_drawer.vue';
import DataExplorer from 'ee/vue_shared/components/data_explorer/data_explorer.vue';

jest.mock('~/lib/utils/dom_utils', () => ({
  getContentWrapperHeight: () => '123',
}));

describe('AddPanelDrawer', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(AddPanelDrawer, {
      propsData: {
        open: false,
        ...props,
      },
    });
  };

  const findDrawer = () => wrapper.findComponent(GlDrawer);
  const findDataExplorer = () => wrapper.findComponent(DataExplorer);
  const findAddToDashboardButton = () => wrapper.findByTestId('add-to-dashboard-button');
  const findAddToDashboardTooltip = () => wrapper.findByTestId('add-to-dashboard-tooltip');
  const findCancelButton = () => wrapper.findByTestId('add-panel-cancel-button');

  const inputQuery = (query) => findDataExplorer().vm.$emit('input', query);
  const submitQuery = (query) => findDataExplorer().vm.$emit('submit', query);

  beforeEach(() => {
    createComponent();
  });

  it('renders the drawer with the correct header height', () => {
    expect(findDrawer().exists()).toBe(true);
    expect(findDrawer().props('headerHeight')).toBe('123');
  });

  it('passes the open prop through to the drawer', () => {
    createComponent({ open: true });

    expect(findDrawer().props('open')).toBe(true);
  });

  it('renders the data explorer in the drawer body', () => {
    expect(findDataExplorer().exists()).toBe(true);
  });

  it('binds the working query to the data explorer', async () => {
    expect(findDataExplorer().props('query')).toBe('');

    inputQuery('type = Issue');
    await nextTick();

    expect(findDataExplorer().props('query')).toBe('type = Issue');
  });

  describe('actions', () => {
    it('renders the "Add to dashboard" button', () => {
      expect(findAddToDashboardButton().exists()).toBe(true);
      expect(findAddToDashboardButton().text()).toBe('Add to dashboard');
    });

    it('renders the "Cancel" button', () => {
      expect(findCancelButton().exists()).toBe(true);
      expect(findCancelButton().text()).toBe('Cancel');
    });

    it('emits close when the cancel button is clicked', () => {
      findCancelButton().vm.$emit('click');

      expect(wrapper.emitted('close')).toHaveLength(1);
    });
  });

  describe('"Add to dashboard" button state', () => {
    it('is disabled with a prompt to run a query when the query is blank', () => {
      expect(findAddToDashboardButton().props('disabled')).toBe(true);
      expect(findAddToDashboardTooltip().attributes('title')).toBe(
        'Enter and run a query to add it to the dashboard.',
      );
    });

    it('is disabled with a pending-changes message when the query has not been run', async () => {
      inputQuery('type = Issue');
      await nextTick();

      expect(findAddToDashboardButton().props('disabled')).toBe(true);
      expect(findAddToDashboardTooltip().attributes('title')).toBe(
        'You have pending changes. Run the query to add the latest version to the dashboard.',
      );
    });

    it('is enabled with no tooltip once the current query has been run', async () => {
      inputQuery('type = Issue');
      submitQuery('type = Issue');
      await nextTick();

      expect(findAddToDashboardButton().props('disabled')).toBe(false);
      expect(findAddToDashboardTooltip().attributes('title')).toBe('');
    });

    it('becomes disabled again when the query is edited after being run', async () => {
      inputQuery('type = Issue');
      submitQuery('type = Issue');
      await nextTick();

      inputQuery('type = MergeRequest');
      await nextTick();

      expect(findAddToDashboardButton().props('disabled')).toBe(true);
    });
  });

  describe('when the "Add to dashboard" button is clicked', () => {
    it('emits add-panel with the submitted query wrapped in a visualization', async () => {
      const query = '      type = Issue AND state = opened \n ';

      inputQuery(query);
      submitQuery(query);
      await nextTick();

      findAddToDashboardButton().vm.$emit('click');

      expect(wrapper.emitted('add-panel')).toEqual([
        [
          {
            type: 'Glql',
            options: {},
            data: {
              type: 'glql',
              query: {
                glql: 'type = Issue AND state = opened',
              },
            },
          },
        ],
      ]);
    });
  });

  it('emits close when the drawer is closed', () => {
    findDrawer().vm.$emit('close');

    expect(wrapper.emitted('close')).toHaveLength(1);
  });
});
