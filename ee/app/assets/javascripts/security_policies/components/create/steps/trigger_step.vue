<script>
import { GlButton } from '@gitlab/ui';
import { s__ } from '~/locale';
import SelectableCard from '../selectable_card.vue';
import GenericConfig from '../generic_config.vue';
import { TRIGGER_TYPES } from '../../../constants';

export default {
  name: 'TriggerStep',
  components: { GlButton, SelectableCard, GenericConfig },
  i18n: {
    configuration: s__('SecurityOrchestration|Configuration'),
    back: s__('SecurityOrchestration|← Back'),
    next: s__('SecurityOrchestration|Next'),
  },
  props: {
    value: {
      type: Object,
      required: true,
    },
  },
  emits: ['input', 'back', 'next'],
  data() {
    return {
      triggerTypes: TRIGGER_TYPES,
      selectedTriggerId: this.value.triggerId || null,
      localConfig: this.value.config || {},
    };
  },
  computed: {
    selectedTrigger() {
      return this.triggerTypes.find((t) => t.id === this.selectedTriggerId);
    },
  },
  methods: {
    selectTrigger(id) {
      this.selectedTriggerId = id;
      this.localConfig = {};
      this.$emit('input', { triggerId: id, config: {} });
    },
    updateConfig(config) {
      this.localConfig = config;
      this.$emit('input', { triggerId: this.selectedTriggerId, config });
    },
  },
};
</script>

<template>
  <div class="gl-flex gl-flex-col gl-gap-5">
    <div class="gl-grid gl-grid-cols-2 gl-gap-3">
      <selectable-card
        v-for="trigger in triggerTypes"
        :key="trigger.id"
        :item="trigger"
        :selected="selectedTriggerId === trigger.id"
        @select="selectTrigger"
      />
    </div>

    <div
      v-if="selectedTrigger && selectedTrigger.fields && selectedTrigger.fields.length"
      class="gl-border gl-rounded-base gl-border-default gl-p-4"
    >
      <h3 class="gl-heading-3 gl-mb-4">
        {{ selectedTrigger.label }} {{ $options.i18n.configuration }}
      </h3>
      <generic-config :fields="selectedTrigger.fields" :value="localConfig" @input="updateConfig" />
    </div>

    <div class="gl-flex gl-justify-between">
      <gl-button @click="$emit('back')">{{ $options.i18n.back }}</gl-button>
      <gl-button variant="confirm" :disabled="!selectedTriggerId" @click="$emit('next')">{{
        $options.i18n.next
      }}</gl-button>
    </div>
  </div>
</template>
