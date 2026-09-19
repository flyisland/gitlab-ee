<script>
import { GlButton, GlFormTextarea, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { s__ } from '~/locale';
import { fieldInputId } from '../utils';
import RegoTemplatesModal from '../rego_templates_modal.vue';

export default {
  name: 'CodeField',
  components: { GlButton, GlFormTextarea, GlIcon, RegoTemplatesModal },
  directives: { GlTooltip: GlTooltipDirective },
  props: {
    field: {
      type: Object,
      required: true,
    },
    value: {
      type: String,
      required: false,
      default: '',
    },
  },
  emits: ['input'],
  i18n: {
    browseTemplates: s__('PolicyStore|Browse templates'),
  },
  data() {
    return { templatesVisible: false };
  },
  computed: {
    inputId() {
      return fieldInputId(this.field);
    },
  },
};
</script>

<template>
  <!-- Not FieldWrapper: the label row also carries the templates button. -->
  <div>
    <div class="gl-mb-2 gl-flex gl-items-center gl-justify-between">
      <label :for="inputId" class="gl-mb-0 gl-font-semibold">
        {{ field.label }}<span v-if="field.required" class="gl-text-danger"> *</span>
        <gl-icon
          v-if="field.helpText"
          v-gl-tooltip
          name="question-o"
          :size="12"
          :title="field.helpText"
          class="gl-ml-1 gl-text-subtle"
        />
      </label>
      <gl-button
        category="secondary"
        variant="default"
        size="small"
        icon="documents"
        @click="templatesVisible = true"
      >
        {{ $options.i18n.browseTemplates }}
      </gl-button>
    </div>
    <gl-form-textarea
      :id="inputId"
      :value="value"
      :placeholder="field.placeholder"
      :rows="10"
      :maxlength="field.maxLength"
      class="gl-border gl-rounded-lg gl-border-subtle gl-bg-subtle gl-font-monospace gl-text-sm"
      spellcheck="false"
      @input="$emit('input', $event)"
    />
    <rego-templates-modal
      :visible="templatesVisible"
      @select="$emit('input', $event)"
      @hide="templatesVisible = false"
    />
  </div>
</template>
