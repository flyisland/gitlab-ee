<script>
import { settingFor } from '../../../catalog/helpers';
import {
  SETTING_VALUE_TYPE_BOOLEAN,
  SETTING_VALUE_TYPE_ENUM,
  SETTING_VALUE_TYPE_MULTI,
  SETTING_VALUE_TYPE_NUMERIC,
  SETTING_VALUE_TYPE_TEXT,
} from '../constants';
import CheckboxField from './checkbox_field.vue';
import { fieldProps } from './field_props';
import MultiBadgeSelector from './multi_badge_selector.vue';
import NumberField from './number_field.vue';
import SelectField from './select_field.vue';
import TextField from './text_field.vue';

// The control to draw for a setting's declared value type, and the shape a stored value
// must have to belong to it. Unlike ConfigWrapper's map this is keyed by the *setting's*
// type, not the catalog field's: which control appears is only known once the author has
// picked a setting.
//
// A type missing here renders nothing, the same deliberate choice ConfigWrapper makes for
// an unknown field type: the settings catalog can carry a type before the frontend can
// draw it, and drawing the wrong control would silently author an invalid value.
const CONTROLS = {
  [SETTING_VALUE_TYPE_BOOLEAN]: {
    component: CheckboxField,
    matches: (value) => typeof value === 'boolean',
  },
  [SETTING_VALUE_TYPE_ENUM]: {
    component: SelectField,
    matches: (value) => typeof value === 'string',
  },
  [SETTING_VALUE_TYPE_MULTI]: { component: MultiBadgeSelector, matches: Array.isArray },
  [SETTING_VALUE_TYPE_NUMERIC]: { component: NumberField, matches: Number.isFinite },
  [SETTING_VALUE_TYPE_TEXT]: {
    component: TextField,
    matches: (value) => typeof value === 'string',
  },
};

export default {
  name: 'SettingValueField',
  props: {
    ...fieldProps,
    value: {
      type: [Array, Boolean, Number, String],
      required: false,
      default: undefined,
    },
  },
  emits: ['input'],
  computed: {
    selectedKey() {
      return this.config[this.field.settingKeyField];
    },
    control() {
      return CONTROLS[settingFor(this.field, this.config)?.valueType];
    },
    // Built key by key rather than spread: the outer field is declared once for every
    // setting it can render, so its type-specific keys (`default`, `min`, `max`,
    // `placeholder`) belong to no control in particular. Leaking `default` in was the
    // worst of them — it would tick a boolean setting's checkbox while the config held
    // no answer at all. Only the choices come from the setting; the label stays the
    // catalog field's, since the sibling control above already names the setting.
    controlField() {
      const { key, label, description, helpText, required } = this.field;

      return {
        key,
        label,
        description,
        helpText,
        required,
        options: settingFor(this.field, this.config)?.options,
      };
    },
    // A value of the wrong shape belongs to a setting that is no longer selected, or to a
    // catalog that has since retyped this one. Passing it on would break the control.
    currentValue() {
      return this.control?.matches(this.value) ? this.value : undefined;
    },
  },
  watch: {
    // Not immediate, so mounting does not discard the value saved against this very
    // setting. That relies on StepWizard seeding policyData synchronously in `data()`
    // and keeping the build step behind `v-if`: were the config to arrive after mount,
    // `undefined -> the saved key` would read as a change and wipe the saved answer.
    selectedKey() {
      this.$emit('input', undefined);
    },
  },
};
</script>

<template>
  <component
    :is="control && control.component"
    :field="controlField"
    :config="config"
    :value="currentValue"
    @input="$emit('input', $event)"
  />
</template>
