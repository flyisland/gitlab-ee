<script>
import { GlFormInput } from '@gitlab/ui';
import { fieldProps } from './field_props';
import FieldWrapper from './field_wrapper.vue';

export default {
  name: 'TextField',
  components: { FieldWrapper, GlFormInput },
  props: {
    ...fieldProps,
    value: {
      type: String,
      required: false,
      default: '',
    },
  },
  emits: ['input'],
};
</script>

<template>
  <field-wrapper :field="field">
    <template #default="{ inputId }">
      <gl-form-input
        :id="inputId"
        :value="value"
        :placeholder="field.placeholder"
        @input="$emit('input', $event)"
      />
    </template>
  </field-wrapper>
</template>
