<script>
import { GlFormInput } from '@gitlab/ui';
import { fieldProps } from './field_props';
import FieldWrapper from './field_wrapper.vue';

export default {
  name: 'NumberField',
  components: { FieldWrapper, GlFormInput },
  props: {
    ...fieldProps,
    value: {
      type: Number,
      required: false,
      default: undefined,
    },
  },
  emits: ['input'],
  methods: {
    // A blank or unparseable entry is unset, not NaN: NaN serialises to null, which the
    // backend reads as a wrong-typed value rather than an absent one.
    emitNumber(entered) {
      const parsed = Number(entered);

      this.$emit('input', entered === '' || Number.isNaN(parsed) ? undefined : parsed);
    },
  },
};
</script>

<template>
  <field-wrapper :field="field">
    <template #default="{ inputId }">
      <gl-form-input
        :id="inputId"
        type="number"
        :value="value"
        :min="field.min"
        :max="field.max"
        :placeholder="field.placeholder"
        @input="emitNumber"
      />
    </template>
  </field-wrapper>
</template>
