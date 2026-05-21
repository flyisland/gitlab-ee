<script>
import { GlSprintf } from '@gitlab/ui';
import {
  CRITICAL,
  HIGH,
  MEDIUM,
  LOW,
  INFO,
  UNKNOWN,
  SEVERITY_COUNT_LIMIT,
} from 'ee/vulnerabilities/constants';
import { s__, sprintf } from '~/locale';

const SEVERITY_ITEMS = [
  { key: 'critical', cssClass: 'severity-text-critical' },
  { key: 'high', cssClass: 'severity-text-high' },
  { key: 'other' },
];

export default {
  name: 'SummaryHighlights',
  components: {
    GlSprintf,
  },
  i18n: {
    critical: s__('ciReport|critical'),
    high: s__('ciReport|high'),
    other: s__('ciReport|others'),
    oneSeverity: s__('ciReport|%{firstSeverityStart}count severity%{firstSeverityEnd}'),
    twoSeverities: s__(
      'ciReport|%{firstSeverityStart}count severity%{firstSeverityEnd} and %{secondSeverityStart}count severity%{secondSeverityEnd}',
    ),
    threeSeverities: s__(
      'ciReport|%{firstSeverityStart}count severity%{firstSeverityEnd}, %{secondSeverityStart}count severity%{secondSeverityEnd}, and %{thirdSeverityStart}count severity%{thirdSeverityEnd}',
    ),
    noVulnerabilities: s__('SecurityReports|0 vulnerabilities'),
  },
  props: {
    /**
     * If provided, this will display only the count for the given severity.
     */
    showSingleSeverity: {
      type: String,
      required: false,
      default: '',
      validator: (severity) =>
        !severity || [CRITICAL, HIGH, MEDIUM, LOW, INFO, UNKNOWN].includes(severity),
    },
    highlights: {
      type: Object,
      required: true,
      validator: (highlights) =>
        [CRITICAL, HIGH].every((requiredField) => {
          if (typeof highlights[requiredField] === 'undefined') {
            return true;
          }

          return Number.isInteger(highlights[requiredField]);
        }),
    },
    capped: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    criticalSeverityCount() {
      return this.formattedCounts(this.highlights[CRITICAL]);
    },
    highSeverityCount() {
      return this.formattedCounts(this.highlights[HIGH]);
    },
    otherSeverityCount() {
      if (typeof this.highlights.other !== 'undefined') {
        return this.formattedCounts(this.highlights.other);
      }

      let totalCounts = 0;
      let isCapped = false;

      [MEDIUM, LOW, INFO, UNKNOWN].forEach((severity) => {
        const count = this.highlights[severity];

        if (count) {
          totalCounts += count;
        }

        if (this.capped && count > SEVERITY_COUNT_LIMIT) {
          isCapped = true;
        }
      });

      return isCapped ? this.formattedCounts(totalCounts) : totalCounts;
    },
    severityItems() {
      const counts = {
        critical: this.criticalSeverityCount,
        high: this.highSeverityCount,
        other: this.otherSeverityCount,
      };

      return SEVERITY_ITEMS.map((item) => {
        const count = counts[item.key];
        return {
          ...item,
          count,
          cssClass: this.getCssClass(item, count),
        };
      });
    },
    visibleSeverityItems() {
      return this.severityItems.filter((item) => this.isPositiveCount(item.count));
    },
    totalCount() {
      return [this.criticalSeverityCount, this.highSeverityCount, this.otherSeverityCount].reduce(
        (sum, count) => sum + (parseInt(count, 10) || 0),
        0,
      );
    },
    hasNoVulnerabilities() {
      return this.totalCount === 0;
    },
    singleSeverityCount() {
      return this.highlights[this.showSingleSeverity] ?? 0;
    },
    severityMessage() {
      const { oneSeverity, twoSeverities, threeSeverities } = this.$options.i18n;
      return [oneSeverity, twoSeverities, threeSeverities][this.visibleSeverityItems.length - 1];
    },
  },
  methods: {
    getCssClass(item, count) {
      return item.cssClass || (this.isPositiveCount(count) ? 'gl-text-subtle' : 'gl-text-disabled');
    },
    formattedCounts(count) {
      if (this.capped) {
        return count > SEVERITY_COUNT_LIMIT
          ? sprintf(s__('SecurityReports|%{count}+'), { count: SEVERITY_COUNT_LIMIT })
          : count;
      }

      return count;
    },
    isPositiveCount(count) {
      return parseInt(count, 10) > 0;
    },
    severityText(item) {
      return `${item.count} ${this.$options.i18n[item.key]}`;
    },
    slotName(index) {
      return ['firstSeverity', 'secondSeverity', 'thirdSeverity'][index];
    },
    emphasisTag(count) {
      if (this.isPositiveCount(count)) {
        return 'strong';
      }

      return 'span';
    },
  },
};
</script>

<template>
  <div class="gl-text-sm">
    <component
      :is="emphasisTag(singleSeverityCount)"
      v-if="showSingleSeverity"
      :class="`severity-text-${showSingleSeverity}`"
    >
      {{ formattedCounts(singleSeverityCount) }}
      {{ n__('vulnerability', 'vulnerabilities', singleSeverityCount) }}
    </component>

    <span v-else-if="hasNoVulnerabilities" class="gl-text-disabled">
      {{ $options.i18n.noVulnerabilities }}
    </span>

    <gl-sprintf v-else :message="severityMessage">
      <template v-for="(item, index) in visibleSeverityItems" #[slotName(index)]>
        <component
          :is="emphasisTag(item.count)"
          :key="item.key"
          :class="item.cssClass"
          :data-testid="item.key"
          >{{ severityText(item) }}</component
        >
      </template>
    </gl-sprintf>
  </div>
</template>
