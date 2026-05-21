<script>
import {
  GlBadge,
  GlButton,
  GlTable,
  GlIcon,
  GlSprintf,
  GlLink,
  GlSkeletonLoader,
} from '@gitlab/ui';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import DrawerWrapper from 'ee/security_orchestration/components/policy_drawer/drawer_wrapper.vue';
import { getPolicyType } from 'ee/security_orchestration/utils';
import { i18n } from '../constants';
import namespacePoliciesQuery from '../graphql/namespace_policies.query.graphql';
import complianceFrameworkPoliciesQuery from '../graphql/compliance_frameworks_policies.query.graphql';
import EditSection from './edit_section.vue';

function extractPolicies(policies) {
  return {
    policies: policies.nodes || [],
    hasNextPage: policies.pageInfo.hasNextPage,
    endCursor: policies.pageInfo.endCursor,
  };
}

export default {
  name: 'PoliciesSection',
  components: {
    DrawerWrapper,
    EditSection,
    GlIcon,
    GlBadge,
    GlButton,
    GlSprintf,
    GlTable,
    GlLink,
    GlSkeletonLoader,
  },
  provide() {
    return {
      namespacePath: this.fullPath,
    };
  },
  inject: ['disableScanPolicyUpdate', 'groupSecurityPoliciesPath'],
  props: {
    fullPath: {
      type: String,
      required: true,
    },
    graphqlId: {
      type: String,
      required: true,
    },
    count: {
      type: Number,
      required: true,
    },
    isInherited: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['policies-count-loaded'],

  data() {
    return {
      selectedPolicy: null,
      rawPolicies: {
        namespaceSecurityPolicies: [],
        complianceApprovalPolicies: [],
        complianceScanExecutionPolicies: [],
        compliancePipelineExecutionPolicies: [],
        complianceVulnerabilityManagementPolicies: [],
      },
      policiesLoaded: false,
      namespacePoliciesLoaded: false,
      policiesLoadCursor: {
        namespaceSecurityPoliciesAfter: null,
        complianceApprovalPoliciesAfter: null,
        complianceScanExecutionPoliciesAfter: null,
        compliancePipelineExecutionPoliciesAfter: null,
        complianceVulnerabilityManagementPoliciesAfter: null,
      },
    };
  },

  apollo: {
    // eslint-disable-next-line @gitlab/vue-no-undef-apollo-properties
    namespacePolicies: {
      query: namespacePoliciesQuery,
      variables() {
        return {
          fullPath: this.fullPath,
          after: this.policiesLoadCursor.namespaceSecurityPoliciesAfter,
        };
      },
      update(data) {
        const { nodes, pageInfo } = data.namespace.securityPolicies;
        this.rawPolicies.namespaceSecurityPolicies.push(...nodes);
        this.policiesLoadCursor.namespaceSecurityPoliciesAfter = pageInfo.endCursor;
        this.namespacePoliciesLoaded = !pageInfo.hasNextPage;
      },
      error(error) {
        this.handleError(error);
      },
      skip() {
        return this.namespacePoliciesLoaded;
      },
    },
    // eslint-disable-next-line @gitlab/vue-no-undef-apollo-properties
    complianceFrameworkPolicies: {
      query: complianceFrameworkPoliciesQuery,
      variables() {
        return {
          fullPath: this.fullPath,
          complianceFramework: this.graphqlId,
          approvalPoliciesAfter: this.policiesLoadCursor.complianceApprovalPoliciesAfter,
          scanExecutionPoliciesAfter: this.policiesLoadCursor.complianceScanExecutionPoliciesAfter,
          pipelineExecutionPoliciesAfter:
            this.policiesLoadCursor.compliancePipelineExecutionPoliciesAfter,
          vulnerabilityManagementPoliciesAfter:
            this.policiesLoadCursor.complianceVulnerabilityManagementPoliciesAfter,
        };
      },
      update(data) {
        this.updatePolicies(
          data.namespace.complianceFrameworks.nodes[0],
          {
            approvalField: 'approvalPolicies',
            scanExecutionField: 'scanExecutionPolicies',
            pipelineExecutionField: 'pipelineExecutionPolicies',
            vulnerabilityManagementField: 'vulnerabilityManagementPolicies',
          },
          'policiesLoaded',
        );
      },
      error(error) {
        this.handleError(error);
      },
      skip() {
        return this.policiesLoaded;
      },
    },
  },

  computed: {
    policies() {
      const complianceByType = {
        approval_policy: new Set(this.rawPolicies.complianceApprovalPolicies.map((p) => p.name)),
        scan_execution_policy: new Set(
          this.rawPolicies.complianceScanExecutionPolicies.map((p) => p.name),
        ),
        pipeline_execution_policy: new Set(
          this.rawPolicies.compliancePipelineExecutionPolicies.map((p) => p.name),
        ),
        vulnerability_management_policy: new Set(
          this.rawPolicies.complianceVulnerabilityManagementPolicies.map((p) => p.name),
        ),
      };

      return this.rawPolicies.namespaceSecurityPolicies
        .filter((p) => complianceByType[p.type]?.has(p.name))
        .map(({ policyAttributes: { __typename: _attrType, ...attrFields }, ...rest }) => ({
          ...rest,
          ...attrFields,
          isLinked: true,
        }))
        .sort((a, b) => (a.name > b.name ? 1 : -1));
    },

    policyType() {
      return this.selectedPolicy ? getPolicyType(this.selectedPolicy.type, 'value', false) : '';
    },
    isLoading() {
      return (
        this.$apollo.queries.complianceFrameworkPolicies.loading ||
        this.$apollo.queries.namespacePolicies.loading
      );
    },
  },

  watch: {
    policiesLoaded(loaded) {
      if (loaded) {
        const total =
          this.rawPolicies.complianceApprovalPolicies.length +
          this.rawPolicies.complianceScanExecutionPolicies.length +
          this.rawPolicies.compliancePipelineExecutionPolicies.length +
          this.rawPolicies.complianceVulnerabilityManagementPolicies.length;
        this.$emit('policies-count-loaded', total);
      }
    },
  },

  methods: {
    updatePolicies(
      namespaceData,
      { approvalField, scanExecutionField, pipelineExecutionField, vulnerabilityManagementField },
      loadedIndicator,
    ) {
      const {
        policies: pendingApprovalPolicies,
        hasNextPage: hasNextApprovalPolicies,
        endCursor: approvalPoliciesAfter,
      } = extractPolicies(namespaceData[approvalField]);

      const {
        policies: pendingScanExecutionPolicies,
        hasNextPage: hasNextScanExecutionPolicies,
        endCursor: scanExecutionPoliciesAfter,
      } = extractPolicies(namespaceData[scanExecutionField]);

      const {
        policies: pendingPipelineExecutionPolicies,
        hasNextPage: hasNextPipelineExecutionPolicies,
        endCursor: pipelineExecutionPoliciesAfter,
      } = extractPolicies(namespaceData[pipelineExecutionField]);

      const {
        policies: pendingVulnerabilityManagementPolicies,
        hasNextPage: hasNextVulnerabilityManagementPolicies,
        endCursor: vulnerabilityManagementPoliciesAfter,
      } = extractPolicies(namespaceData[vulnerabilityManagementField]);

      this.rawPolicies.complianceApprovalPolicies.push(...pendingApprovalPolicies);
      this.rawPolicies.complianceScanExecutionPolicies.push(...pendingScanExecutionPolicies);
      this.rawPolicies.compliancePipelineExecutionPolicies.push(
        ...pendingPipelineExecutionPolicies,
      );
      this.rawPolicies.complianceVulnerabilityManagementPolicies.push(
        ...pendingVulnerabilityManagementPolicies,
      );

      this.policiesLoadCursor.complianceApprovalPoliciesAfter = approvalPoliciesAfter;
      this.policiesLoadCursor.complianceScanExecutionPoliciesAfter = scanExecutionPoliciesAfter;
      this.policiesLoadCursor.compliancePipelineExecutionPoliciesAfter =
        pipelineExecutionPoliciesAfter;
      this.policiesLoadCursor.complianceVulnerabilityManagementPoliciesAfter =
        vulnerabilityManagementPoliciesAfter;
      this[loadedIndicator] =
        !hasNextApprovalPolicies &&
        !hasNextScanExecutionPolicies &&
        !hasNextPipelineExecutionPolicies &&
        !hasNextVulnerabilityManagementPolicies;
    },

    handleError(error) {
      this.errorMessage = this.$options.i18n.fetchError;
      Sentry.captureException(error);
    },

    openPolicyDrawerFromRow(rows) {
      if (this.isInherited || rows.length === 0) return;
      this.openPolicyDrawer(rows[0]);
    },

    openPolicyDrawer(policy) {
      if (this.isInherited) return;
      this.selectedPolicy = policy;
    },

    deselectPolicy() {
      this.selectedPolicy = null;
      this.$refs.policiesTable.$children[0].clearSelected();
    },
  },

  tableFields: [
    {
      key: 'name',
      label: i18n.policiesTableFields.name,
      thClass: '!gl-border-t-0',
      tdClass: '!gl-bg-default @md/panel:gl-w-2/5 !gl-border-b-white',
    },
    {
      key: 'description',
      label: i18n.policiesTableFields.desc,
      thClass: '!gl-border-t-0',
      tdClass: '!gl-bg-default @md/panel:gl-w-2/5 !gl-border-b-white',
    },
    {
      key: 'action',
      label: i18n.policiesTableFields.action,
      thAlignRight: true,
      thClass: '!gl-border-t-0',
      tdClass: 'gl-text-right @md/panel:gl-w-1/5 !gl-bg-default !gl-border-b-white',
    },
  ],
  i18n,
};
</script>

<template>
  <edit-section
    :title="$options.i18n.policies"
    :description="$options.i18n.policiesDescription"
    :items-count="count"
  >
    <gl-table
      v-if="count"
      ref="policiesTable"
      :items="policies"
      :fields="$options.tableFields"
      :busy="isLoading"
      responsive
      stacked="md"
      hover
      :selectable="!isInherited"
      select-mode="single"
      selected-variant="primary"
      class="gl-mb-6"
      @row-selected="openPolicyDrawerFromRow"
    >
      <template #cell(name)="{ item }">
        <span>{{ item.name }}</span>
        <gl-badge v-if="!item.enabled" variant="neutral" class="gl-ml-2">
          {{ __('Disabled') }}
        </gl-badge>
      </template>
      <template #cell(action)="{ item }">
        <gl-button v-if="!isInherited" variant="link" @click="openPolicyDrawer(item)">
          {{ __('View details') }}
        </gl-button>
      </template>

      <template #table-busy>
        <gl-skeleton-loader :lines="count" equal-width-lines />
      </template>
    </gl-table>
    <drawer-wrapper
      v-if="!isInherited"
      container-class=".content-wrapper"
      :open="Boolean(selectedPolicy)"
      :policy="selectedPolicy"
      :policy-type="policyType"
      :disable-scan-policy-update="disableScanPolicyUpdate"
      @close="deselectPolicy"
    />
    <div class="gl-ml-5" data-testid="info-text">
      <gl-icon name="information-o" variant="subtle" class="gl-mr-2" />
      <gl-sprintf :message="$options.i18n.policiesInfoText">
        <template #link="{ content }">
          <gl-link :href="groupSecurityPoliciesPath">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </div>
  </edit-section>
</template>
