import { GlButton, GlButtonGroup, GlIcon } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import AiToolRuleAccessControl from 'ee/ai/governance/components/ai_tool_management/ai_tool_rule_access_control.vue';

describe('AiToolRuleAccessControl', () => {
  let wrapper;

  const createComponent = ({
    value = null,
    disabled = false,
    disabledTooltip = '',
    isLoading = false,
  } = {}) => {
    wrapper = mountExtended(AiToolRuleAccessControl, {
      propsData: {
        value,
        disabled,
        disabledTooltip,
        isLoading,
      },
    });
  };

  const findButtons = () => wrapper.findAllComponents(GlButton);
  const findButtonGroup = () => wrapper.findComponent(GlButtonGroup);
  const findButton = (value) => wrapper.findByTestId(`access-option-${value.toLowerCase()}`);

  describe('rendering', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders a button group', () => {
      expect(findButtonGroup().exists()).toBe(true);
    });

    it('renders three buttons', () => {
      expect(findButtons()).toHaveLength(3);
    });

    it('renders ALLOW, ASK, DENY buttons', () => {
      expect(findButton('ALLOW').exists()).toBe(true);
      expect(findButton('ASK').exists()).toBe(true);
      expect(findButton('DENY').exists()).toBe(true);
    });

    it('renders icons for each button', () => {
      const icons = wrapper.findAllComponents(GlIcon);
      expect(icons).toHaveLength(3);
    });
  });

  describe('selected state', () => {
    it('marks the current value as selected', () => {
      createComponent({ value: 'ASK' });

      expect(findButton('ASK').props('selected')).toBe(true);
      expect(findButton('ALLOW').props('selected')).toBe(false);
      expect(findButton('DENY').props('selected')).toBe(false);
    });

    it('applies green icon class to ALLOW when selected', () => {
      createComponent({ value: 'ALLOW' });

      const icon = findButton('ALLOW').findComponent(GlIcon);
      expect(icon.classes()).toContain('gl-text-green-500');
    });

    it('applies red icon class to DENY when selected', () => {
      createComponent({ value: 'DENY' });

      const icon = findButton('DENY').findComponent(GlIcon);
      expect(icon.classes()).toContain('gl-text-red-500');
    });

    it('does not apply color class to unselected buttons', () => {
      createComponent({ value: 'ALLOW' });

      const denyIcon = findButton('DENY').findComponent(GlIcon);
      expect(denyIcon.classes()).not.toContain('gl-text-red-500');
    });
  });

  describe('disabled state', () => {
    it('disables all buttons when disabled prop is true', () => {
      createComponent({ disabled: true });

      findButtons().wrappers.forEach((button) => {
        expect(button.props('disabled')).toBe(true);
      });
    });
  });

  describe('loading state', () => {
    it('disables all buttons when isLoading prop is true', () => {
      createComponent({ isLoading: true });

      findButtons().wrappers.forEach((button) => {
        expect(button.props('disabled')).toBe(true);
      });
    });
  });

  describe('when a button is clicked', () => {
    it('emits select with the clicked value', async () => {
      createComponent({ value: null });

      await findButton('ALLOW').trigger('click');

      expect(wrapper.emitted('select')).toEqual([['ALLOW']]);
    });

    it('does not emit select when the already-selected value is clicked', async () => {
      createComponent({ value: 'ASK' });

      await findButton('ASK').trigger('click');

      expect(wrapper.emitted('select')).toBeUndefined();
    });

    it('does not emit select when isLoading is true', async () => {
      createComponent({ value: null, isLoading: true });

      await findButton('ALLOW').trigger('click');

      expect(wrapper.emitted('select')).toBeUndefined();
    });
  });
});
