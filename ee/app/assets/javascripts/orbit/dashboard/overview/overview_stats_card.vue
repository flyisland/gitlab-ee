<script>
import { defineComponent } from 'vue';
import { GlLoadingIcon, GlSprintf } from '@gitlab/ui';
import { formatNumber, n__, s__, sprintf } from '~/locale';
import { DOMAIN_COLORS } from 'ee/orbit/constants';
import { LOAD_STATUS, ROUTE_SCHEMA } from '../constants';
import { OVERVIEW_AREAS } from './constants';

const FAILED_STATUSES = [LOAD_STATUS.FAILED, LOAD_STATUS.FORBIDDEN];

export default defineComponent({
  name: 'OverviewStatsCard',
  compatConfig: { MODE: 3 },
  components: { GlLoadingIcon, GlSprintf },
  props: {
    groupCount: {
      type: Number,
      required: true,
    },
    graphStats: {
      type: Object,
      required: false,
      default: null,
    },
    status: {
      type: String,
      required: true,
      validator: (status) => Object.values(LOAD_STATUS).includes(status),
    },
  },
  computed: {
    isLoading() {
      return this.status === LOAD_STATUS.LOADING;
    },
    hasFailed() {
      return FAILED_STATUSES.includes(this.status);
    },
    totalMessage() {
      return n__(
        'Orbit|%{count} %{labelStart}item%{labelEnd}',
        'Orbit|%{count} %{labelStart}items%{labelEnd}',
        this.total,
      );
    },
    failureText() {
      return this.status === LOAD_STATUS.FORBIDDEN
        ? s__('Orbit|Counts are not available for your groups.')
        : s__('Orbit|Counts are not available right now. Try again later.');
    },
    total() {
      return this.graphStats.getTotalIndexedNodes();
    },
    formattedTotal() {
      return formatNumber(this.total);
    },
    domainTotals() {
      return this.graphStats.getDomainTotals();
    },
    areas() {
      return OVERVIEW_AREAS.map((area) => ({
        ...area,
        color: DOMAIN_COLORS[area.key],
        count: formatNumber(this.domainTotals[area.key] ?? 0),
      }));
    },
    scopeText() {
      return sprintf(s__('Orbit|in %{groups} and %{projects}'), {
        groups: n__('%d group', '%d groups', this.groupCount),
        projects: n__('%d project', '%d projects', this.graphStats.getProjects().indexed),
      });
    },
  },
  ROUTE_SCHEMA,
});
</script>

<template>
  <div
    class="gl-border gl-rounded-lg gl-border-default gl-bg-default gl-p-4 gl-shadow-sm"
    data-testid="overview-stats-card"
  >
    <p class="gl-mb-3 gl-text-sm gl-font-bold gl-text-default">{{ s__('Orbit|In your graph') }}</p>

    <gl-loading-icon v-if="isLoading" size="md" class="gl-my-5" />

    <p
      v-else-if="hasFailed"
      class="gl-mb-3 gl-text-sm gl-text-subtle"
      data-testid="overview-stats-failed"
    >
      {{ failureText }}
    </p>

    <template v-else>
      <p class="gl-mb-1 gl-text-size-h-display gl-font-bold gl-leading-1">
        <gl-sprintf :message="totalMessage">
          <template #count>{{ formattedTotal }}</template>
          <template #label="{ content }">
            <span class="gl-text-base gl-font-normal gl-text-subtle">{{ content }}</span>
          </template>
        </gl-sprintf>
      </p>
      <p class="gl-mb-0 gl-text-sm gl-text-subtle" data-testid="overview-stats-scope">
        {{ scopeText }}
      </p>

      <hr class="gl-my-3" />

      <ul class="gl-m-0 gl-list-none gl-p-0">
        <li
          v-for="area in areas"
          :key="area.key"
          class="gl-mb-3 gl-flex gl-items-center gl-justify-between gl-gap-3 gl-text-sm"
        >
          <span class="gl-flex gl-items-center gl-gap-3">
            <span
              class="gl-inline-block gl-h-2 gl-w-2 gl-shrink-0 gl-rounded-full"
              :style="{ backgroundColor: area.color }"
            ></span>
            {{ area.label }}
          </span>
          <span class="gl-tabular-nums gl-text-default">{{ area.count }}</span>
        </li>
      </ul>
    </template>

    <router-link :to="{ name: $options.ROUTE_SCHEMA }" class="gl-text-sm">
      {{ s__('Orbit|What is in each area? View schema') }}
    </router-link>
  </div>
</template>
