<script>
import { GlCard, GlCollapsibleListbox, GlFormGroup } from '@gitlab/ui';
import { omit } from 'lodash-es';
import { s__ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import {
  FILTER_FIELD_MERGE_REQUEST_ACTION,
  FILTER_OPERATOR_IN,
  FLOW_TRIGGER_TYPE_MERGE_REQUEST,
  MERGE_REQUEST_ACTIONS,
} from 'ee/ai/duo_agents_platform/constants';
import { parseMergeRequestActionFilter } from 'ee/ai/duo_agents_platform/utils';

export default {
  name: 'MergeRequestEventsConfiguration',
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
  },
  emits: ['input'],
  computed: {
    actionOptions() {
      return MERGE_REQUEST_ACTIONS.filter(
        (action) => !action.featureFlag || this.glFeatures[action.featureFlag],
      ).map((action) => ({ text: action.text, value: action.value }));
    },
    selectedActions() {
      return parseMergeRequestActionFilter(this.value);
    },
    toggleText() {
      if (!this.selectedActions.length) {
        return s__('DuoAgentsPlatform|Select a condition');
      }
      return MERGE_REQUEST_ACTIONS.filter((action) => this.selectedActions.includes(action.value))
        .map((action) => action.text)
        .join(', ');
    },
  },
  methods: {
    setSelectedActions(newSelected) {
      const nextValue = omit(this.value, FLOW_TRIGGER_TYPE_MERGE_REQUEST.value);
      if (newSelected.length > 0) {
        nextValue[FLOW_TRIGGER_TYPE_MERGE_REQUEST.value] = {
          rules: [
            {
              field: FILTER_FIELD_MERGE_REQUEST_ACTION,
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
      <h4 class="gl-m-0 gl-text-base gl-font-semibold">
        {{ s__('DuoAgentsPlatform|Merge request events configuration') }}
      </h4>
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
        :header-text="s__('DuoAgentsPlatform|Select merge request actions')"
        multiple
        block
        @select="setSelectedActions"
      />
    </gl-form-group>
  </gl-card>
</template>
