<script>
import { GlFormGroup, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { glSlotsMixin } from '~/lib/utils/vue3compat/gl_slots_mixin';
import { fieldInputId } from '../utils';

export default {
  name: 'FieldWrapper',
  components: { GlFormGroup, GlIcon },
  directives: { GlTooltip: GlTooltipDirective },
  mixins: [glSlotsMixin],
  props: {
    field: {
      type: Object,
      required: true,
    },
    // False when the slot holds a group of controls rather than one labelable element,
    // so the label is not given a `for` that points at nothing.
    labelledControl: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  computed: {
    inputId() {
      return fieldInputId(this.field);
    },
    labelFor() {
      return this.labelledControl ? this.inputId : null;
    },
  },
};
</script>

<template>
  <gl-form-group :label-for="labelFor" :description="field.description" class="gl-mb-0">
    <template #label>
      {{ field.label }}<span v-if="field.required" class="gl-text-danger"> *</span>
      <gl-icon
        v-if="field.helpText"
        v-gl-tooltip
        name="question-o"
        :size="12"
        :title="field.helpText"
        class="gl-ml-1 gl-text-subtle"
      />
    </template>
    <template v-if="glSlots().default" #default><slot :input-id="inputId"></slot></template>
  </gl-form-group>
</template>
