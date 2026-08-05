<script>
import { GlButton } from '@gitlab/ui';
import { s__ } from '~/locale';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import {
  STATUS_ALL,
  STATUS_DEGRADED,
  STATUS_DEPLOYING,
  STATUS_HEALTHY,
  STATUS_PENDING,
  statusSortOrderMap,
} from '../constants';
import cdApplicationsQuery from '../graphql/cd_applications.query.graphql';
import ApplicationsList from './applications_list.vue';
import NewApplicationPanel from './new_application_panel.vue';
import FilterBar from './shared/filter_bar.vue';

export default {
  name: 'ApplicationsIndex',
  components: {
    ApplicationsList,
    FilterBar,
    GlButton,
    NewApplicationPanel,
    PageHeading,
  },
  data() {
    return {
      organization: undefined,
      isPanelOpen: false,
      searchTerm: '',
      selectedStatus: STATUS_ALL,
    };
  },
  apollo: {
    organization: {
      query: cdApplicationsQuery,
    },
  },
  computed: {
    applications() {
      const applications = this.organization?.cdApplications.nodes || [];

      // TODO remove fake status data when available in API. This is just for testing UI
      const statuses = [STATUS_HEALTHY, STATUS_DEGRADED, STATUS_DEPLOYING, STATUS_PENDING];
      return applications.map((application, index) => ({
        ...application,
        status: statuses[index % 4],
      }));
    },
    displayedApplications() {
      if (this.selectedStatus === STATUS_ALL) {
        return this.applications.toSorted(
          (a, b) => statusSortOrderMap[a.status] - statusSortOrderMap[b.status],
        );
      }
      return this.applications.filter((app) => app.status === this.selectedStatus);
    },
    organizationId() {
      return this.organization?.id;
    },
    statusButtons() {
      return [
        {
          text: s__('ContinuousDeployment|All'),
          id: STATUS_ALL,
          count: this.applications.length,
        },
        {
          id: STATUS_PENDING,
          count: this.applications.filter((app) => app.status === STATUS_PENDING).length,
          text: s__('ContinuousDeployment|Awaiting approval'),
        },
        {
          id: STATUS_DEGRADED,
          count: this.applications.filter((app) => app.status === STATUS_DEGRADED).length,
          text: s__('ContinuousDeployment|Degraded'),
        },
        {
          id: STATUS_DEPLOYING,
          count: this.applications.filter((app) => app.status === STATUS_DEPLOYING).length,
          text: s__('ContinuousDeployment|Deploying'),
        },
        {
          id: STATUS_HEALTHY,
          count: this.applications.filter((app) => app.status === STATUS_HEALTHY).length,
          text: s__('ContinuousDeployment|Healthy'),
        },
      ];
    },
  },
};
</script>

<template>
  <div>
    <page-heading :heading="s__('ContinuousDeployment|Applications')">
      <template #actions>
        <gl-button variant="confirm" @click="isPanelOpen = true">
          {{ s__('ContinuousDeployment|New application') }}
        </gl-button>
      </template>
    </page-heading>

    <filter-bar
      :filters="statusButtons"
      :search-placeholder="s__('ContinuousDeployment|Search by name, team, or description')"
      :search-term="searchTerm"
      :selected-filter-id="selectedStatus"
      @filter-selected="selectedStatus = $event"
      @search="searchTerm = $event"
    />

    <applications-list :applications="displayedApplications" />

    <new-application-panel
      :open="isPanelOpen"
      :organization-id="organizationId"
      @close="isPanelOpen = false"
    />
  </div>
</template>
