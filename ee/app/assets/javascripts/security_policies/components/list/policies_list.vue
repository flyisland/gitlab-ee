<script>
import {
  GlButton,
  GlBreadcrumb,
  GlCollapsibleListbox,
  GlEmptyState,
  GlSearchBoxByType,
} from '@gitlab/ui';
import { s__ } from '~/locale';
import { SUMMARY_TILES } from '../../constants';
import SummaryTile from './summary_tile.vue';
import StatsBar from './stats_bar.vue';
import PolicyRow from './policy_row.vue';

export default {
  name: 'PoliciesList',
  components: {
    GlButton,
    GlBreadcrumb,
    GlCollapsibleListbox,
    GlEmptyState,
    GlSearchBoxByType,
    SummaryTile,
    StatsBar,
    PolicyRow,
  },
  i18n: {
    newPolicy: s__('SecurityOrchestration|New Policy'),
    policies: s__('SecurityOrchestration|Policies'),
    subtitle: s__(
      'SecurityOrchestration|Secure your software development lifecycle with enterprise security policies',
    ),
    filterPlaceholder: s__('SecurityOrchestration|Filter policies...'),
    noPoliciesFound: s__('SecurityOrchestration|No policies found'),
    createFirstPolicy: s__(
      'SecurityOrchestration|Create your first security policy to get started.',
    ),
  },
  emits: ['create', 'edit', 'delete'],
  data() {
    return {
      summaryTiles: SUMMARY_TILES,
      searchQuery: '',
      selectedType: null,
      selectedStatus: null,
      selectedPriority: null,
      typeOptions: [
        { value: null, text: s__('SecurityOrchestration|All Policies') },
        { value: 'scan_execution', text: s__('SecurityOrchestration|Scan Execution') },
        { value: 'scan_result', text: s__('SecurityOrchestration|Scan Result') },
      ],
      statusOptions: [
        { value: null, text: s__('SecurityOrchestration|All Statuses') },
        { value: 'active', text: s__('SecurityOrchestration|Active') },
        { value: 'inactive', text: s__('SecurityOrchestration|Inactive') },
      ],
      priorityOptions: [
        { value: null, text: s__('SecurityOrchestration|All Priorities') },
        { value: 'high', text: s__('SecurityOrchestration|High') },
        { value: 'medium', text: s__('SecurityOrchestration|Medium') },
        { value: 'low', text: s__('SecurityOrchestration|Low') },
      ],
      statsData: [
        {
          icon: 'shield',
          count: 0,
          label: s__('SecurityOrchestration|Total Policies'),
          variant: 'default',
        },
        {
          icon: 'notifications',
          count: 0,
          label: s__('SecurityOrchestration|Alerts'),
          variant: 'warning',
        },
        {
          icon: 'check-circle',
          count: 0,
          label: s__('SecurityOrchestration|Active'),
          variant: 'success',
        },
        {
          icon: 'warning',
          count: 0,
          label: s__('SecurityOrchestration|Warnings'),
          variant: 'warning',
        },
      ],
      policies: [],
      breadcrumbItems: [{ text: s__('SecurityOrchestration|Policies') }],
    };
  },
};
</script>

<template>
  <div class="gl-px-4 gl-py-5">
    <div class="gl-mb-2 gl-flex gl-items-center gl-justify-between">
      <gl-breadcrumb :items="breadcrumbItems" />
      <gl-button variant="confirm" @click="$emit('create')">{{
        $options.i18n.newPolicy
      }}</gl-button>
    </div>
    <h1 class="gl-heading-1 gl-mb-1">{{ $options.i18n.policies }}</h1>
    <p class="gl-mb-5 gl-text-secondary">
      {{ $options.i18n.subtitle }}
    </p>

    <div class="gl-mb-5 gl-grid gl-grid-cols-3 gl-gap-4">
      <summary-tile
        v-for="tile in summaryTiles"
        :key="tile.id"
        :title="tile.title"
        :count="0"
        :action-label="tile.actionLabel"
      />
    </div>

    <stats-bar :stats="statsData" class="gl-mb-5" />

    <div class="gl-mb-4 gl-flex gl-items-center gl-gap-3">
      <gl-collapsible-listbox v-model="selectedType" :items="typeOptions" />
      <gl-collapsible-listbox v-model="selectedStatus" :items="statusOptions" />
      <gl-collapsible-listbox v-model="selectedPriority" :items="priorityOptions" />
      <gl-search-box-by-type
        v-model="searchQuery"
        :placeholder="$options.i18n.filterPlaceholder"
        class="gl-flex-1"
      />
    </div>

    <div v-if="policies.length > 0">
      <policy-row
        v-for="policy in policies"
        :key="policy.id"
        :policy="policy"
        @edit="$emit('edit', $event)"
        @delete="$emit('delete', $event)"
      />
    </div>
    <gl-empty-state
      v-else
      :title="$options.i18n.noPoliciesFound"
      :description="$options.i18n.createFirstPolicy"
    >
      <template #actions>
        <gl-button variant="confirm" @click="$emit('create')">{{
          $options.i18n.newPolicy
        }}</gl-button>
      </template>
    </gl-empty-state>
  </div>
</template>
