<script>
import { GlCollapsibleListbox } from '@gitlab/ui';
import { isEqual, uniqueId } from 'lodash-es';
import { s__, sprintf } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import {
  FLOW_TRIGGER_TYPES,
  FLOW_TRIGGER_TYPE_MERGE_REQUEST,
  FLOW_TRIGGER_TYPE_PIPELINE_HOOKS,
} from 'ee/ai/duo_agents_platform/constants';
import {
  parseMergeRequestActionFilter,
  parsePipelineStatusFilter,
} from 'ee/ai/duo_agents_platform/utils';
import MergeRequestEventsConfiguration from './event_configurations/merge_request_events_configuration.vue';
import PipelineEventsConfiguration from './event_configurations/pipeline_events_configuration.vue';

const EVENT_CONFIGURATIONS = {
  [FLOW_TRIGGER_TYPE_PIPELINE_HOOKS.value]: {
    component: PipelineEventsConfiguration,
    isValid: (filter) => parsePipelineStatusFilter(filter).length > 0,
    invalidFeedback: () => s__('DuoAgentsPlatform|Select at least one pipeline event.'),
  },
  [FLOW_TRIGGER_TYPE_MERGE_REQUEST.value]: {
    component: MergeRequestEventsConfiguration,
    isValid: (filter) => parseMergeRequestActionFilter(filter).length > 0,
    invalidFeedback: () => s__('DuoAgentsPlatform|Select at least one merge request action.'),
  },
};

const getConfigurableTypes = (values) =>
  values
    .map((value) => FLOW_TRIGGER_TYPES.find((type) => type.value === value))
    .filter((type) => type && EVENT_CONFIGURATIONS[type.value]);

export default {
  name: 'FlowTriggerEventsField',
  components: {
    GlCollapsibleListbox,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    eventTypes: {
      type: Array,
      required: false,
      default: () => [],
    },
    filter: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    state: {
      type: Boolean,
      required: false,
      default: null,
    },
    showErrors: {
      type: Boolean,
      required: false,
      default: false,
    },
    listboxId: {
      type: String,
      required: false,
      default: () => uniqueId('flow-trigger-events-'),
    },
    itemTypeLabel: {
      type: String,
      required: true,
    },
  },
  emits: ['update:event-types', 'update:filter', 'update:filter-valid', 'blur'],
  computed: {
    eventTypeOptions() {
      return FLOW_TRIGGER_TYPES.filter((item) => {
        if (item.isAvailable) return item.isAvailable(this.glFeatures);
        if (item.featureFlag) return Boolean(this.glFeatures[item.featureFlag]);
        return true;
      }).map((item) => ({
        text: item.text,
        value: item.value,
        description: item.description
          ? sprintf(item.description, { itemType: this.itemTypeLabel })
          : undefined,
      }));
    },
    configurableEventTypes() {
      const enabledValues = new Set(this.eventTypeOptions.map((option) => option.value));
      return getConfigurableTypes(this.eventTypes)
        .filter((type) => enabledValues.has(type.value))
        .map((type) => ({
          ...type,
          configuration: EVENT_CONFIGURATIONS[type.value],
        }));
    },
    selectedEventTypeText() {
      if (!this.eventTypes.length) {
        return s__('DuoAgentsPlatform|Select one or multiple event types');
      }
      return this.eventTypeOptions
        .filter((option) => this.eventTypes.includes(option.value))
        .map((option) => option.text)
        .join(', ');
    },
    isValid() {
      return this.configurableEventTypes.every((type) => type.configuration.isValid(this.filter));
    },
    displayedInvalidFeedback() {
      if (!this.showErrors) return {};
      const feedback = {};
      this.configurableEventTypes.forEach((type) => {
        if (!type.configuration.isValid(this.filter)) {
          feedback[type.value] = type.configuration.invalidFeedback();
        }
      });
      return feedback;
    },
  },
  watch: {
    isValid: {
      immediate: true,
      handler(value) {
        this.$emit('update:filter-valid', value);
      },
    },
  },
  methods: {
    onSelectEventTypes(newValues) {
      const activeScopes = getConfigurableTypes(newValues).map((type) => type.value);
      const prunedFilter = Object.fromEntries(
        Object.entries(this.filter).filter(([scope]) => activeScopes.includes(scope)),
      );

      if (!isEqual(prunedFilter, this.filter)) {
        this.$emit('update:filter', prunedFilter);
      }
      this.$emit('update:event-types', newValues);
    },
    onUpdateFilter(newFilter) {
      this.$emit('update:filter', newFilter);
    },
  },
};
</script>

<template>
  <div class="gl-flex gl-flex-col gl-gap-5">
    <gl-collapsible-listbox
      :id="listboxId"
      :items="eventTypeOptions"
      :selected="eventTypes"
      :toggle-text="selectedEventTypeText"
      :header-text="s__('DuoAgentsPlatform|Select one or multiple event types')"
      multiple
      block
      fluid-width
      :state="state"
      @select="onSelectEventTypes"
      @blur="$emit('blur')"
    >
      <template #list-item="{ item }">
        <div class="gl-flex gl-flex-col">
          <strong>{{ item.text }}</strong>
          <span v-if="item.description" class="gl-text-sm gl-text-subtle">{{
            item.description
          }}</span>
        </div>
      </template>
    </gl-collapsible-listbox>

    <component
      :is="type.configuration.component"
      v-for="type in configurableEventTypes"
      :key="type.value"
      :value="filter"
      :invalid-feedback="displayedInvalidFeedback[type.value] || null"
      @input="onUpdateFilter"
    />
  </div>
</template>
