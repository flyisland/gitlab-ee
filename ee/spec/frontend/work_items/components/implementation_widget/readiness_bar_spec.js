import { shallowMount } from '@vue/test-utils';
import { assertProps } from 'helpers/assert_props';
import ReadinessBar from 'ee/work_items/components/implementation_widget/readiness_bar.vue';
import { PLAN_READINESS_LEVELS } from 'ee/work_items/components/implementation_widget/constants';

describe('ReadinessBar', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(ReadinessBar, {
      propsData: {
        readinessLevel: PLAN_READINESS_LEVELS.HIGH,
        ...props,
      },
    });
  };

  const findTrack = () => wrapper.find('span');
  const findFill = () => wrapper.find('span > span');

  describe('readinessLevel prop validator', () => {
    it.each(Object.values(PLAN_READINESS_LEVELS))('accepts the "$value" level', (level) => {
      expect(() => assertProps(ReadinessBar, { readinessLevel: level })).not.toThrow();
    });

    it('rejects an unknown level', () => {
      expect(() => assertProps(ReadinessBar, { readinessLevel: { value: 'UNKNOWN' } })).toThrow();
    });
  });

  describe.each`
    level                           | width
    ${PLAN_READINESS_LEVELS.LOW}    | ${'33.33333333333333%'}
    ${PLAN_READINESS_LEVELS.MEDIUM} | ${'66.66666666666666%'}
    ${PLAN_READINESS_LEVELS.HIGH}   | ${'100%'}
  `('when readiness level is $value', ({ level, width }) => {
    beforeEach(() => {
      createComponent({ readinessLevel: level });
    });

    it(`fills the track to ${width}`, () => {
      expect(findFill().element.style.width).toBe(width);
    });
  });

  describe('when an ariaLabel is provided', () => {
    beforeEach(() => {
      createComponent({ ariaLabel: 'Readiness: HIGH' });
    });

    it('renders it on the track element', () => {
      expect(findTrack().attributes('aria-label')).toBe('Readiness: HIGH');
    });
  });
});
