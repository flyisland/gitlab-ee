<script>
import { s__ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import {
  RULE_TYPE_LICENSE,
  RULE_TYPE_VULNERABILITY,
  RULE_TYPE_MALICIOUS,
  RULE_TYPE_RISK_SEVERITY,
} from '../constants';
import { buildDefaultRuleForType } from '../utils';
import FixedRuleCard from '../components/fixed_rule_card.vue';

export default {
  name: 'RuleList',
  RULE_TYPE_LICENSE,
  RULE_TYPE_VULNERABILITY,
  RULE_TYPE_MALICIOUS,
  RULE_TYPE_RISK_SEVERITY,
  components: { FixedRuleCard },
  mixins: [glFeatureFlagsMixin()],
  i18n: {
    maliciousLabel: s__('SecurityOrchestration|Malicious packages'),
    // "Known vulnerabilities" is the design's name for this card regardless of which rule
    // type backs it - risk_severity once dependencyFirewallRiskSeverityRule is on, the
    // legacy vulnerability type until then. The label never switches to "Risk severity".
    knownVulnerabilitiesLabel: s__('SecurityOrchestration|Known vulnerabilities'),
    licenseLabel: s__('SecurityOrchestration|Licenses'),
  },
  props: {
    rules: {
      type: Array,
      required: true,
    },
  },
  emits: ['changed'],
  computed: {
    maliciousRule() {
      return this.findRule(RULE_TYPE_MALICIOUS);
    },
    licenseRule() {
      return this.findRule(RULE_TYPE_LICENSE);
    },
    // The risk_severity flag replaces the vulnerability card with the risk_severity card in
    // the same slot - the two are never both shown, matching the old add-rule dropdown's
    // behavior (see git history: getAddRuleTypeItems swapped one item for the other).
    riskSeverityEnabled() {
      return Boolean(this.glFeatures.dependencyFirewallRiskSeverityRule);
    },
    secondRuleType() {
      return this.riskSeverityEnabled ? RULE_TYPE_RISK_SEVERITY : RULE_TYPE_VULNERABILITY;
    },
    secondRule() {
      return this.findRule(this.secondRuleType);
    },
  },
  methods: {
    findRule(type) {
      return this.rules.find((rule) => rule.type === type) || null;
    },
    toggleRule(type, { checked, draftRule }) {
      if (checked) {
        this.$emit('changed', [...this.rules, draftRule || buildDefaultRuleForType(type)]);
      } else {
        this.$emit(
          'changed',
          this.rules.filter((rule) => rule.type !== type),
        );
      }
    },
    updateRule(type, rule) {
      this.$emit(
        'changed',
        this.rules.map((existing) => (existing.type === type ? rule : existing)),
      );
    },
  },
};
</script>

<template>
  <div class="gl-flex gl-flex-col gl-gap-4">
    <fixed-rule-card
      :type="$options.RULE_TYPE_MALICIOUS"
      :label="$options.i18n.maliciousLabel"
      :rule="maliciousRule"
      recommended
      @toggle="toggleRule($options.RULE_TYPE_MALICIOUS, $event)"
      @changed="updateRule($options.RULE_TYPE_MALICIOUS, $event)"
    />

    <fixed-rule-card
      :type="secondRuleType"
      :label="$options.i18n.knownVulnerabilitiesLabel"
      :rule="secondRule"
      @toggle="toggleRule(secondRuleType, $event)"
      @changed="updateRule(secondRuleType, $event)"
    />

    <fixed-rule-card
      :type="$options.RULE_TYPE_LICENSE"
      :label="$options.i18n.licenseLabel"
      :rule="licenseRule"
      @toggle="toggleRule($options.RULE_TYPE_LICENSE, $event)"
      @changed="updateRule($options.RULE_TYPE_LICENSE, $event)"
    />
  </div>
</template>
