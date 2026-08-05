<script>
import { GlBadge, GlTableLite } from '@gitlab/ui';
import { s__ } from '~/locale';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import {
  TH_CLASS,
  TD_CLASS,
  ROW_CLASS,
  ROW_OPEN_CLASS,
  ROW_SELECTED_CLASS,
  ROLLOUT_STATE_VARIANTS,
  ROLLOUT_STATE_LABELS,
} from '../constants';

export default {
  name: 'ReleasesTable',
  components: {
    GlBadge,
    GlTableLite,
    TimeAgo,
  },
  props: {
    releases: {
      type: Array,
      required: true,
    },
    full: {
      type: Boolean,
      required: false,
      default: false,
    },
    selectedId: {
      type: String,
      required: false,
      default: null,
    },
    openId: {
      type: String,
      required: false,
      default: null,
    },
  },
  emits: ['select'],
  computed: {
    fields() {
      const base = [
        {
          key: 'name',
          label: s__('ContinuousDeployment|Version'),
          tdClass: TD_CLASS,
          thClass: TH_CLASS,
        },
        {
          key: 'status',
          label: s__('ContinuousDeployment|Status'),
          tdClass: TD_CLASS,
          thClass: TH_CLASS,
        },
      ];
      if (this.full) {
        base.push(
          {
            key: 'services',
            label: s__('ContinuousDeployment|Services'),
            tdClass: TD_CLASS,
            thClass: TH_CLASS,
          },
          {
            key: 'createdAt',
            label: s__('ContinuousDeployment|Created'),
            tdClass: `${TD_CLASS} gl-whitespace-nowrap gl-text-right !gl-text-secondary`,
            thClass: `${TH_CLASS} gl-whitespace-nowrap gl-text-right`,
          },
        );
      }
      return base;
    },
  },
  methods: {
    servicesCount(release) {
      return release.versionSetEntries?.count ?? 0;
    },
    rolloutState(release) {
      return release.rollouts?.nodes?.[0]?.state ?? null;
    },
    statusVariant(release) {
      return ROLLOUT_STATE_VARIANTS[this.rolloutState(release)] ?? 'neutral';
    },
    statusLabel(release) {
      return ROLLOUT_STATE_LABELS[this.rolloutState(release)] ?? '';
    },
    rowClass(item) {
      if (item?.id === this.openId) {
        return [ROW_CLASS, ROW_OPEN_CLASS];
      }
      if (item?.id === this.selectedId) {
        return [ROW_CLASS, ROW_SELECTED_CLASS];
      }
      return ROW_CLASS;
    },
  },
};
</script>

<template>
  <gl-table-lite
    :items="releases"
    :fields="fields"
    stacked="sm"
    :tbody-tr-class="rowClass"
    data-testid="releases-table"
    @row-clicked="$emit('select', $event)"
  >
    <template #cell(status)="{ item }">
      <gl-badge v-if="statusLabel(item)" :variant="statusVariant(item)">
        {{ statusLabel(item) }}
      </gl-badge>
    </template>
    <template v-if="full" #cell(services)="{ item }">
      {{ servicesCount(item) }}
    </template>
    <template v-if="full" #cell(createdAt)="{ item }">
      <time-ago v-if="item.createdAt" :time="item.createdAt" />
    </template>
  </gl-table-lite>
</template>
