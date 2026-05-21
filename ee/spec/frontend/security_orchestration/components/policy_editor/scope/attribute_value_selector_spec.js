import { GlCollapsibleListbox, GlPopover } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AttributeValueSelector from 'ee/security_orchestration/components/policy_editor/scope/attribute_value_selector.vue';

const ITEMS = [
  { value: 'gid://gitlab/Security::Attribute/1', text: 'Mission Critical', color: '#ff0000' },
  { value: 'gid://gitlab/Security::Attribute/2', text: 'Business Critical', color: '#ff8800' },
];

describe('AttributeValueSelector', () => {
  let wrapper;

  const createComponent = (propsData = {}) => {
    wrapper = shallowMountExtended(AttributeValueSelector, {
      propsData: { items: ITEMS, ...propsData },
    });
  };

  const findDropdown = () => wrapper.findComponent(GlCollapsibleListbox);
  const findPopover = () => wrapper.findComponent(GlPopover);

  describe('rendering', () => {
    it('renders items on the dropdown', () => {
      createComponent();
      expect(findDropdown().props('items')).toEqual(ITEMS);
    });

    it('passes selected ids through to the dropdown', () => {
      createComponent({ selected: [ITEMS[0].value] });
      expect(findDropdown().props('selected')).toEqual([ITEMS[0].value]);
    });

    it('disables the dropdown when disabled prop is true', () => {
      createComponent({ disabled: true });
      expect(findDropdown().props('disabled')).toBe(true);
    });

    it('propagates the loading prop', () => {
      createComponent({ loading: true });
      expect(findDropdown().props('loading')).toBe(true);
    });
  });

  describe('empty category', () => {
    it('shows the no-attributes popover and disables the dropdown', () => {
      createComponent({ items: [], isCategoryEmpty: true });
      expect(findPopover().exists()).toBe(true);
      expect(findDropdown().props('disabled')).toBe(true);
    });

    it('hides the popover when the category has attributes', () => {
      createComponent();
      expect(findPopover().exists()).toBe(false);
    });
  });

  describe('emits', () => {
    beforeEach(() => createComponent());

    it('emits select with the ids from the dropdown', () => {
      findDropdown().vm.$emit('select', [ITEMS[0].value]);
      expect(wrapper.emitted('select')).toEqual([[[ITEMS[0].value]]]);
    });

    it('emits reset when the dropdown is cleared', () => {
      findDropdown().vm.$emit('reset');
      expect(wrapper.emitted('reset')).toHaveLength(1);
    });

    it('emits select-all with every item id', () => {
      findDropdown().vm.$emit('select-all');
      expect(wrapper.emitted('select-all')).toEqual([[ITEMS.map(({ value }) => value)]]);
    });
  });

  describe('search', () => {
    it('filters items by a search term', async () => {
      createComponent();

      await findDropdown().vm.$emit('search', 'business');

      expect(findDropdown().props('items')).toEqual([ITEMS[1]]);
    });
  });

  describe('toggle text', () => {
    it('shows the placeholder when nothing is selected', () => {
      createComponent();
      expect(findDropdown().props('toggleText')).toBe('Select attributes');
    });

    it('shows the single selected attribute name', () => {
      createComponent({ selected: [ITEMS[0].value] });
      expect(findDropdown().props('toggleText')).toBe('Mission Critical');
    });
  });

  describe('validation state', () => {
    it('is valid when not dirty', () => {
      createComponent();
      expect(wrapper.findComponent({ name: 'GlFormGroup' }).attributes('state')).toBe('true');
    });

    it('is invalid when dirty with no selection', () => {
      createComponent({ isDirty: true });
      expect(wrapper.findComponent({ name: 'GlFormGroup' }).attributes('state')).toBeUndefined();
    });
  });

  describe('unique dropdown id', () => {
    it('generates a distinct id per instance so popovers do not collide', () => {
      const first = shallowMountExtended(AttributeValueSelector, {
        propsData: { items: ITEMS },
      });
      const second = shallowMountExtended(AttributeValueSelector, {
        propsData: { items: ITEMS },
      });

      const firstId = first.findComponent(GlCollapsibleListbox).attributes('id');
      const secondId = second.findComponent(GlCollapsibleListbox).attributes('id');

      expect(firstId).toEqual(expect.stringMatching(/^attribute-value-selector-/));
      expect(secondId).toEqual(expect.stringMatching(/^attribute-value-selector-/));
      expect(firstId).not.toBe(secondId);
    });
  });
});
