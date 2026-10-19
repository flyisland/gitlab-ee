<script>
import { GlButton, GlFormInput, GlFormRadioGroup, GlFormSelect } from '@gitlab/ui';
import { BOOLEAN_OPTIONS } from '~/security_configuration/constants';
import StringListTokenSelector from './string_list_token_selector.vue';
import {
  VALUE_TYPE_BOOLEAN,
  VALUE_TYPE_ENUM,
  VALUE_TYPE_STRING_LIST,
} from './variable_definitions';

export default {
  name: 'AdvancedConfigurationValueField',
  components: {
    GlButton,
    GlFormInput,
    GlFormRadioGroup,
    GlFormSelect,
    StringListTokenSelector,
  },
  props: {
    value: {
      type: [String, Number, Boolean, Array],
      required: false,
      default: null,
    },
    definition: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    fieldLabel: {
      type: String,
      required: true,
    },
    removeLabel: {
      type: String,
      required: true,
    },
    valueDataTestid: {
      type: String,
      required: true,
    },
    removeDataTestid: {
      type: String,
      required: true,
    },
  },
  emits: ['update'],
  computed: {
    isBoolean() {
      return this.definition.valueType === VALUE_TYPE_BOOLEAN;
    },
    isEnum() {
      return this.definition.valueType === VALUE_TYPE_ENUM;
    },
    isStringList() {
      return this.definition.valueType === VALUE_TYPE_STRING_LIST;
    },
    options() {
      return this.definition.options ?? [];
    },
    // Native <select> visually falls back to its first option when :value doesn't match any of
    // them (e.g. imageSuffix's placeholder null for a trigger with nothing configured yet), which
    // would misleadingly look like that option is selected. A genuinely blank one fixes that.
    selectOptions() {
      if (this.value === null || this.value === undefined) {
        return [{ value: null, text: '' }, ...this.options];
      }
      return this.options;
    },
  },
  methods: {
    // GlFormInput's value only accepts a String or a Number. Booleans, enums, and lists get
    // their own widget below; anything else falls back to plain text.
    stringifyValue(value) {
      return value === null || value === undefined ? '' : String(value);
    },
  },
  booleanOptions: BOOLEAN_OPTIONS,
};
</script>

<template>
  <div class="gl-flex gl-items-center gl-justify-between gl-gap-2">
    <gl-form-radio-group
      v-if="isBoolean"
      :checked="value"
      :options="$options.booleanOptions"
      :aria-label="fieldLabel"
      :data-testid="valueDataTestid"
      @input="$emit('update', $event)"
    />
    <gl-form-select
      v-else-if="isEnum"
      :value="value"
      :options="selectOptions"
      :aria-label="fieldLabel"
      :data-testid="valueDataTestid"
      @input="$emit('update', $event)"
    />
    <string-list-token-selector
      v-else-if="isStringList"
      :value="value"
      :aria-label="fieldLabel"
      :text-input-attrs="{ 'data-testid': valueDataTestid }"
      @input="$emit('update', $event)"
    />
    <gl-form-input
      v-else
      :value="stringifyValue(value)"
      :aria-label="fieldLabel"
      :data-testid="valueDataTestid"
      @change="$emit('update', $event)"
    />
    <gl-button
      category="tertiary"
      icon="remove"
      size="small"
      :aria-label="removeLabel"
      :data-testid="removeDataTestid"
      @click="$emit('update', null)"
    />
  </div>
</template>
