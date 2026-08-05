<script>
import { GlBadge, GlTableLite } from '@gitlab/ui';
import { s__ } from '~/locale';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import {
  HEALTH_DOT_CLASSES,
  HEALTH_LABELS,
  HEALTH_VARIANTS,
  SYNC_VARIANTS,
  SYNC_LABELS,
  TH_CLASS,
  TD_CLASS,
} from '../constants';

const SERVICE_TYPE_VARIANTS = {
  'http-api': 'info',
  worker: 'neutral',
  scheduler: 'neutral',
  frontend: 'success',
};

export default {
  name: 'ServicesTable',
  components: {
    GlBadge,
    GlTableLite,
    TimeAgo,
  },
  props: {
    services: {
      type: Array,
      required: true,
    },
    full: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['select'],
  computed: {
    fields() {
      const base = [
        {
          key: 'name',
          label: s__('ContinuousDeployment|Service'),
          tdClass: TD_CLASS,
          thClass: TH_CLASS,
        },
      ];
      if (this.full) {
        base.push(
          {
            key: 'health',
            label: s__('ContinuousDeployment|Status'),
            tdClass: TD_CLASS,
            thClass: TH_CLASS,
          },
          {
            key: 'serviceType',
            label: s__('ContinuousDeployment|Type'),
            tdClass: TD_CLASS,
            thClass: TH_CLASS,
          },
          {
            key: 'sync',
            label: s__('ContinuousDeployment|Sync'),
            tdClass: TD_CLASS,
            thClass: TH_CLASS,
          },
        );
      }
      base.push({
        key: 'lastDeployed',
        label: s__('ContinuousDeployment|Deployed'),
        tdClass: `${TD_CLASS} gl-whitespace-nowrap gl-text-right !gl-text-secondary`,
        thClass: `${TH_CLASS} gl-whitespace-nowrap gl-text-right`,
      });
      return base;
    },
  },
  methods: {
    healthDotClass(health) {
      return HEALTH_DOT_CLASSES[health] ?? HEALTH_DOT_CLASSES.default;
    },
    healthLabel(health) {
      return HEALTH_LABELS[health] ?? health ?? '';
    },
    healthVariant(health) {
      return HEALTH_VARIANTS[health] ?? 'neutral';
    },
    syncLabel(value) {
      return SYNC_LABELS[value] ?? value ?? '';
    },
    syncVariant(value) {
      return SYNC_VARIANTS[value] ?? 'neutral';
    },
    serviceTypeVariant(serviceType) {
      return SERVICE_TYPE_VARIANTS[serviceType] ?? 'neutral';
    },
  },
};
</script>

<template>
  <gl-table-lite
    :items="services"
    :fields="fields"
    tbody-tr-class="gl-cursor-pointer"
    stacked="sm"
    data-testid="services-table"
    @row-clicked="$emit('select', $event)"
  >
    <template #cell(name)="{ item }">
      <span
        :class="healthDotClass(item.health)"
        class="gl-mr-2 gl-inline-block gl-h-2 gl-w-2 gl-rounded-full gl-align-middle"
        data-testid="health-dot"
      ></span>
      {{ item.name }}
    </template>
    <template v-if="full" #cell(health)="{ item }">
      <gl-badge
        v-if="healthLabel(item.health)"
        :variant="healthVariant(item.health)"
        size="sm"
        data-testid="health-badge"
        >{{ healthLabel(item.health) }}</gl-badge
      >
    </template>
    <template v-if="full" #cell(serviceType)="{ item }">
      <gl-badge
        v-if="item.serviceType"
        :variant="serviceTypeVariant(item.serviceType)"
        size="sm"
        data-testid="service-type-badge"
        >{{ item.serviceType }}</gl-badge
      >
    </template>
    <template v-if="full" #cell(sync)="{ item }">
      <gl-badge
        v-if="syncLabel(item.sync)"
        :variant="syncVariant(item.sync)"
        size="sm"
        data-testid="sync-badge"
        >{{ syncLabel(item.sync) }}</gl-badge
      >
    </template>
    <template #cell(lastDeployed)="{ item }">
      <time-ago v-if="item.lastDeployed" :time="item.lastDeployed" />
    </template>
  </gl-table-lite>
</template>
