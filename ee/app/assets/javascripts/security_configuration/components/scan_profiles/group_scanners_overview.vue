<script>
import { GlLink, GlSkeletonLoader, GlSprintf, GlTable } from '@gitlab/ui';
import { __, s__, sprintf, createListFormat } from '~/locale';
import ScanTypeCell from '~/security_configuration/components/scan_profiles/scan_type_cell.vue';
import SegmentedBar from 'ee/security_inventory/components/segmented_bar.vue';
import groupAvailableSecurityScanProfilesQuery from 'ee/security_configuration/graphql/scan_profiles/group_available_security_scan_profiles.query.graphql';
import groupAnalyzerStatusesQuery from 'ee/security_configuration/graphql/scan_profiles/group_analyzer_statuses.query.graphql';
import { SCAN_PROFILE_SCANNER_HEALTH_PENDING } from '~/security_configuration/constants';

export default {
  name: 'GroupScannersOverview',
  components: {
    GlLink,
    GlSkeletonLoader,
    GlSprintf,
    GlTable,
    ScanTypeCell,
    SegmentedBar,
  },
  inject: ['groupFullPath', 'securityInventoryPath'],
  apollo: {
    availableScanners: {
      query: groupAvailableSecurityScanProfilesQuery,
      variables() {
        return { fullPath: this.groupFullPath };
      },
      update: (data) => data?.group?.availableSecurityScanProfiles ?? [],
    },
    groupAnalyzerStatuses: {
      query: groupAnalyzerStatusesQuery,
      variables() {
        return { fullPath: this.groupFullPath };
      },
      update: (data) => data?.group?.analyzerStatuses ?? [],
    },
  },
  data() {
    return {
      availableScanners: [],
      groupAnalyzerStatuses: [],
    };
  },
  computed: {
    isScannerListLoading() {
      return this.$apollo.queries.availableScanners.loading;
    },
    isScannerStatusLoading() {
      return this.$apollo.queries.groupAnalyzerStatuses.loading;
    },
    statusByType() {
      return Object.fromEntries(
        this.groupAnalyzerStatuses.map((status) => [status.analyzerType, status]),
      );
    },
  },
  methods: {
    coverageSegments(item) {
      const status = this.statusByType[item.scanType];
      return [
        {
          class: 'gl-bg-green-500',
          count: status?.success ?? 0,
          template: __('%{count} active'),
        },
        {
          class: 'gl-bg-red-500',
          count: status?.failure ?? 0,
          template: __('%{count} failed'),
        },
        {
          class: 'gl-bg-status-neutral',
          count: status?.notConfigured ?? 0,
        },
      ];
    },
    coveragePercentage(item) {
      const {
        success = 0,
        failure = 0,
        notConfigured = 0,
      } = this.statusByType[item.scanType] ?? {};
      const total = success + failure + notConfigured;
      return total === 0 ? '0%' : `${Math.round((success / total) * 100)}%`;
    },
    coverageSegmentsText(item) {
      const list = this.coverageSegments(item)
        .filter(({ count, template }) => count && template)
        .map(({ count, template }) => sprintf(template, { count }));

      return createListFormat({ style: 'narrow' }).format(list);
    },
  },
  fields: [
    {
      key: 'scanType',
      label: s__('SecurityConfiguration|Scanner'),
      tdClass: '!gl-bg-default !gl-border-none',
      thClass: 'gl-w-3/8',
    },
    {
      key: 'coverage',
      label: s__('SecurityConfiguration|Project coverage'),
      tdClass: '!gl-bg-default !gl-border-none !gl-align-middle',
      thClass: 'gl-w-1/2',
    },
  ],
  SCAN_PROFILE_SCANNER_HEALTH_PENDING,
};
</script>

<template>
  <div>
    <div class="gl-mb-4 gl-mt-3">
      <gl-sprintf
        :message="
          s__(
            'SecurityConfiguration|Enable scanners, monitor health, and track coverage across your projects. For full tool coverage, visit the %{linkStart}Security Inventory%{linkEnd}.',
          )
        "
      >
        <template #link="{ content }">
          <gl-link :href="securityInventoryPath">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </div>

    <gl-table
      :fields="$options.fields"
      :items="availableScanners"
      :busy="isScannerListLoading"
      show-empty
      table-class="!gl-bg-strong gl-rounded-xl"
      borderless
    >
      <template #empty>
        <div class="gl-py-6 gl-text-center">
          <p class="gl-mb-2 gl-font-bold">
            {{ s__('SecurityConfiguration|No scanners enabled yet') }}
          </p>
          <p class="gl-mb-0 gl-text-subtle">
            {{
              s__(
                'SecurityConfiguration|Enable security scanning to automatically detect vulnerabilities in your projects.',
              )
            }}
          </p>
        </div>
      </template>
      <template #cell(scanType)="{ item }">
        <scan-type-cell
          :scan-type="item.scanType"
          :status="$options.SCAN_PROFILE_SCANNER_HEALTH_PENDING"
        />
      </template>
      <template #cell(coverage)="{ item }">
        <gl-skeleton-loader
          v-if="isScannerStatusLoading"
          :width="300"
          :height="10"
          preserve-aspect-ratio="none"
        >
          <rect x="0" y="0" width="300" height="10" rx="5" />
        </gl-skeleton-loader>
        <template v-else>
          <segmented-bar :segments="coverageSegments(item)" />
          <div class="gl-flex gl-justify-between">
            <span class="gl-text-sm gl-text-status-neutral">
              {{ coveragePercentage(item) }}
            </span>
            <span class="gl-text-sm gl-text-status-neutral">
              {{ coverageSegmentsText(item) }}
            </span>
          </div>
        </template>
      </template>
    </gl-table>
  </div>
</template>
