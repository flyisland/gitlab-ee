import { GlSprintf } from '@gitlab/ui';
import SummaryHighlights from 'ee/vue_shared/security_reports/components/summary_highlights.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

describe('MR Widget Security Reports - Summary Highlights', () => {
  let wrapper;

  const createComponent = ({ highlights, showSingleSeverity, capped } = {}) => {
    wrapper = shallowMountExtended(SummaryHighlights, {
      propsData: {
        highlights,
        showSingleSeverity,
        capped,
      },
      stubs: { GlSprintf },
    });
  };

  describe.each`
    severity      | count
    ${'critical'} | ${5022}
    ${'high'}     | ${20}
    ${'other'}    | ${1}
  `('should only emphasize counts higher than 0 for $severity', ({ severity, count }) => {
    it('should emphasize counts higher than 0', () => {
      createComponent({
        highlights: {
          [severity]: count,
        },
      });

      expect(wrapper.findByTestId(severity).element.tagName).toBe('STRONG');
    });
  });

  it("calculate 'others' when other severities are provided", () => {
    const others = { medium: 50, low: 30, unknown: 20 };

    createComponent({
      highlights: {
        critical: 10,
        high: 20,
        ...others,
      },
    });

    expect(wrapper.text()).toContain('100 others');
  });

  it.each`
    severity      | color                       | count
    ${'critical'} | ${'severity-text-critical'} | ${10}
    ${'high'}     | ${'severity-text-high'}     | ${20}
    ${'medium'}   | ${'severity-text-medium'}   | ${50}
    ${'low'}      | ${'severity-text-low'}      | ${30}
    ${'unknown'}  | ${'severity-text-unknown'}  | ${20}
  `(
    "displays a number only when 'showSingleSeverity' property is provided",
    ({ severity, color, count }) => {
      const others = { medium: 50, low: 30, unknown: 20 };

      createComponent({
        showSingleSeverity: severity,
        highlights: {
          critical: 10,
          high: 20,
          ...others,
        },
      });

      expect(wrapper.html()).toContain(color);
      expect(wrapper.text().replace(/\s+/, ' ')).toBe(`${count.toString()} vulnerabilities`);
    },
  );

  it('shows capped results when capped property is true', () => {
    const others = { medium: 50, low: 1001, unknown: 20 };

    createComponent({
      capped: true,
      highlights: {
        critical: 1001,
        high: 20,
        ...others,
      },
    });

    expect(wrapper.text()).toContain('1000+ critical');
    expect(wrapper.text()).toContain('20 high');
    expect(wrapper.text()).toContain('1000+ others');
  });

  it('shows capped results when `other` is specified and capped property is true', () => {
    createComponent({
      capped: true,
      highlights: {
        critical: 1001,
        high: 20,
        other: 1001,
      },
    });

    expect(wrapper.text()).toContain('1000+ critical');
    expect(wrapper.text()).toContain('20 high');
    expect(wrapper.text()).toContain('1000+ others');
  });

  describe('snapshots', () => {
    it('should display all three severity highlights properly', () => {
      createComponent({
        highlights: { critical: 10, high: 20, other: 60 },
      });

      expect(wrapper.html()).toMatchSnapshot();
    });

    it('should display two severity highlights properly', () => {
      createComponent({
        highlights: { critical: 10, high: 20, other: 0 },
      });

      expect(wrapper.html()).toMatchSnapshot();
    });

    it('should display one severity highlight properly', () => {
      createComponent({
        highlights: { critical: 10, high: 0, other: 0 },
      });

      expect(wrapper.html()).toMatchSnapshot();
    });

    it('should display zero vulnerabilities properly', () => {
      createComponent({
        highlights: { critical: 0, high: 0, other: 0 },
      });

      expect(wrapper.html()).toMatchSnapshot();
    });
  });

  describe('hiding zero-count severity parts', () => {
    it('shows only non-zero parts when there are findings', () => {
      createComponent({
        highlights: { critical: 4, high: 0, other: 0 },
      });

      expect(wrapper.findByTestId('critical').exists()).toBe(true);
      expect(wrapper.findByTestId('high').exists()).toBe(false);
      expect(wrapper.findByTestId('other').exists()).toBe(false);
      expect(wrapper.text()).toBe('4 critical');
    });

    it('shows two non-zero parts with conjunction', () => {
      createComponent({
        highlights: { critical: 4, high: 2, other: 0 },
      });

      expect(wrapper.findByTestId('critical').exists()).toBe(true);
      expect(wrapper.findByTestId('high').exists()).toBe(true);
      expect(wrapper.findByTestId('other').exists()).toBe(false);
      expect(wrapper.text()).toBe('4 critical and 2 high');
    });

    it('shows all three parts when all are non-zero', () => {
      createComponent({
        highlights: { critical: 4, high: 2, other: 3 },
      });

      expect(wrapper.findByTestId('critical').exists()).toBe(true);
      expect(wrapper.findByTestId('high').exists()).toBe(true);
      expect(wrapper.findByTestId('other').exists()).toBe(true);
      expect(wrapper.text()).toBe('4 critical, 2 high, and 3 others');
    });

    it('shows "0 vulnerabilities" when all counts are zero', () => {
      createComponent({
        highlights: { critical: 0, high: 0, other: 0 },
      });

      expect(wrapper.text()).toBe('0 vulnerabilities');
    });
  });
});
