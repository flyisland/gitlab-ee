<script>
import { GlCard, GlIcon } from '@gitlab/ui';
import { mapState } from 'vuex';
import { isUndefined } from 'lodash-es';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import {
  PERFORMANCE_TYPE_INDICATOR_TEXT,
  PERFORMANCE_TYPE_CLOSED_ISSUES,
  PERFORMANCE_TYPE_COMMITS_NUMBER,
  PERFORMANCE_TYPE_MERGED_REQUESTS,
  PERFORMANCE_TYPE_PER_CAPITA_COMMITS,
  PERFORMANCE_TYPE_INDICATOR_ICONS,
  PERFORMANCE_TYPE_PUSH_TEXTS,
} from 'jh/analytics/performance_analytics/constants';

export default {
  name: 'PerformanceCards',
  components: {
    GlCard,
    GlIcon,
  },
  computed: {
    ...mapState({
      isGroup: (state) => state.isGroup,
      summaryData: (state) => state.summaryData,
    }),
    keyIndicatorList() {
      const displayIndicators = [
        PERFORMANCE_TYPE_CLOSED_ISSUES,
        PERFORMANCE_TYPE_COMMITS_NUMBER,
        PERFORMANCE_TYPE_MERGED_REQUESTS,
        PERFORMANCE_TYPE_PER_CAPITA_COMMITS,
      ];

      const camelCaseSummaryData = convertObjectPropsToCamelCase(this.summaryData);
      return displayIndicators.map((item) => {
        let title = PERFORMANCE_TYPE_INDICATOR_TEXT[item];
        if (this.isGroup && !isUndefined(PERFORMANCE_TYPE_PUSH_TEXTS[item])) {
          title = PERFORMANCE_TYPE_PUSH_TEXTS[item];
        }
        return {
          key: item,
          title,
          value: camelCaseSummaryData[item] || 0,
        };
      });
    },
  },
  icons: PERFORMANCE_TYPE_INDICATOR_ICONS,
};
</script>

<template>
  <div class="performance-card gl-flex" data-testid="performance-card">
    <gl-card
      v-for="item in keyIndicatorList"
      :key="item.key"
      class="card gl-mb-6"
      :data-testid="item.key"
      body-class="gl-py-3"
    >
      <template #header>
        <div class="gl-flex">
          <gl-icon :name="$options.icons[item.key]" />
          <h5 class="gl-my-0 gl-ml-3">{{ item.title }}</h5>
        </div>
      </template>
      <template #default>
        <div
          class="card-count gl-flex gl-items-center gl-justify-center gl-text-center gl-text-size-h-display gl-font-bold"
          data-testid="performance-card-value"
        >
          {{ item.value }}
        </div>
      </template>
    </gl-card>
  </div>
</template>
