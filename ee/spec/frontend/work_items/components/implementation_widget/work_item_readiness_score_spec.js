import { GlLink, GlSprintf } from '@gitlab/ui';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import { shallowMountExtended, mountExtended } from 'helpers/vue_test_utils_helper';
import { stubComponent } from 'helpers/stub_component';
import HelpPopover from '~/vue_shared/components/help_popover.vue';
import { helpPagePath } from '~/helpers/help_page_helper';
import WorkItemReadinessScore from 'ee/work_items/components/implementation_widget/work_item_readiness_score.vue';
import ReadinessBar from 'ee/work_items/components/implementation_widget/readiness_bar.vue';
import ImplementationWidgetSegment from 'ee/vue_shared/components/work_items/implementation_widget_segment.vue';
import { PLAN_READINESS_LEVELS } from 'ee/work_items/components/implementation_widget/constants';

describe('WorkItemReadinessScore', () => {
  let wrapper;

  const createComponent = ({ props = {}, mountFn = shallowMountExtended, stubs = {} } = {}) => {
    wrapper = mountFn(WorkItemReadinessScore, {
      propsData: props,
      stubs: { ImplementationWidgetSegment, ...stubs },
    });
  };

  const findPill = () => wrapper.findComponent(ReadinessBar);
  const findHelpPopover = () => wrapper.findComponent(HelpPopover);
  const findHelpLink = () => wrapper.findComponent(GlLink);
  // We intentionally target by `role` rather than a `data-testid` here: the
  // point is to assert the element is exposed as the correct accessibility role
  // (an `img` with an aria-label) so it triggers the right behaviour for
  // assistive tech. A `data-testid` would not guarantee that.
  const findScoreGroup = () => wrapper.findByRole('img');
  const findScoreValue = () => wrapper.find('[data-testid="readiness-score-value"]');

  describe.each`
    scenario              | score  | readinessLevel                  | label
    ${'zero'}             | ${0}   | ${PLAN_READINESS_LEVELS.LOW}    | ${'Low'}
    ${'low, upper bound'} | ${39}  | ${PLAN_READINESS_LEVELS.LOW}    | ${'Low'}
    ${'medium, lower'}    | ${40}  | ${PLAN_READINESS_LEVELS.MEDIUM} | ${'Medium'}
    ${'medium, upper'}    | ${79}  | ${PLAN_READINESS_LEVELS.MEDIUM} | ${'Medium'}
    ${'high, lower'}      | ${80}  | ${PLAN_READINESS_LEVELS.HIGH}   | ${'High'}
    ${'high, max'}        | ${100} | ${PLAN_READINESS_LEVELS.HIGH}   | ${'High'}
  `('when score is $scenario', ({ score, readinessLevel, label }) => {
    beforeEach(() => {
      createComponent({ props: { score } });
    });

    it(`passes the "${label}" readiness level to the pill`, () => {
      expect(findPill().props('readinessLevel')).toEqual(readinessLevel);
    });

    it(`shows the "${label}" readiness label`, () => {
      expect(wrapper.text()).toContain(label);
    });

    it(`exposes "Readiness: ${label}" via aria-label`, () => {
      expect(findScoreGroup().attributes('aria-label')).toBe(`Readiness: ${label}`);
    });
  });

  describe('tracking', () => {
    const { bindInternalEventDocument } = useMockInternalEventsTracking();

    beforeEach(() => {
      createComponent({ props: { score: 72 } });
    });

    it('does not track an event on render', () => {
      const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

      expect(trackEventSpy).not.toHaveBeenCalled();
    });

    it('tracks an event with the score only the first time the popover is shown', () => {
      const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

      findHelpPopover().vm.$emit('shown');
      findHelpPopover().vm.$emit('shown');

      expect(trackEventSpy).toHaveBeenCalledTimes(1);
      expect(trackEventSpy).toHaveBeenCalledWith(
        'view_work_item_agent_plan_readiness_score',
        { value: 72 },
        undefined,
      );
    });
  });

  describe('help popover', () => {
    beforeEach(() => {
      createComponent({ props: { score: 90 } });
    });

    it('uses the info icon since it provides additional information', () => {
      expect(findHelpPopover().props('icon')).toBe('information-o');
    });

    it('sets a clean aria-label without sprintf placeholders', () => {
      expect(findHelpPopover().props('ariaLabel')).toBe('What is the readiness score?');
      expect(findHelpPopover().props('ariaLabel')).not.toContain('linkStart');
    });

    it('explains how readiness is calculated', () => {
      const { content } = findHelpPopover().props('options');
      expect(content).toContain('Shows how ready this work item is for an agent to run');
      expect(content).toContain(
        'To raise the score, add more detail to the work item description and to the workplan steps',
      );
    });

    it('shows the title in the popover', () => {
      createComponent({
        props: { score: 90 },
        mountFn: mountExtended,
        stubs: {
          HelpPopover: stubComponent(HelpPopover, {
            template: '<div><slot name="title"></slot><slot></slot></div>',
          }),
          GlSprintf,
        },
      });

      expect(wrapper.text()).toContain('What is the readiness score?');
    });

    describe('score value', () => {
      const createMounted = (score) =>
        createComponent({
          props: { score },
          mountFn: mountExtended,
          stubs: {
            HelpPopover: stubComponent(HelpPopover, {
              template: '<div><slot name="title"></slot><slot></slot></div>',
            }),
            GlSprintf,
          },
        });

      it('renders the score out of 100', () => {
        createMounted(85);
        expect(findScoreValue().text()).toBe('Score: 85 / 100');
      });
    });

    it('links to the readiness score documentation', () => {
      createComponent({
        props: { score: 90 },
        mountFn: mountExtended,
        stubs: {
          HelpPopover: stubComponent(HelpPopover, {
            template: '<div><slot></slot></div>',
          }),
          GlSprintf,
        },
      });

      expect(findHelpLink().attributes('href')).toBe(
        helpPagePath('user/work_items/workplan.md', { anchor: 'readiness-score' }),
      );
    });
  });
});
