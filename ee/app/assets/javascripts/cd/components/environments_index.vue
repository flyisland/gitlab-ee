<script>
import emptyEnvironmentsSvgPath from '@gitlab/svgs/dist/illustrations/empty-state/empty-environment-md.svg';
import { GlButton, GlSprintf } from '@gitlab/ui';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { s__ } from '~/locale';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import { ENVIRONMENT_FILTERS } from '../constants';
import cdEnvironmentsQuery from '../graphql/cd_environments.query.graphql';
import EnvironmentCard from './environment_card.vue';
import EnvironmentList from './environment_list.vue';
import NewEnvironmentPanel from './new_environment_panel.vue';
import FilterBar from './shared/filter_bar.vue';

export default {
  name: 'EnvironmentsIndex',
  components: {
    GlButton,
    EnvironmentCard,
    EnvironmentList,
    NewEnvironmentPanel,
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
  emptyEnvironmentsSvgPath,
  data() {
    return {
      environments: [],
      selectedFilterId: null,
      searchTerm: '',
      isPanelOpen: false,
    };
  },
  apollo: {
    environments: {
      query: cdEnvironmentsQuery,
      update(data) {
        return data?.organization?.cdEnvironments?.nodes || [];
      },
      error(error) {
        Sentry.captureException(error);
      },
    },
  },
  computed: {
    statusFilters() {
      return Object.entries(ENVIRONMENT_FILTERS).map(([id, text]) => ({ id, text }));
    },
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
    openPanel() {
      this.isPanelOpen = true;
    },
    closePanel() {
      this.isPanelOpen = false;
    },
  },
};
</script>

<template>
  <div>
    <page-heading :heading="$options.i18n.title">
      <template #actions>
        <gl-button variant="confirm" data-testid="register-environment-button" @click="openPanel">
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
      :filters="statusFilters"
      :selected-filter-id="selectedFilterId"
      :search-term="searchTerm"
      :search-placeholder="$options.i18n.searchPlaceholder"
      @filter-selected="onFilterSelected"
      @search="onSearch"
    />
    <div
      v-if="environments.length"
      class="gl-mt-5 gl-grid gl-grid-cols-1 gl-gap-3 md:gl-grid-cols-2 xl:gl-grid-cols-3"
    >
      <environment-card
        v-for="environment in environments"
        :key="environment.id"
        :name="environment.name"
      />
    </div>
    <environment-list v-else @register="openPanel" />
    <new-environment-panel :open="isPanelOpen" @close="closePanel" />
  </div>
</template>
