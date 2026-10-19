import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import CheckboxField from 'ee/policy_store/components/editor/fields/checkbox_field.vue';
import MultiBadgeSelector from 'ee/policy_store/components/editor/fields/multi_badge_selector.vue';
import NumberField from 'ee/policy_store/components/editor/fields/number_field.vue';
import SelectField from 'ee/policy_store/components/editor/fields/select_field.vue';
import SettingValueField from 'ee/policy_store/components/editor/fields/setting_value_field.vue';
import TextField from 'ee/policy_store/components/editor/fields/text_field.vue';

describe('SettingValueField', () => {
  let wrapper;

  const settings = {
    pipelines_must_succeed: { name: 'Pipelines must succeed', valueType: 'boolean' },
    project_visibility: {
      name: 'Visibility level',
      valueType: 'enum',
      options: [
        { id: 'private', label: 'Private' },
        { id: 'public', label: 'Public' },
      ],
    },
    enabled_scanners: {
      name: 'Enabled scanners',
      valueType: 'multi',
      options: [{ id: 'sast', label: 'SAST' }],
    },
    minimum_approvals: { name: 'Minimum approvals', valueType: 'numeric' },
    default_branch_name: { name: 'Default branch name', valueType: 'text' },
    tomorrows_type: { name: 'From a newer backend', valueType: 'duration' },
  };

  const field = {
    key: 'value',
    label: 'Required value',
    settingKeyField: 'settingKey',
    settings,
  };

  const controls = [CheckboxField, SelectField, MultiBadgeSelector, NumberField, TextField];
  const renderedControls = () =>
    controls.filter((control) => wrapper.findComponent(control).exists());

  const createComponent = ({ settingKey, ...props } = {}) =>
    shallowMountExtended(SettingValueField, {
      propsData: { field, config: { settingKey }, ...props },
    });

  describe('choosing a control for the selected setting', () => {
    it.each([
      ['boolean', 'pipelines_must_succeed', CheckboxField],
      ['enum', 'project_visibility', SelectField],
      ['multi', 'enabled_scanners', MultiBadgeSelector],
      ['numeric', 'minimum_approvals', NumberField],
      ['text', 'default_branch_name', TextField],
    ])('renders the %s control', (valueType, settingKey, component) => {
      wrapper = createComponent({ settingKey });

      expect(wrapper.findComponent(component).exists()).toBe(true);
    });

    it('renders nothing until a setting is selected', () => {
      wrapper = createComponent();

      expect(renderedControls()).toEqual([]);
    });

    it('renders nothing for a setting the catalog does not know', () => {
      wrapper = createComponent({ settingKey: 'invented_by_the_author' });

      expect(renderedControls()).toEqual([]);
    });

    // Drawing the wrong control would silently author an invalid value, so a value
    // type the frontend does not support yet renders no control at all.
    it('renders nothing for a value type it does not support', () => {
      wrapper = createComponent({ settingKey: 'tomorrows_type' });

      expect(renderedControls()).toEqual([]);
    });
  });

  describe('the control it renders', () => {
    it('keeps the outer field label rather than repeating the setting name', () => {
      wrapper = createComponent({ settingKey: 'default_branch_name' });

      expect(wrapper.findComponent(TextField).props('field').label).toBe('Required value');
    });

    it("offers the setting's own options", () => {
      wrapper = createComponent({ settingKey: 'project_visibility' });

      expect(wrapper.findComponent(SelectField).props('field').options).toEqual([
        { id: 'private', label: 'Private' },
        { id: 'public', label: 'Public' },
      ]);
    });

    it('passes the current value through', () => {
      wrapper = createComponent({ settingKey: 'project_visibility', value: 'private' });

      expect(wrapper.findComponent(SelectField).props('value')).toBe('private');
    });

    // A policy saved before the catalog retyped its setting, or read mid-clear, would
    // otherwise hand the control a value of the wrong shape.
    it('ignores a stored value that does not match the setting type', () => {
      wrapper = createComponent({ settingKey: 'minimum_approvals', value: 'private' });

      expect(wrapper.findComponent(NumberField).props('value')).toBeUndefined();
    });

    // The outer field is declared once for every setting it can render, so its own
    // default belongs to none of them. Leaking it in ticked a boolean setting's checkbox
    // while the config held no answer at all.
    it('does not dress the control in the outer field type-specific keys', () => {
      wrapper = shallowMountExtended(SettingValueField, {
        propsData: {
          field: { ...field, default: true, min: 1, placeholder: 'Anything' },
          config: { settingKey: 'pipelines_must_succeed' },
        },
      });

      expect(wrapper.findComponent(CheckboxField).props('field')).toEqual({
        key: 'value',
        label: 'Required value',
        description: undefined,
        helpText: undefined,
        required: undefined,
        options: undefined,
      });
    });

    it('re-emits what the control emits', () => {
      wrapper = createComponent({ settingKey: 'minimum_approvals' });

      wrapper.findComponent(NumberField).vm.$emit('input', 2);

      expect(wrapper.emitted('input')).toEqual([[2]]);
    });
  });

  describe('when the selected setting changes', () => {
    it('clears the value left over from the previous setting', async () => {
      wrapper = createComponent({ settingKey: 'project_visibility', value: 'private' });

      await wrapper.setProps({ config: { settingKey: 'minimum_approvals' } });

      expect(wrapper.emitted('input')).toEqual([[undefined]]);
    });

    // Mounting with a saved policy's value must not wipe it before the author sees it.
    it('keeps a value that was there on mount', () => {
      wrapper = createComponent({ settingKey: 'project_visibility', value: 'private' });

      expect(wrapper.emitted('input')).toBeUndefined();
    });

    // The watcher is safe only because the wizard seeds its config synchronously. This
    // fails loudly the day a saved policy starts arriving after the editor has mounted.
    it('clears once a setting arrives where there was none, and not before', async () => {
      wrapper = createComponent({ value: 'private' });
      expect(wrapper.emitted('input')).toBeUndefined();

      await wrapper.setProps({ config: { settingKey: 'project_visibility' } });

      expect(wrapper.emitted('input')).toEqual([[undefined]]);
    });

    it('ignores a change to a config key it does not depend on', async () => {
      wrapper = createComponent({ settingKey: 'project_visibility', value: 'private' });

      await wrapper.setProps({ config: { settingKey: 'project_visibility', other: 'x' } });

      expect(wrapper.emitted('input')).toBeUndefined();
    });
  });
});
