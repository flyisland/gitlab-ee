<script>
import { GlButton } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import cdApplicationsQuery from '../graphql/cd_applications.query.graphql';
import { APPLICATION_FILTERS } from '../constants';
import FilterBar from './shared/filter_bar.vue';
import ApplicationsList from './applications_list.vue';

export default {
  name: 'ApplicationsIndex',
  components: {
    ApplicationsList,
    GlButton,
    PageHeading,
    FilterBar,
  },
  statusFilters: APPLICATION_FILTERS,
  data() {
    return {
      organization: null,
      selectedFilterId: null,
      searchTerm: '',
    };
  },
  apollo: {
    organization: {
      query: cdApplicationsQuery,
    },
  },
  computed: {
    groups() {
      return this.organization?.groups.nodes ?? [];
    },
    groupsWithApplications() {
      return this.groups.filter((group) => group.cdApplications.nodes.length);
    },
    applications() {
      return this.groupsWithApplications.reduce(
        (acc, group) => acc.concat(group.cdApplications.nodes),
        [],
      );
    },
    subheadingText() {
      // Cannot have "1 application across n groups"
      let text = s__(
        'ContinuousDeployment|%{applicationCount} applications across %{groupCount} groups',
      );
      if (this.groupsWithApplications.length === 1) {
        text =
          this.applications.length === 1
            ? s__('ContinuousDeployment|%{applicationCount} application across %{groupCount} group')
            : s__(
                'ContinuousDeployment|%{applicationCount} applications across %{groupCount} group',
              );
      }
      return sprintf(text, {
        applicationCount: this.applications.length,
        groupCount: this.groupsWithApplications.length,
      });
    },
  },
  methods: {
    onFilterSelected(id) {
      this.selectedFilterId = id;
    },
    onSearch(term) {
      this.searchTerm = term;
    },
  },
};
</script>

<template>
  <div>
    <page-heading :heading="s__('ContinuousDeployment|Applications')">
      <template #actions>
        <gl-button variant="confirm">{{ s__('ContinuousDeployment|New application') }}</gl-button>
      </template>
      <template #description>
        {{ subheadingText }}
      </template>
    </page-heading>

    <filter-bar
      :filters="$options.statusFilters"
      :selected-filter-id="selectedFilterId"
      :search-term="searchTerm"
      @filter-selected="onFilterSelected"
      @search="onSearch"
    />

    <applications-list :applications="applications" />
  </div>
</template>
