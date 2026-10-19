import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import SessionPill from 'ee/ai/duo_agentic_chat/components/session_pills/session_pill.vue';
import { EventsTracker } from 'ee/ai/duo_agentic_chat/observability/events_tracker';

jest.mock('ee/ai/duo_agentic_chat/observability/events_tracker');

describe('SessionPill', () => {
  let wrapper;

  const defaultProps = {
    workflowId: 326,
    label: 'Merge MR !23423',
    status: 'RUNNING',
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(SessionPill, {
      propsData: { ...defaultProps, ...props },
    });
  };

  const findButton = () => wrapper.findByTestId('session-pill');
  const findStatusDot = () => wrapper.findComponentByTestId('session-pill-status-dot');
  const findCancelButton = () => wrapper.findComponentByTestId('session-pill-cancel-button');

  it('renders the pill with its label', () => {
    createComponent();

    expect(findButton().exists()).toBe(true);
    expect(wrapper.text()).toContain('Merge MR !23423');
  });

  it('renders a status dot with the color class matching the status', () => {
    createComponent({ status: 'RUNNING' });

    expect(findStatusDot().exists()).toBe(true);
    expect(findStatusDot().classes()).toContain('gl-fill-status-info');
    expect(findStatusDot().props('name')).toBe('status_created_borderless');
  });

  it('exposes the human-readable status in the aria-label', () => {
    createComponent();

    expect(findButton().attributes('aria-label')).toBe('Merge MR !23423 Running');
  });

  describe('click handling', () => {
    it('emits click with the workflowId', async () => {
      createComponent();

      await findButton().trigger('click');

      expect(wrapper.emitted('click')).toEqual([[326]]);
    });

    it('tracks the click via EventsTracker.trackClickThroughSessionPill', async () => {
      createComponent();

      await findButton().trigger('click');

      expect(EventsTracker.trackClickThroughSessionPill).toHaveBeenCalledWith({
        workflowId: 326,
      });
    });
  });

  describe('when the user hovers or focuses the pill', () => {
    beforeEach(() => {
      createComponent();
    });

    it('shows the cancel button', () => {
      expect(findCancelButton().classes()).toEqual(
        expect.arrayContaining([
          'gl-hidden',
          'group-hover:gl-inline-flex',
          'group-focus-within:gl-inline-flex',
        ]),
      );
    });

    it('labels the cancel button "Cancel session"', () => {
      expect(findCancelButton().attributes('title')).toBe('Cancel session');
      expect(findCancelButton().attributes('aria-label')).toBe('Cancel session');
    });
  });

  describe('when the user clicks the cancel button', () => {
    beforeEach(() => {
      createComponent();
      findCancelButton().vm.$emit('click');
    });

    it('requests cancellation without opening the session', () => {
      expect(wrapper.emitted('cancel')).toEqual([[326]]);
      expect(wrapper.emitted('click')).toBeUndefined();
    });

    it('tracks the cancellation', () => {
      expect(EventsTracker.trackCancelSessionFromSessionPill).toHaveBeenCalledWith({
        workflowId: 326,
      });
    });
  });
});
