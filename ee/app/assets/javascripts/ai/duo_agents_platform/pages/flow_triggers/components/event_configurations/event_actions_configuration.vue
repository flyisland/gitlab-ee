<script>
import { GlCard, GlCollapsibleListbox, GlFormGroup } from '@gitlab/ui';
import { omit } from 'lodash-es';
import { s__ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import {
  FILTER_FIELD_ACTION,
  FILTER_OPERATOR_IN,
  FLOW_TRIGGER_TYPE_MERGE_REQUEST,
  FLOW_TRIGGER_TYPE_WORK_ITEM,
} from 'ee/ai/duo_agents_platform/constants';
import { parseFilterRuleValues } from 'ee/ai/duo_agents_platform/utils';

export default {
  name: 'EventActionsConfiguration',
  components: {
    GlCard,
    GlCollapsibleListbox,
    GlFormGroup,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    value: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    invalidFeedback: {
      type: String,
      required: false,
      default: null,
    },
    scope: {
      type: String,
      required: true,
      validator: (val) =>
        [FLOW_TRIGGER_TYPE_MERGE_REQUEST.value, FLOW_TRIGGER_TYPE_WORK_ITEM.value].includes(val),
    },
    field: {
      type: String,
      required: true,
      validator: (val) => val === FILTER_FIELD_ACTION,
    },
    // Actions are hidden when passed a truthy featureFlag field.
    actions: {
      type: Array,
      required: true,
      validator: (actions) => actions.every((a) => a.text && a.value),
    },
    cardTitle: {
      type: String,
      required: true,
    },
    listboxHeaderText: {
      type: String,
      required: true,
    },
  },
  emits: ['input'],
  computed: {
    actionOptions() {
      return this.actions
        .filter((action) => !action.featureFlag || this.glFeatures[action.featureFlag])
        .map((action) => ({ text: action.text, value: action.value }));
    },
    selectedActions() {
      return parseFilterRuleValues({
        filter: this.value,
        scope: this.scope,
        field: this.field,
        options: this.actions,
      });
    },
    toggleText() {
      if (!this.selectedActions.length) {
        return s__('DuoAgentsPlatform|Select a condition');
      }
      return this.actions
        .filter((action) => this.selectedActions.includes(action.value))
        .map((action) => action.text)
        .join(', ');
    },
  },
  methods: {
    setSelectedActions(newSelected) {
      const nextValue = omit(this.value, this.scope);
      if (newSelected.length > 0) {
        nextValue[this.scope] = {
          rules: [
            {
              field: this.field,
              operator: FILTER_OPERATOR_IN,
              value: newSelected,
            },
          ],
        };
      }
      this.$emit('input', nextValue);
    },
  },
};
</script>

<template>
  <gl-card>
    <template #header>
      <h2 class="gl-m-0 gl-text-base gl-font-semibold">{{ cardTitle }}</h2>
    </template>
    <gl-form-group
      :label="s__('DuoAgentsPlatform|Trigger when')"
      :state="!invalidFeedback"
      :invalid-feedback="invalidFeedback"
      class="gl-mb-0"
    >
      <gl-collapsible-listbox
        :items="actionOptions"
        :selected="selectedActions"
        :toggle-text="toggleText"
        :state="!invalidFeedback"
        :header-text="listboxHeaderText"
        multiple
        block
        @select="setSelectedActions"
      />
    </gl-form-group>
  </gl-card>
</template>
