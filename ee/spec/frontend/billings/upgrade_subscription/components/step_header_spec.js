import { GlButton, GlIcon } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import {
  STEP_STATUS_COMPLETE,
  STEP_STATUS_DISABLED,
} from 'ee/billings/upgrade_subscription/constants';
import StepHeader from 'ee/billings/upgrade_subscription/components/step_header.vue';

const { bindInternalEventDocument } = useMockInternalEventsTracking();

describe('StepHeader component', () => {
  let wrapper;
  let trackingSpy;

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(StepHeader, {
      propsData: {
        stepNumber: 1,
        title: 'Select a plan',
        ...props,
      },
    });
  };

  const findActiveIcon = () => wrapper.findByTestId('step-icon-active');
  const findCompleteIcon = () => wrapper.findByTestId('step-icon-complete');
  const findEditButton = () => wrapper.findByTestId('step-edit');

  describe('when step is active', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the title', () => {
      expect(wrapper.find('h2').text()).toBe('Select a plan');
    });

    it('renders the active step icon with the step number and correct styles', () => {
      const icon = findActiveIcon();

      expect(icon.exists()).toBe(true);
      expect(icon.text()).toBe('1');
      expect(icon.classes()).toContain('gl-bg-status-info');
    });

    it('does not render the complete icon', () => {
      expect(findCompleteIcon().exists()).toBe(false);
    });

    it('does not render the edit button', () => {
      expect(findEditButton().exists()).toBe(false);
    });
  });

  describe('when step is complete', () => {
    beforeEach(() => {
      createComponent({ status: STEP_STATUS_COMPLETE });
    });

    it('renders the complete icon with status-success', () => {
      expect(findCompleteIcon().exists()).toBe(true);
      expect(findCompleteIcon().findComponent(GlIcon).props('name')).toBe('status-success');
    });

    it('does not render the active icon', () => {
      expect(findActiveIcon().exists()).toBe(false);
    });

    it('renders the edit button', () => {
      expect(findEditButton().exists()).toBe(true);
    });

    it('emits edit event when edit button is clicked', () => {
      findEditButton().findComponent(GlButton).vm.$emit('click');

      expect(wrapper.emitted('edit')).toHaveLength(1);
    });

    it('tracks click_edit_plan_selection event when edit button is clicked', () => {
      trackingSpy = bindInternalEventDocument(wrapper.element).trackEventSpy;
      trackingSpy.mockClear();

      findEditButton().findComponent(GlButton).vm.$emit('click');

      expect(trackingSpy).toHaveBeenCalledWith(
        'click_edit_plan_selection',
        { property: 'edit_plan_selection' },
        undefined,
      );
    });
  });

  describe('when step is disabled', () => {
    beforeEach(() => {
      createComponent({ status: STEP_STATUS_DISABLED });
    });

    it('renders the step icon with the step number', () => {
      const icon = findActiveIcon();

      expect(icon.exists()).toBe(true);
      expect(icon.text()).toBe('1');
    });

    it('applies disabled styles to the outer and inner circle', () => {
      const icon = findActiveIcon();

      expect(icon.classes()).toContain('gl-bg-gray-100');
      expect(icon.classes()).not.toContain('gl-bg-status-info');

      const innerCircle = wrapper.findByTestId('step-icon-inner');
      expect(innerCircle.classes()).toContain('gl-bg-gray-300');
      expect(innerCircle.classes()).not.toContain('gl-bg-blue-500');
    });

    it('does not render the complete icon', () => {
      expect(findCompleteIcon().exists()).toBe(false);
    });

    it('does not render the edit button', () => {
      expect(findEditButton().exists()).toBe(false);
    });
  });

  it('renders the correct step number', () => {
    createComponent({ stepNumber: 2 });

    expect(findActiveIcon().text()).toBe('2');
  });
});
