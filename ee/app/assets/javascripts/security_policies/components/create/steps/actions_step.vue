<script>
import { GlButton, GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import SelectableCard from '../selectable_card.vue';
import GenericConfig from '../generic_config.vue';
import { ACTION_TYPES } from '../../../constants';

let nextId = 1;

export default {
  name: 'ActionsStep',
  components: { GlButton, GlIcon, SelectableCard, GenericConfig },
  i18n: {
    and: s__('SecurityOrchestration|AND'),
    or: s__('SecurityOrchestration|OR'),
    noConfigRequired: s__(
      'SecurityOrchestration|No additional configuration required for this action type.',
    ),
    noActionsYet: s__(
      'SecurityOrchestration|No actions added yet. Add actions below to define policy responses.',
    ),
    addAction: s__('SecurityOrchestration|Add Action'),
    back: s__('SecurityOrchestration|← Back'),
    savePolicy: s__('SecurityOrchestration|Save Policy'),
  },
  props: {
    value: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  emits: ['input', 'back', 'submit'],
  data() {
    return {
      actionTypes: ACTION_TYPES,
      addedActions: this.value.map((a, i) => {
        const id = nextId;
        nextId += 1;
        return {
          id,
          actionId: a.actionId,
          config: a.config || {},
          isExpanded: false,
          operator: i > 0 ? a.operator || 'AND' : null,
        };
      }),
      lastAddedActionId: null,
    };
  },
  methods: {
    addActionById(actionId) {
      const id = nextId;
      nextId += 1;
      this.addedActions.push({
        id,
        actionId,
        config: {},
        isExpanded: true,
        operator: this.addedActions.length > 0 ? 'AND' : null,
      });
      this.lastAddedActionId = actionId;
      this.emitActions();
    },
    removeAction(idx) {
      this.addedActions.splice(idx, 1);
      if (this.addedActions.length > 0 && this.addedActions[0].operator !== null) {
        this.addedActions[0].operator = null;
      }
      this.emitActions();
    },
    toggleAction(idx) {
      this.addedActions[idx].isExpanded = !this.addedActions[idx].isExpanded;
    },
    setOperator(idx, op) {
      this.addedActions[idx].operator = op;
      this.emitActions();
    },
    updateActionConfig(idx, config) {
      this.addedActions[idx].config = config;
      this.emitActions();
    },
    emitActions() {
      this.$emit(
        'input',
        this.addedActions.map((a) => ({
          actionId: a.actionId,
          config: a.config,
          operator: a.operator,
        })),
      );
    },
    getActionLabel(actionId) {
      return ACTION_TYPES.find((a) => a.id === actionId)?.label ?? actionId;
    },
    getActionIcon(actionId) {
      return ACTION_TYPES.find((a) => a.id === actionId)?.icon ?? 'cog';
    },
    getActionFields(actionId) {
      return ACTION_TYPES.find((a) => a.id === actionId)?.fields ?? [];
    },
  },
};
</script>

<template>
  <div class="gl-flex gl-flex-col gl-gap-6">
    <div v-if="addedActions.length > 0">
      <template v-for="(action, idx) in addedActions">
        <div v-if="idx > 0" :key="`op-${action.id}`" class="gl-my-2 gl-flex gl-gap-2 gl-pl-2">
          <gl-button
            size="small"
            :variant="action.operator === 'AND' ? 'confirm' : 'default'"
            @click="setOperator(idx, 'AND')"
            >{{ $options.i18n.and }}</gl-button
          >
          <gl-button
            size="small"
            :variant="action.operator === 'OR' ? 'confirm' : 'default'"
            @click="setOperator(idx, 'OR')"
            >{{ $options.i18n.or }}</gl-button
          >
        </div>

        <div
          :key="`action-${action.id}`"
          class="gl-border gl-overflow-hidden gl-rounded-base gl-border-default"
        >
          <div
            class="gl-flex gl-cursor-pointer gl-items-center gl-justify-between gl-p-4 hover:gl-bg-subtle"
            @click="toggleAction(idx)"
          >
            <div class="gl-flex gl-items-center gl-gap-3">
              <gl-icon :name="getActionIcon(action.actionId)" class="gl-text-secondary" />
              <span class="gl-font-bold">{{ getActionLabel(action.actionId) }}</span>
            </div>
            <div class="gl-flex gl-items-center gl-gap-2" @click.stop>
              <gl-button
                icon="close"
                category="tertiary"
                size="small"
                :aria-label="`Remove ${getActionLabel(action.actionId)}`"
                @click="removeAction(idx)"
              />
              <gl-icon :name="action.isExpanded ? 'chevron-up' : 'chevron-down'" />
            </div>
          </div>

          <div v-if="action.isExpanded" class="gl-border-t gl-border-default gl-p-4">
            <generic-config
              v-if="getActionFields(action.actionId).length"
              :fields="getActionFields(action.actionId)"
              :value="action.config"
              @input="updateActionConfig(idx, $event)"
            />
            <p v-else class="gl-mb-0 gl-text-sm gl-text-secondary">
              {{ $options.i18n.noConfigRequired }}
            </p>
          </div>
        </div>
      </template>
    </div>
    <p v-else class="gl-my-0 gl-text-secondary">
      {{ $options.i18n.noActionsYet }}
    </p>

    <div>
      <h3 class="gl-heading-3 gl-mb-4">{{ $options.i18n.addAction }}</h3>
      <div class="gl-grid gl-grid-cols-2 gl-gap-3">
        <selectable-card
          v-for="action in actionTypes"
          :key="action.id"
          :item="action"
          :selected="lastAddedActionId === action.id"
          @select="addActionById"
        />
      </div>
    </div>

    <div class="gl-flex gl-justify-between">
      <gl-button @click="$emit('back')">{{ $options.i18n.back }}</gl-button>
      <gl-button variant="confirm" @click="$emit('submit')">{{
        $options.i18n.savePolicy
      }}</gl-button>
    </div>
  </div>
</template>
