<script>
import emptyEnvironmentsSvgPath from '@gitlab/svgs/dist/illustrations/empty-state/empty-environment-md.svg';
import { GlButton, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import { ENVIRONMENT_FILTERS } from '../constants';
import EnvironmentList from './environment_list.vue';
import FilterBar from './shared/filter_bar.vue';

export default {
  name: 'EnvironmentsIndex',
  components: {
    GlButton,
    EnvironmentList,
    PageHeading,
    FilterBar,
    GlSprintf,
  },
  i18n: {
    title: s__('ContinuousDeployment|Environments'),
    registerEnvironment: s__('ContinuousDeployment|Register environment'),
    registerFirstEnvironment: s__('ContinuousDeployment|Register your first environment'),
    environmentsCountLabel: s__(
      'ContinuousDeployment|%{environmentsCount} of %{totalEnvironmentsCount} environments',
    ),
    emptyStateTitle: s__('ContinuousDeployment|Get started with environments'),
    emptyStateDescription: s__(
      'ContinuousDeployment|Environments are places where code gets deployed, such as staging or production.',
    ),
    searchPlaceholder: s__('ContinuousDeployment|Filter environments...'),
  },
  statusFilters: ENVIRONMENT_FILTERS,
  emptyEnvironmentsSvgPath,
  data() {
    return {
      selectedFilterId: null,
      searchTerm: '',
    };
  },
  computed: {
    environmentsCount() {
      return '0';
    },
    totalEnvironmentsCount() {
      return '0';
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
    <page-heading :heading="$options.i18n.title">
      <template #actions>
        <gl-button variant="confirm" data-testid="register-environment-button">
          {{ $options.i18n.registerEnvironment }}
        </gl-button>
      </template>
      <template #description>
        <gl-sprintf :message="$options.i18n.environmentsCountLabel">
          <template #environmentsCount>
            {{ environmentsCount }}
          </template>
          <template #totalEnvironmentsCount>
            {{ totalEnvironmentsCount }}
          </template>
        </gl-sprintf>
      </template>
    </page-heading>
    <filter-bar
      :filters="$options.statusFilters"
      :selected-filter-id="selectedFilterId"
      :search-term="searchTerm"
      :search-placeholder="$options.i18n.searchPlaceholder"
      @filter-selected="onFilterSelected"
      @search="onSearch"
    />
    <environment-list />
  </div>
</template>
