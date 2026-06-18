<script>
import {
  GlAlert,
  GlIcon,
  GlLink,
  GlSprintf,
  GlTable,
  GlKeysetPagination,
  GlTooltipDirective,
} from '@gitlab/ui';
import { s__, n__, sprintf } from '~/locale';
import { createAlert } from '~/alert';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import { TYPENAME_GROUP } from '~/graphql_shared/constants';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import groupScannerDetailsProjectsQuery from 'ee/security_configuration/graphql/scan_profiles/group_scanner_details_projects.query.graphql';
import groupAvailableSecurityScanProfilesQuery from 'ee/security_configuration/graphql/scan_profiles/group_available_security_scan_profiles.query.graphql';
import groupAnalyzerStatusesQuery from 'ee/security_configuration/graphql/scan_profiles/group_analyzer_statuses.query.graphql';
import attachMutation from 'ee/security_configuration/graphql/scan_profiles/security_scan_profile_attach.mutation.graphql';
import detachMutation from 'ee/security_configuration/graphql/scan_profiles/security_scan_profile_detach.mutation.graphql';
import InventoryDashboardFilteredSearchBar from 'ee/security_inventory/components/inventory_dashboard_filtered_search_bar.vue';
import NameCell from 'ee/security_inventory/components/name_cell.vue';
import AttributesCell from 'ee/security_inventory/components/attributes_cell.vue';
import { smoothScrollTop } from '~/lib/utils/scroll_utils';
import {
  SCAN_PROFILE_CATEGORIES,
  SCAN_PROFILE_SCANNER_HEALTH_PENDING,
} from '~/security_configuration/constants';
import ScannerStatusIcon from 'ee/security_configuration/components/scan_profiles/scanner_status_icon.vue';
import {
  GROUP_STATUS_NOT_ENABLED,
  STATUS_NORMALIZATION_MAP,
} from 'ee/security_configuration/constants';
import ActionsCell from './actions_cell.vue';
import StatisticsCardRow from './statistics_card_row.vue';
import LastScanCell from './last_scan_cell.vue';
import TroubleshootJobDrawer from './troubleshoot_job_drawer.vue';

const PAGE_SIZE = 20;
const TD_CLASS = '!gl-bg-default !gl-align-middle';
const TH_CLASS = 'gl-w-1/6';

const ANALYZER_SOURCE_LABELS = {
  SCAN_EXECUTION_POLICY: s__('SecurityConfiguration|Scan execution policy'),
  PIPELINE_EXECUTION_POLICY: s__('SecurityConfiguration|Pipeline execution policy'),
  SECURITY_SCAN_PROFILES: s__('SecurityConfiguration|Security scan profile'),
  PIPELINE_EXECUTION_POLICY_SCHEDULE: s__(
    'SecurityConfiguration|Scheduled pipeline execution policy',
  ),
  SECURITY_ORCHESTRATION_POLICY: s__('SecurityConfiguration|Security orchestration policy'),
  ON_DEMAND_DAST_SCAN: s__('SecurityConfiguration|On-demand DAST scan'),
  ON_DEMAND_DAST_VALIDATION: s__('SecurityConfiguration|On-demand DAST validation'),
  YML: s__('SecurityConfiguration|YAML configuration'),
};

export default {
  name: 'ScannerDetails',
  components: {
    ScannerStatusIcon,
    PageHeading,
    GlAlert,
    GlIcon,
    GlLink,
    GlSprintf,
    GlTable,
    GlKeysetPagination,
    InventoryDashboardFilteredSearchBar,
    NameCell,
    AttributesCell,
    ActionsCell,
    StatisticsCardRow,
    LastScanCell,
    TroubleshootJobDrawer,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  inject: ['groupFullPath', 'groupId', 'groupName', 'canReadAttributes', 'securityInventoryPath'],
  apollo: {
    availableSecurityScanProfiles: {
      query: groupAvailableSecurityScanProfilesQuery,
      variables() {
        return { fullPath: this.groupFullPath, gitlabRecommended: true };
      },
      update: (data) => data?.group?.availableSecurityScanProfiles ?? [],
    },
    groupAnalyzerStatuses: {
      query: groupAnalyzerStatusesQuery,
      variables() {
        return { fullPath: this.groupFullPath };
      },
      update: (data) => data?.group?.analyzerStatuses ?? [],
      result() {
        if (!this.scannerStatus) {
          this.handleCardError();
        }
      },
      error() {
        this.handleCardError();
      },
    },
    namespaceSecurityProjects: {
      query: groupScannerDetailsProjectsQuery,
      variables() {
        const {
          search = '',
          securityAnalyzerFilters = [],
          vulnerabilityCountFilters = [],
          attributeFilters = [],
        } = this.filters;

        return {
          namespaceId: convertToGraphQLId(TYPENAME_GROUP, this.groupId),
          first: this.after || !this.before ? PAGE_SIZE : null,
          after: this.after,
          last: this.before ? PAGE_SIZE : null,
          before: this.before,
          search,
          securityAnalyzerFilters,
          vulnerabilityCountFilters,
          attributeFilters,
          canReadAttributes: this.canReadAttributes,
        };
      },
    },
  },
  data() {
    return {
      availableSecurityScanProfiles: [],
      groupAnalyzerStatuses: [],
      namespaceSecurityProjects: {},
      after: null,
      before: null,
      filters: {},
      hasCardError: false,
      drawerData: null,
      isDrawerOpen: false,
      cardFilter: null,
    };
  },
  computed: {
    scannerKey() {
      return this.$route.params.scanner_key;
    },
    scannerName() {
      return SCAN_PROFILE_CATEGORIES[this.scannerKey]?.name ?? this.scannerKey;
    },
    defaultProfile() {
      return this.availableSecurityScanProfiles.find(
        (profile) => profile.scanType === this.scannerKey,
      );
    },
    isLoading() {
      return this.$apollo.queries.namespaceSecurityProjects.loading;
    },
    areCardsLoading() {
      return this.$apollo.queries.groupAnalyzerStatuses.loading;
    },
    scannerStatus() {
      return this.groupAnalyzerStatuses.find((status) => status.analyzerType === this.scannerKey);
    },
    statCards() {
      return [
        {
          title: s__('SecurityConfiguration|Enabled'),
          value: this.scannerStatus?.success ?? 0,
          description: sprintf(
            n__(
              'SecurityConfiguration|Project with %{scannerName} running successfully',
              'SecurityConfiguration|Projects with %{scannerName} running successfully',
              this.scannerStatus?.success ?? 0,
            ),
            { scannerName: this.scannerName },
          ),
          filters: {
            securityAnalyzerFilters: [{ analyzerType: this.scannerKey, status: 'SUCCESS' }],
          },
        },
        {
          title: s__('SecurityConfiguration|Not enabled'),
          value: this.scannerStatus?.notConfigured ?? 0,
          description: sprintf(
            n__(
              'SecurityConfiguration|Project without %{scannerName} enabled',
              'SecurityConfiguration|Projects without %{scannerName} enabled',
              this.scannerStatus?.notConfigured ?? 0,
            ),
            {
              scannerName: this.scannerName,
            },
          ),
          filters: {
            securityAnalyzerFilters: [{ analyzerType: this.scannerKey, status: 'NOT_CONFIGURED' }],
          },
        },
        {
          title: s__('SecurityConfiguration|Needs attention'),
          value: this.scannerStatus?.failure ?? 0,
          description: n__(
            'SecurityConfiguration|Project with scan failures',
            'SecurityConfiguration|Projects with scan failures',
            this.scannerStatus?.failure ?? 0,
          ),
          filters: {
            securityAnalyzerFilters: [{ analyzerType: this.scannerKey, status: 'FAILED' }],
          },
        },
        {
          title: s__('SecurityConfiguration|Stale'),
          value: this.scannerStatus?.stale ?? 0,
          description: n__(
            'SecurityConfiguration|Project not scanned in 90+ days',
            'SecurityConfiguration|Projects not scanned in 90+ days',
            this.scannerStatus?.stale ?? 0,
          ),
          filters: {
            securityAnalyzerFilters: [{ analyzerType: this.scannerKey, status: 'STALE' }],
          },
        },
      ];
    },
    projects() {
      return (this.namespaceSecurityProjects.nodes ?? []).map((project) => ({
        ...project,
        scanStatus: this.getStatusForItem(project),
      }));
    },
    pageInfo() {
      return this.namespaceSecurityProjects.pageInfo ?? {};
    },
    headingText() {
      return sprintf(s__('SecurityConfiguration|%{scanner} configuration'), {
        scanner: this.scannerName,
      });
    },
    profileTooltipText() {
      return sprintf(
        s__(
          'SecurityConfiguration|How %{scannerName} is configured for each project. Management actions on this page are only available for projects using profile-based configuration. Other sources must be managed at their origin.',
        ),
        { scannerName: this.scannerName },
      );
    },
    fields() {
      const fields = [
        {
          key: 'name',
          label: s__('SecurityConfiguration|Project'),
          tdClass: TD_CLASS,
          thClass: TH_CLASS,
        },
        {
          key: 'securityScanProfile',
          label: s__('SecurityConfiguration|Source'),
          tdClass: TD_CLASS,
          thClass: TH_CLASS,
        },
        {
          key: 'analyzerStatus',
          label: s__('SecurityConfiguration|Status'),
          tdClass: TD_CLASS,
          thClass: TH_CLASS,
        },
        {
          key: 'lastScan',
          label: s__('SecurityConfiguration|Last scan'),
          tdClass: TD_CLASS,
          thClass: TH_CLASS,
        },
        {
          key: 'actions',
          label: '',
          tdClass: `${TD_CLASS} gl-text-right`,
          thClass: `${TH_CLASS} !gl-align-middle`,
        },
      ];

      if (this.canReadAttributes) {
        fields.splice(-1, 0, {
          key: 'securityAttributes',
          label: s__('SecurityConfiguration|Security attributes'),
          tdClass: TD_CLASS,
          thClass: TH_CLASS,
        });
      }

      return fields;
    },
  },
  methods: {
    handleViewProjects(card) {
      this.cardFilter = card;
      this.filters = { ...card.filters };
      this.after = null;
      this.before = null;
    },
    clearCardFilter() {
      this.cardFilter = null;
      this.filters = {};
      this.after = null;
      this.before = null;
    },
    matchingProfile(item) {
      return item.securityScanProfiles?.find((profile) => profile.scanType === this.scannerKey);
    },
    sourceLabel(item) {
      const source = item.analyzerStatuses?.find(
        (status) => status.analyzerType === this.scannerKey,
      )?.source;
      return ANALYZER_SOURCE_LABELS[source] ?? null;
    },
    getStatusForItem(item) {
      const profileMatch = item.scanProfileStatuses?.find(
        (s) => s.scanProfile?.scanType === this.scannerKey,
      );
      if (
        profileMatch &&
        profileMatch.status?.toLowerCase() !== SCAN_PROFILE_SCANNER_HEALTH_PENDING
      ) {
        const profileStatus = profileMatch.status?.toLowerCase();
        return {
          ...profileMatch,
          rawStatus: profileStatus,
          status: STATUS_NORMALIZATION_MAP[profileStatus] ?? profileStatus,
        };
      }

      const analyzerMatch = item.analyzerStatuses?.find((s) => s.analyzerType === this.scannerKey);
      if (!analyzerMatch) return { status: GROUP_STATUS_NOT_ENABLED };
      const analyzerStatus = analyzerMatch.status?.toLowerCase();
      return {
        ...analyzerMatch,
        rawStatus: analyzerStatus,
        status: STATUS_NORMALIZATION_MAP[analyzerStatus] ?? analyzerStatus,
        lastScanAt: analyzerMatch.updatedAt,
      };
    },
    openDrawer(item, jobData = {}) {
      this.drawerData = {
        jobData: { ...jobData },
        buildId: item.scanStatus.buildId,
        status: item.scanStatus.rawStatus,
        fullPath: item.fullPath,
      };
      this.isDrawerOpen = true;
    },
    handleError() {
      createAlert({
        message: s__('SecurityConfiguration|An error occurred managing scan profiles.'),
      });
    },
    handleCardError() {
      if (this.hasCardError) return;

      this.hasCardError = true;
      createAlert({
        message: s__('SecurityConfiguration|Failed to load scanner statistics'),
      });
    },
    async applyDefaultProfile(item) {
      if (!this.defaultProfile) {
        this.handleError();
        return;
      }

      await this.$apollo.mutate({
        mutation: attachMutation,
        variables: {
          input: { securityScanProfileId: this.defaultProfile.id, projectIds: [item.id] },
        },
      });
      this.$apollo.queries.namespaceSecurityProjects.refetch();
    },
    async disableProfile(item) {
      const profile = this.matchingProfile(item);
      if (!profile) {
        this.handleError();
        return;
      }

      await this.$apollo.mutate({
        mutation: detachMutation,
        variables: { input: { securityScanProfileId: profile.id, projectIds: [item.id] } },
      });
      this.$apollo.queries.namespaceSecurityProjects.refetch();
    },
    handleFilter(filters) {
      this.filters = filters;
      this.after = null;
      this.before = null;
    },
    handleNext(endCursor) {
      this.after = endCursor;
      this.before = null;
      smoothScrollTop();
    },
    handlePrev(startCursor) {
      this.before = startCursor;
      this.after = null;
      smoothScrollTop();
    },
  },
};
</script>
<template>
  <div>
    <page-heading :heading="headingText" />
    <div class="gl-mb-4 gl-flex gl-items-start gl-justify-between gl-gap-3">
      <span>
        <gl-sprintf
          :message="
            s__(
              'SecurityConfiguration|View and manage %{scanner} configuration across projects in the %{group} group.',
            )
          "
        >
          <template #scanner>
            {{ scannerName }}
          </template>
          <template #group>
            <gl-link :href="`/${groupFullPath}`">{{ groupName }}</gl-link>
          </template>
        </gl-sprintf>
      </span>
    </div>

    <statistics-card-row
      :cards="statCards"
      :loading="areCardsLoading"
      :error="hasCardError"
      @view-projects="handleViewProjects"
    />

    <gl-alert
      v-if="cardFilter"
      variant="info"
      class="gl-mb-4"
      :title="cardFilter.title"
      @dismiss="clearCardFilter"
    >
      {{
        s__(
          'SecurityConfiguration|Showing projects that match this statistic. Dismiss to view all.',
        )
      }}
    </gl-alert>
    <inventory-dashboard-filtered-search-bar
      v-else
      :namespace="groupFullPath"
      class="gl-mb-4"
      @filter-subgroups-and-projects="handleFilter"
    />

    <gl-table
      :fields="fields"
      :items="projects"
      :busy="isLoading"
      table-class="!gl-bg-strong gl-rounded-xl gl-table-fixed"
      show-empty
      borderless
    >
      <template #cell(name)="{ item }">
        <name-cell :item="item" show-search-param />
      </template>
      <template #head(securityScanProfile)="{ label }">
        <div class="gl-flex gl-items-center">
          <span>{{ label }}</span>
          <gl-icon
            v-gl-tooltip
            :title="profileTooltipText"
            name="information-o"
            variant="info"
            class="gl-ml-2"
          />
        </div>
      </template>
      <template #cell(securityScanProfile)="{ item }">
        <span v-if="matchingProfile(item)">{{ matchingProfile(item).name }}</span>
        <span v-else class="gl-text-subtle">{{
          s__('SecurityConfiguration|No profile applied')
        }}</span>

        <div
          v-if="sourceLabel(item)"
          data-testid="analyzer-source"
          class="gl-text-sm gl-text-subtle"
        >
          {{ sourceLabel(item) }}
        </div>
      </template>
      <template #cell(analyzerStatus)="{ item }">
        <scanner-status-icon
          data-testid="status-icon"
          class="gl-self-start"
          :status="item.scanStatus.status"
          :consecutive-success-count="item.scanStatus.consecutiveSuccessCount"
          :consecutive-failure-count="item.scanStatus.consecutiveFailureCount"
        />
      </template>
      <template #cell(lastScan)="{ item }">
        <last-scan-cell
          :target-id="`scanner-details-${item.id}`"
          :last-scan-at="item.scanStatus?.lastScanAt"
          :build-id="item.scanStatus?.buildId"
          :status="item.scanStatus?.rawStatus"
          :project-full-path="item.fullPath"
          link-variant="pipeline-job"
          @open-drawer="openDrawer(item, $event)"
        />
      </template>
      <template #cell(securityAttributes)="{ item, index }">
        <attributes-cell :item="item" :index="index" />
      </template>
      <template #cell(actions)="{ item }">
        <actions-cell
          :item="item"
          :has-profile="Boolean(matchingProfile(item))"
          @apply-profile="applyDefaultProfile(item)"
          @disable-profile="disableProfile(item)"
          @troubleshoot-failure="openDrawer(item)"
        />
      </template>
    </gl-table>

    <div
      v-if="pageInfo.hasNextPage || pageInfo.hasPreviousPage"
      class="gl-mt-5 gl-flex gl-justify-center"
    >
      <gl-keyset-pagination v-bind="pageInfo" @prev="handlePrev" @next="handleNext" />
    </div>

    <troubleshoot-job-drawer
      v-if="isDrawerOpen"
      :job-data="drawerData.jobData"
      :build-id="drawerData.buildId"
      :scan-type="scannerKey"
      :status="drawerData.status"
      :full-path="drawerData.fullPath"
      :open-drawer="isDrawerOpen"
      @close-drawer="isDrawerOpen = false"
    />
  </div>
</template>
