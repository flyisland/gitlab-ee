import {
  GlBadge,
  GlButton,
  GlFormCheckbox,
  GlFormGroup,
  GlFormInput,
  GlFormSelect,
  GlFormTextarea,
  GlIcon,
} from '@gitlab/ui';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import CheckboxField from 'ee/policy_store/components/editor/fields/checkbox_field.vue';
import CodeField from 'ee/policy_store/components/editor/fields/code_field.vue';
import FieldWrapper from 'ee/policy_store/components/editor/fields/field_wrapper.vue';
import SelectField from 'ee/policy_store/components/editor/fields/select_field.vue';
import TextField from 'ee/policy_store/components/editor/fields/text_field.vue';
import TextListField from 'ee/policy_store/components/editor/fields/text_list_field.vue';
import TextareaField from 'ee/policy_store/components/editor/fields/textarea_field.vue';
import MultiBadgeSelector from 'ee/policy_store/components/editor/multi_badge_selector.vue';
import RegoTemplatesModal from 'ee/policy_store/components/editor/rego_templates_modal.vue';

describe('editor field controls', () => {
  let wrapper;

  describe('FieldWrapper', () => {
    const mountWrapper = (field, props = {}) =>
      mountExtended(FieldWrapper, {
        propsData: { field, ...props },
        slots: { default: '<input id="policy-store-field-branch" />' },
      });

    it('points the label at the control it labels', () => {
      wrapper = mountWrapper({ key: 'branch', label: 'Branch' });

      expect(wrapper.find('label').text()).toContain('Branch');
      expect(wrapper.find('label').attributes('for')).toBe('policy-store-field-branch');
    });

    it('omits the label target when the slot holds a group of controls', () => {
      wrapper = shallowMountExtended(FieldWrapper, {
        propsData: { field: { key: 'branch', label: 'Branch' }, labelledControl: false },
      });

      expect(wrapper.findComponent(GlFormGroup).attributes('label-for')).toBeUndefined();
    });

    it('renders the description under the control', () => {
      wrapper = mountWrapper({ key: 'branch', label: 'Branch', description: 'Sub-text' });

      expect(wrapper.text()).toContain('Sub-text');
    });

    it('marks a required field with a semantic token rather than a raw colour', () => {
      wrapper = mountWrapper({ key: 'branch', label: 'Branch', required: true });

      expect(wrapper.find('label span').classes()).toContain('gl-text-danger');
    });

    it('renders a help icon only when the field declares help text', () => {
      expect(mountWrapper({ key: 'b', label: 'B' }).findComponent(GlIcon).exists()).toBe(false);
      expect(
        mountWrapper({ key: 'b', label: 'B', helpText: 'Why' }).findComponent(GlIcon).exists(),
      ).toBe(true);
    });
  });

  describe('TextField', () => {
    it('renders the value and placeholder, and emits on input', () => {
      wrapper = mountExtended(TextField, {
        propsData: {
          field: { key: 'branch', label: 'Branch', placeholder: 'e.g. main' },
          value: 'x',
        },
      });

      expect(wrapper.findComponent(GlFormInput).props('value')).toBe('x');
      expect(wrapper.find('input').attributes('placeholder')).toBe('e.g. main');
      expect(wrapper.find('input').attributes('id')).toBe('policy-store-field-branch');

      wrapper.findComponent(GlFormInput).vm.$emit('input', 'main');
      expect(wrapper.emitted('input')).toEqual([['main']]);
    });
  });

  describe('TextListField', () => {
    const field = { key: 'names', label: 'Environment names' };
    const mountField = (value) =>
      mountExtended(TextListField, { propsData: { field, ...(value ? { value } : {}) } });

    it('displays the stored array as a comma-separated string', () => {
      wrapper = mountField(['production', 'staging']);

      expect(wrapper.findComponent(GlFormInput).props('value')).toBe('production, staging');
    });

    it('splits the input into a trimmed array on change, dropping empties', () => {
      wrapper = mountField();

      wrapper.findComponent(GlFormInput).vm.$emit('change', ' production ,, staging ,');

      expect(wrapper.emitted('input')).toEqual([[['production', 'staging']]]);
    });

    it('emits an empty array when the input is cleared', () => {
      wrapper = mountField(['production']);

      wrapper.findComponent(GlFormInput).vm.$emit('change', '');

      expect(wrapper.emitted('input')).toEqual([[[]]]);
    });
  });

  describe('TextareaField', () => {
    it('renders the value and emits on input', () => {
      wrapper = mountExtended(TextareaField, {
        propsData: { field: { key: 'message', label: 'Message' }, value: 'hi' },
      });

      expect(wrapper.findComponent(GlFormTextarea).props('value')).toBe('hi');
      expect(wrapper.find('textarea').attributes('id')).toBe('policy-store-field-message');

      wrapper.findComponent(GlFormTextarea).vm.$emit('input', 'bye');
      expect(wrapper.emitted('input')).toEqual([['bye']]);
    });
  });

  describe('SelectField', () => {
    const field = {
      key: 'tier',
      label: 'Tier',
      options: [
        { id: 'production', label: 'Production' },
        { id: 'staging', label: 'Staging' },
      ],
    };

    it('renders a placeholder option followed by each option', () => {
      wrapper = mountExtended(SelectField, { propsData: { field } });

      expect(wrapper.findAll('option').wrappers.map((o) => o.text())).toEqual([
        'Select...',
        'Production',
        'Staging',
      ]);
      expect(wrapper.find('select').attributes('id')).toBe('policy-store-field-tier');
    });

    it('uses the field placeholder for the empty option when given', () => {
      wrapper = mountExtended(SelectField, {
        propsData: { field: { ...field, placeholder: 'Any tier' } },
      });

      expect(wrapper.findAll('option').at(0).text()).toBe('Any tier');
    });

    it('emits on change', () => {
      wrapper = mountExtended(SelectField, { propsData: { field } });

      wrapper.findComponent(GlFormSelect).vm.$emit('change', 'staging');
      expect(wrapper.emitted('input')).toEqual([['staging']]);
    });
  });

  describe('CheckboxField', () => {
    const field = { key: 'sameRef', label: 'Same ref' };
    const create = (props) =>
      shallowMountExtended(CheckboxField, { propsData: { field, ...props } });

    it('labels itself from the field', () => {
      expect(create().findComponent(GlFormCheckbox).text()).toBe('Same ref');
    });

    it('is unchecked when neither a value nor a default is set', () => {
      expect(create().findComponent(GlFormCheckbox).props('checked')).toBe(false);
    });

    it('falls back to the field default', () => {
      wrapper = shallowMountExtended(CheckboxField, {
        propsData: { field: { ...field, default: true } },
      });

      expect(wrapper.findComponent(GlFormCheckbox).props('checked')).toBe(true);
    });

    it('prefers an explicit false value over a true default', () => {
      wrapper = shallowMountExtended(CheckboxField, {
        propsData: { field: { ...field, default: true }, value: false },
      });

      expect(wrapper.findComponent(GlFormCheckbox).props('checked')).toBe(false);
    });

    it('emits on change', () => {
      wrapper = create();

      wrapper.findComponent(GlFormCheckbox).vm.$emit('change', true);
      expect(wrapper.emitted('input')).toEqual([[true]]);
    });
  });

  describe('CodeField', () => {
    const field = { key: 'policy', label: 'Rego policy definition', maxLength: 32768 };
    const create = (props) => shallowMountExtended(CodeField, { propsData: { field, ...props } });

    it('renders a monospace editor honouring the field constraints', () => {
      wrapper = create({ value: 'package foo' });
      const textarea = wrapper.findComponent(GlFormTextarea);

      expect(textarea.props('value')).toBe('package foo');
      expect(textarea.attributes('maxlength')).toBe('32768');
      expect(textarea.attributes('spellcheck')).toBe('false');
      expect(textarea.classes()).toContain('gl-font-monospace');
    });

    it('ties its label to the editor', () => {
      wrapper = mountExtended(CodeField, { propsData: { field } });

      expect(wrapper.find('label').attributes('for')).toBe('policy-store-field-policy');
      expect(wrapper.find('textarea').attributes('id')).toBe('policy-store-field-policy');
    });

    it('opens the templates modal from the browse button and applies a choice', async () => {
      wrapper = create();
      expect(wrapper.findComponent(RegoTemplatesModal).props('visible')).toBe(false);

      await wrapper.findComponent(GlButton).vm.$emit('click');
      expect(wrapper.findComponent(RegoTemplatesModal).props('visible')).toBe(true);

      wrapper.findComponent(RegoTemplatesModal).vm.$emit('select', 'package governance');
      expect(wrapper.emitted('input')).toEqual([['package governance']]);
    });

    it('emits on input', () => {
      wrapper = create();

      wrapper.findComponent(GlFormTextarea).vm.$emit('input', 'package bar');
      expect(wrapper.emitted('input')).toEqual([['package bar']]);
    });
  });

  describe('MultiBadgeSelector', () => {
    const field = {
      key: 'roles',
      label: 'Role approvers',
      options: [
        { id: 'a', label: 'Alpha' },
        { id: 'b', label: 'Beta' },
      ],
    };
    const create = (props) =>
      shallowMountExtended(MultiBadgeSelector, { propsData: { field, ...props } });
    const findBadges = () => wrapper.findAllComponents(GlBadge);

    it('renders each option as a button, since they are meant to be interacted with', () => {
      wrapper = create();

      expect(findBadges().wrappers.map((b) => b.text())).toEqual(['Alpha', 'Beta']);
      expect(findBadges().wrappers.every((b) => b.props('tag') === 'button')).toBe(true);
    });

    it('names the group, because the options are buttons rather than one control', () => {
      wrapper = create();

      expect(wrapper.find('[role="group"]').attributes('aria-label')).toBe('Role approvers');
      expect(wrapper.findComponent(FieldWrapper).props('labelledControl')).toBe(false);
    });

    it('announces the pressed state of every option, selected or not', () => {
      wrapper = create({ value: ['a'] });

      expect(findBadges().wrappers.map((b) => b.attributes('aria-pressed'))).toEqual([
        'true',
        'false',
      ]);
    });

    it('adds and removes options as they are clicked', () => {
      wrapper = create({ value: ['a'] });

      findBadges().at(1).vm.$emit('click');
      expect(wrapper.emitted('input')).toEqual([[['a', 'b']]]);

      findBadges().at(0).vm.$emit('click');
      expect(wrapper.emitted('input')[1]).toEqual([['a'].filter((id) => id !== 'a')]);
    });
  });
});
