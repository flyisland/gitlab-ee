import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import ComponentLabel, {
  COMPONENT_COLORS,
} from 'ee/ai/duo_agents_platform/components/common/component_label.vue';

describe('ComponentLabel', () => {
  const findName = (wrapper) => wrapper.findByTestId('component-label-name');
  const findSeparator = (wrapper) => wrapper.findByTestId('component-label-separator');

  const createWrapper = (propsData = {}) =>
    shallowMountExtended(ComponentLabel, {
      propsData: {
        componentName: 'supervisor',
        ...propsData,
      },
    });

  it('renders humanized component name and separator', () => {
    const wrapper = createWrapper();

    expect(findName(wrapper).text()).toBe('Supervisor');
    expect(findSeparator(wrapper).text()).toBe('·');
  });

  it.each(COMPONENT_COLORS.map((color, index) => [index, color]))(
    'applies color at index %i (%s)',
    (colorIndex, expectedClass) => {
      const wrapper = createWrapper({ componentName: 'supervisor', colorIndex });

      expect(findName(wrapper).classes()).toContain(expectedClass);
    },
  );

  it('wraps around the palette when colorIndex exceeds palette length', () => {
    const wrapper = createWrapper({
      componentName: 'supervisor',
      colorIndex: COMPONENT_COLORS.length,
    });

    expect(findName(wrapper).classes()).toContain(COMPONENT_COLORS[0]);
  });
});
