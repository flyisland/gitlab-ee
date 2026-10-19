<script>
import { hiddenFieldKeys, visibleFields } from '../../catalog/helpers';
import {
  FIELD_TYPE_CHECKBOX,
  FIELD_TYPE_CODE,
  FIELD_TYPE_FREEZE_WINDOWS,
  FIELD_TYPE_MULTI_BADGE,
  FIELD_TYPE_SEARCHABLE_SELECT,
  FIELD_TYPE_NUMBER,
  FIELD_TYPE_SELECT,
  FIELD_TYPE_SETTING_VALUE,
  FIELD_TYPE_TEXT,
  FIELD_TYPE_TEXTAREA,
  FIELD_TYPE_TEXT_LIST,
} from './constants';
import CheckboxField from './fields/checkbox_field.vue';
import CodeField from './fields/code_field.vue';
import NumberField from './fields/number_field.vue';
import SettingValueField from './fields/setting_value_field.vue';
import SearchableSelectField from './fields/searchable_select_field.vue';
import SelectField from './fields/select_field.vue';
import TextField from './fields/text_field.vue';
import TextListField from './fields/text_list_field.vue';
import TextareaField from './fields/textarea_field.vue';
import FreezeWindowsConfig from './freeze_windows_config.vue';
import MultiBadgeSelector from './fields/multi_badge_selector.vue';

// One component per field type, all sharing the same contract: `{ field, value, config }`
// in, `input` out. A capability contributing its own control adds an entry here rather
// than growing a branch inside the renderer.
//
// A type missing from this map renders nothing, because Vue does not render
// `<component :is="undefined" />`. That is deliberate, and follows
// security_configuration/components/dynamic_fields.vue: it lets the backend catalog add a
// type before the frontend supports it, rather than drawing the wrong control for it.
const FIELD_COMPONENTS = {
  [FIELD_TYPE_TEXT]: TextField,
  [FIELD_TYPE_TEXT_LIST]: TextListField,
  [FIELD_TYPE_TEXTAREA]: TextareaField,
  [FIELD_TYPE_SELECT]: SelectField,
  [FIELD_TYPE_SEARCHABLE_SELECT]: SearchableSelectField,
  [FIELD_TYPE_CHECKBOX]: CheckboxField,
  [FIELD_TYPE_MULTI_BADGE]: MultiBadgeSelector,
  [FIELD_TYPE_CODE]: CodeField,
  [FIELD_TYPE_NUMBER]: NumberField,
  [FIELD_TYPE_SETTING_VALUE]: SettingValueField,
  [FIELD_TYPE_FREEZE_WINDOWS]: FreezeWindowsConfig,
};

export default {
  name: 'ConfigWrapper',
  props: {
    fields: {
      type: Array,
      required: true,
    },
    value: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  emits: ['input'],
  computed: {
    shownFields() {
      return visibleFields(this.fields, this.value);
    },
  },
  created() {
    // Two passes: a field's default can be the answer a sibling's showIf matches, so the
    // first reveals that sibling and the second seeds its default. catalog_spec caps
    // chains at one level, so a third pass would find nothing.
    const seeded = this.defaultsFor(this.shownFields, this.value);
    const revealed = { ...this.value, ...seeded };
    const defaults = {
      ...seeded,
      ...this.defaultsFor(visibleFields(this.fields, revealed), revealed),
    };

    if (Object.keys(defaults).length) {
      this.$emit('input', { ...this.value, ...defaults });
    }
  },
  methods: {
    componentFor(type) {
      return FIELD_COMPONENTS[type];
    },
    // Seed declared defaults so the value persists even if the control is never touched.
    defaultsFor(fields, config) {
      return fields.reduce((acc, field) => {
        // `in`, not a null check: a cleared control leaves the key declared as `undefined`,
        // and re-seeding it would hand back the default the author just removed. An explicit
        // `null` is still unset. JSON.stringify drops an `undefined` key on save, so this
        // holds in-session only and catalog_spec bans defaults on types that clear to it.
        const isUnset = !(field.key in config) || config[field.key] === null;

        return field.default !== undefined && isUnset
          ? { ...acc, [field.key]: field.default }
          : acc;
      }, {});
    },
    // A field the answer just hid loses its value: the author can no longer see or clear
    // it, so keeping it would let an abandoned control decide what is saved.
    update(key, newValue) {
      const next = { ...this.value, [key]: newValue };
      // One pass: catalog_spec forbids a showIf naming a conditional sibling, so hiding a
      // field can never hide a second one in the same change.
      const hidden = hiddenFieldKeys(this.fields, next);
      // Keys the catalog does not declare pass through untouched — deserializeRule owns
      // dropping those, and a field list mid-migration must not lose its value here.
      const shown = Object.fromEntries(
        Object.entries(next).filter(([configKey]) => !hidden.includes(configKey)),
      );
      // Only what this change revealed: a field that already carries a value keeps it, and a
      // control emitting nothing to mean "cleared" is not handed its default straight back.
      const revealed = this.fields.filter(
        ({ key: fieldKey }) => !hidden.includes(fieldKey) && !(fieldKey in shown),
      );

      this.$emit('input', { ...shown, ...this.defaultsFor(revealed, shown) });
    },
  },
};
</script>

<template>
  <div class="gl-flex gl-flex-col gl-gap-4">
    <component
      :is="componentFor(field.type)"
      v-for="field in shownFields"
      :key="field.key"
      :field="field"
      :value="value[field.key]"
      :config="value"
      @input="update(field.key, $event)"
    />
  </div>
</template>
