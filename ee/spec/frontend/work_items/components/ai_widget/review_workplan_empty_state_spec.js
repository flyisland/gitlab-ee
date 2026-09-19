import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import ReviewWorkplanEmptyState from 'ee/work_items/components/ai_widget/review_workplan_empty_state.vue';
import {
  WORKPLAN_GOAL_PREFIX,
  GENERATE_MR_BUTTON_OPTIONS,
} from 'ee/work_items/components/ai_widget/constants';

describe('ReviewWorkplanEmptyState', () => {
  let wrapper;

  const defaultProps = {
    projectPath: 'group/project',
    workItemIid: '42',
    workItemType: 'Issue',
    workItemWebUrl: 'http://gdk.test/group/project/-/work_items/42',
    isPanelOpen: false,
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(ReviewWorkplanEmptyState, {
      propsData: { ...defaultProps, ...props },
    });
  };

  const findHeader = () => wrapper.findByTestId('workplan-header');
  const findDescription = () => wrapper.findByTestId('workplan-description');
  const findImplementButton = () => wrapper.findComponentByTestId('implement-workplan-button');
  const findViewButton = () => wrapper.findComponentByTestId('view-workplan-button');

  beforeEach(() => {
    createComponent();
  });

  it('shows the "found" header', () => {
    expect(findHeader().text()).toBe('Workplan found');
  });

  it('shows the review-first description', () => {
    expect(findDescription().text()).toBe("View the workplan and implement it when you're ready.");
  });

  it('renders the Implement button with correct props', () => {
    expect(findImplementButton().exists()).toBe(true);
    expect(findImplementButton().props()).toMatchObject({
      projectPath: 'group/project',
      workItemIid: '42',
      workItemType: 'Issue',
      workItemWebUrl: 'http://gdk.test/group/project/-/work_items/42',
      runDuoDeveloperInChat: true,
      additionalGoalContext: WORKPLAN_GOAL_PREFIX,
      generateMrButtonOptions: GENERATE_MR_BUTTON_OPTIONS,
    });
  });

  it('renders the View button before the Implement button', () => {
    const buttons = wrapper.findAll('[data-testid$="-workplan-button"]');

    expect(buttons.at(0).attributes('data-testid')).toBe('view-workplan-button');
    expect(buttons.at(1).attributes('data-testid')).toBe('implement-workplan-button');
  });

  describe.each`
    isPanelOpen | ariaPressed
    ${false}    | ${'false'}
    ${true}     | ${'true'}
  `('when isPanelOpen is $isPanelOpen', ({ isPanelOpen, ariaPressed }) => {
    beforeEach(() => {
      createComponent({ isPanelOpen });
    });

    it(`shows the View button as a toggle with aria-pressed="${ariaPressed}"`, () => {
      expect(findViewButton().exists()).toBe(true);
      expect(findViewButton().attributes('aria-pressed')).toBe(ariaPressed);
    });

    describe('when the View button is clicked', () => {
      beforeEach(() => {
        findViewButton().vm.$emit('click');
      });

      it('emits view-workplan', () => {
        expect(wrapper.emitted('view-workplan')).toHaveLength(1);
      });
    });
  });
});
