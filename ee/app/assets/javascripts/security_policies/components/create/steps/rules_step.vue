<script>
import { GlButton, GlBadge, GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import SelectableCard from '../selectable_card.vue';
import GenericConfig from '../generic_config.vue';
import { RULE_TYPES } from '../../../constants';

let nextId = 1;

export default {
  name: 'RulesStep',
  components: { GlButton, GlBadge, GlIcon, SelectableCard, GenericConfig },
  i18n: {
    and: s__('SecurityOrchestration|AND'),
    or: s__('SecurityOrchestration|OR'),
    conditions: s__('SecurityOrchestration|0 conditions'),
    noConfigRequired: s__(
      'SecurityOrchestration|No additional configuration required for this rule type.',
    ),
    noRulesYet: s__(
      'SecurityOrchestration|No rules added yet. Add rules below to define policy conditions.',
    ),
    addRule: s__('SecurityOrchestration|Add Rule'),
    back: s__('SecurityOrchestration|← Back'),
    next: s__('SecurityOrchestration|Next'),
  },
  props: {
    value: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  emits: ['input', 'back', 'next'],
  data() {
    return {
      addedRules: this.value.map((r, i) => {
        const id = nextId;
        nextId += 1;
        return {
          id,
          ruleId: r.ruleId,
          config: r.config || {},
          isExpanded: false,
          operator: i > 0 ? r.operator || 'AND' : null,
        };
      }),
      lastAddedRuleId: null,
    };
  },
  computed: {
    customRule() {
      return RULE_TYPES.find((r) => r.id === 'custom_rule');
    },
    regularRules() {
      return RULE_TYPES.filter((r) => r.id !== 'custom_rule');
    },
  },
  methods: {
    addRuleById(ruleId) {
      const id = nextId;
      nextId += 1;
      this.addedRules.push({
        id,
        ruleId,
        config: {},
        isExpanded: true,
        operator: this.addedRules.length > 0 ? 'AND' : null,
      });
      this.lastAddedRuleId = ruleId;
      this.emitRules();
    },
    removeRule(idx) {
      this.addedRules.splice(idx, 1);
      if (this.addedRules.length > 0 && this.addedRules[0].operator !== null) {
        this.addedRules[0].operator = null;
      }
      this.emitRules();
    },
    toggleRule(idx) {
      this.addedRules[idx].isExpanded = !this.addedRules[idx].isExpanded;
    },
    setOperator(idx, op) {
      this.addedRules[idx].operator = op;
      this.emitRules();
    },
    updateRuleConfig(idx, config) {
      this.addedRules[idx].config = config;
      this.emitRules();
    },
    emitRules() {
      this.$emit(
        'input',
        this.addedRules.map((r) => ({ ruleId: r.ruleId, config: r.config, operator: r.operator })),
      );
    },
    getRuleLabel(ruleId) {
      return RULE_TYPES.find((r) => r.id === ruleId)?.label ?? ruleId;
    },
    getRuleIcon(ruleId) {
      return RULE_TYPES.find((r) => r.id === ruleId)?.icon ?? 'shield';
    },
    getRuleFields(ruleId) {
      return RULE_TYPES.find((r) => r.id === ruleId)?.fields ?? [];
    },
  },
};
</script>

<template>
  <div class="gl-flex gl-flex-col gl-gap-6">
    <div v-if="addedRules.length > 0">
      <template v-for="(rule, idx) in addedRules">
        <div v-if="idx > 0" :key="`op-${rule.id}`" class="gl-my-2 gl-flex gl-gap-2 gl-pl-2">
          <gl-button
            size="small"
            :variant="rule.operator === 'AND' ? 'confirm' : 'default'"
            @click="setOperator(idx, 'AND')"
            >{{ $options.i18n.and }}</gl-button
          >
          <gl-button
            size="small"
            :variant="rule.operator === 'OR' ? 'confirm' : 'default'"
            @click="setOperator(idx, 'OR')"
            >{{ $options.i18n.or }}</gl-button
          >
        </div>

        <div
          :key="`rule-${rule.id}`"
          class="gl-border gl-overflow-hidden gl-rounded-base gl-border-default"
        >
          <div
            class="gl-flex gl-cursor-pointer gl-items-center gl-justify-between gl-p-4 hover:gl-bg-subtle"
            @click="toggleRule(idx)"
          >
            <div class="gl-flex gl-items-center gl-gap-3">
              <gl-icon :name="getRuleIcon(rule.ruleId)" class="gl-text-secondary" />
              <span class="gl-font-bold">{{ getRuleLabel(rule.ruleId) }}</span>
              <gl-badge variant="neutral" size="sm">{{ $options.i18n.conditions }}</gl-badge>
            </div>
            <div class="gl-flex gl-items-center gl-gap-2" @click.stop>
              <gl-button
                icon="close"
                category="tertiary"
                size="small"
                :aria-label="`Remove ${getRuleLabel(rule.ruleId)}`"
                @click="removeRule(idx)"
              />
              <gl-icon :name="rule.isExpanded ? 'chevron-up' : 'chevron-down'" />
            </div>
          </div>

          <div v-if="rule.isExpanded" class="gl-border-t gl-border-default gl-p-4">
            <generic-config
              v-if="getRuleFields(rule.ruleId).length"
              :fields="getRuleFields(rule.ruleId)"
              :value="rule.config"
              @input="updateRuleConfig(idx, $event)"
            />
            <p v-else class="gl-mb-0 gl-text-sm gl-text-secondary">
              {{ $options.i18n.noConfigRequired }}
            </p>
          </div>
        </div>
      </template>
    </div>
    <p v-else class="gl-my-0 gl-text-secondary">
      {{ $options.i18n.noRulesYet }}
    </p>

    <div>
      <h3 class="gl-heading-3 gl-mb-4">{{ $options.i18n.addRule }}</h3>

      <div class="gl-mb-4">
        <selectable-card
          :item="customRule"
          :selected="lastAddedRuleId === customRule.id"
          @select="addRuleById"
        />
      </div>

      <div class="gl-grid gl-grid-cols-2 gl-gap-3">
        <selectable-card
          v-for="rule in regularRules"
          :key="rule.id"
          :item="rule"
          :selected="lastAddedRuleId === rule.id"
          @select="addRuleById"
        />
      </div>
    </div>

    <div class="gl-flex gl-justify-between">
      <gl-button @click="$emit('back')">{{ $options.i18n.back }}</gl-button>
      <gl-button variant="confirm" @click="$emit('next')">{{ $options.i18n.next }}</gl-button>
    </div>
  </div>
</template>
