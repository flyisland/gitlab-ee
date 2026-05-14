import { GlBadge } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import TestRunStatusBadge from 'ee/security_orchestration/components/policies/test_run_status_badge.vue';

describe('TestRunStatusBadge', () => {
  let wrapper;

  const createComponent = ({ testRuns = null } = {}) => {
    wrapper = shallowMountExtended(TestRunStatusBadge, {
      propsData: {
        testRuns,
      },
    });
  };

  const findBadge = () => wrapper.findComponent(GlBadge);

  describe('when no test run exists', () => {
    it('does not render badge when testRuns is null', () => {
      createComponent();

      expect(findBadge().exists()).toBe(false);
    });

    it('does not render badge when testRuns.nodes is empty', () => {
      createComponent({ testRuns: { nodes: [] } });

      expect(findBadge().exists()).toBe(false);
    });
  });

  describe('when test run exists', () => {
    it.each`
      state         | expectedVariant | expectedText       | expectedIcon
      ${'RUNNING'}  | ${'info'}       | ${'Test running'}  | ${'status_running'}
      ${'COMPLETE'} | ${'success'}    | ${'Test complete'} | ${'status_closed'}
      ${'FAILED'}   | ${'danger'}     | ${'Test failed'}   | ${'status_failed'}
    `(
      'renders $state state with $expectedVariant variant, "$expectedText" text, and $expectedIcon icon',
      ({ state, expectedVariant, expectedText, expectedIcon }) => {
        createComponent({
          testRuns: { nodes: [{ id: '1', state }] },
        });

        expect(findBadge().exists()).toBe(true);
        expect(findBadge().props('variant')).toBe(expectedVariant);
        expect(findBadge().props('icon')).toBe(expectedIcon);
        expect(findBadge().text()).toBe(expectedText);
      },
    );

    it('renders neutral variant for unknown state', () => {
      createComponent({
        testRuns: { nodes: [{ id: '1', state: 'UNKNOWN' }] },
      });

      expect(findBadge().exists()).toBe(true);
      expect(findBadge().props('variant')).toBe('neutral');
      expect(findBadge().props('icon')).toBeNull();
    });
  });
});
