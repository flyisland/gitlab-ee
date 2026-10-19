import { GlButtonGroup } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { VIEW_MODE_LIST, VIEW_MODE_BOARD, VIEW_MODE_TABLE } from '~/work_items/constants';
import WorkItemViewModeToggle from '~/work_items/components/work_item_view_mode_toggle.vue';

// Pin this to the EE view modes regardless of which alias environment the suite runs under
// — the CE/EE difference itself is covered by view_modes_spec.js.
jest.mock('ee_else_ce/work_items/view_modes', () => jest.requireActual('ee/work_items/view_modes'));

describe('WorkItemViewModeToggle (EE)', () => {
  let wrapper;

  const findToggles = () => wrapper.findAllComponents(GlButtonGroup);
  const findIconButton = (viewMode) => wrapper.findComponentByTestId(`view-mode-icon-${viewMode}`);
  const findLabelButton = (viewMode) =>
    wrapper.findComponentByTestId(`view-mode-label-${viewMode}`);

  const createComponent = ({ props = {}, provide = {} } = {}) => {
    wrapper = shallowMountExtended(WorkItemViewModeToggle, {
      propsData: {
        viewMode: VIEW_MODE_LIST,
        ...props,
      },
      provide: {
        glFeatures: { planningViewBoards: true },
        ...provide,
      },
    });
  };

  it('renders the list and board icons when only planningViewBoards is enabled', () => {
    createComponent();

    expect(findToggles()).toHaveLength(2);
    expect(findIconButton(VIEW_MODE_LIST).exists()).toBe(true);
    expect(findIconButton(VIEW_MODE_BOARD).exists()).toBe(true);
    expect(findIconButton(VIEW_MODE_TABLE).exists()).toBe(false);
  });

  it('renders a board icon button labelled for assistive tech', () => {
    createComponent();

    expect(findIconButton(VIEW_MODE_BOARD).props('icon')).toBe('work-item-issue-board');
    expect(findIconButton(VIEW_MODE_BOARD).attributes('aria-label')).toBe('Board');
    expect(findIconButton(VIEW_MODE_BOARD).attributes('title')).toBe('Board');
  });

  it('renders a board label button with text and no icon', () => {
    createComponent();

    expect(findLabelButton(VIEW_MODE_BOARD).text()).toBe('Board');
    expect(findLabelButton(VIEW_MODE_BOARD).props('icon')).toBe('');
  });

  it('emits toggle-view-mode with the clicked value from either variant', () => {
    createComponent();

    findIconButton(VIEW_MODE_BOARD).vm.$emit('click');
    findLabelButton(VIEW_MODE_BOARD).vm.$emit('click');

    expect(wrapper.emitted('toggle-view-mode')).toEqual([[VIEW_MODE_BOARD], [VIEW_MODE_BOARD]]);
  });

  it('omits the board button when the planningViewBoards feature flag is disabled', () => {
    createComponent({ provide: { glFeatures: { planningViewBoards: false } } });

    expect(findToggles()).toHaveLength(0);
  });

  describe('when planningViewTable is also enabled', () => {
    beforeEach(() => {
      createComponent({
        provide: { glFeatures: { planningViewBoards: true, planningViewTable: true } },
      });
    });

    it('renders list, board and table buttons', () => {
      expect(findIconButton(VIEW_MODE_LIST).exists()).toBe(true);
      expect(findIconButton(VIEW_MODE_BOARD).exists()).toBe(true);
      expect(findIconButton(VIEW_MODE_TABLE).exists()).toBe(true);
    });

    it('omits the board button when the planningViewBoards feature flag is disabled', () => {
      createComponent({
        provide: { glFeatures: { planningViewBoards: false, planningViewTable: true } },
      });

      expect(findToggles()).toHaveLength(2);
      expect(findIconButton(VIEW_MODE_BOARD).exists()).toBe(false);
      expect(findIconButton(VIEW_MODE_TABLE).exists()).toBe(true);
    });
  });
});
