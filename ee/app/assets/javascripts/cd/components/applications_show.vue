<script>
import { GlAlert, GlButton, GlEmptyState, GlLoadingIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import { TYPENAME_CD_APPLICATION } from 'ee/graphql_shared/constants';
import { convertToGraphQLId, getIdFromGraphQLId } from '~/graphql_shared/utils';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import cdApplicationWithServicesQuery from '../graphql/cd_application_with_services.query.graphql';
import OverviewCard from './overview_card.vue';
import ServicesTable from './services_table.vue';
import ReleasesTable from './releases_table.vue';
import ApplicationFlow from './application_flow.vue';

export default {
  name: 'ApplicationsShow',
  components: {
    GlAlert,
    GlButton,
    GlLoadingIcon,
    GlEmptyState,
    PageHeading,
    OverviewCard,
    ApplicationFlow,
  },
  props: {
    id: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      application: null,
      hasError: false,
      expandedSections: {},
      highlightedReleaseId: null,
    };
  },
  apollo: {
    application: {
      query: cdApplicationWithServicesQuery,
      variables() {
        return { id: this.applicationId };
      },
      update: (data) => data?.organization?.cdApplication ?? null,
      error() {
        this.hasError = true;
      },
      watchLoading(isLoading) {
        // Clear a stale error when a new fetch starts (e.g. on refetch).
        if (isLoading) {
          this.hasError = false;
        }
      },
    },
  },
  computed: {
    applicationId() {
      return convertToGraphQLId(TYPENAME_CD_APPLICATION, this.id);
    },
    services() {
      return this.application?.services?.nodes ?? [];
    },
    releases() {
      return this.application?.versionSets?.nodes ?? [];
    },
    openReleaseId() {
      if (this.$route.name !== 'release_detail_route') {
        return null;
      }
      const { releaseId } = this.$route.params;
      return this.releases.find((r) => String(getIdFromGraphQLId(r.id)) === releaseId)?.id ?? null;
    },
    isLoading() {
      return this.$apollo.queries.application.loading;
    },
    // Declarative, data-driven section config resolved against current state:
    // each section owns its identity, labels, expand state, and (optionally) the
    // component + props/listeners used to render its body.
    sections() {
      const isExpanded = (key) => Boolean(this.expandedSections[key]);
      return [
        {
          key: 'services',
          title: s__('ContinuousDeployment|Services'),
          expandLabel: s__('ContinuousDeployment|Expand services'),
          collapseLabel: s__('ContinuousDeployment|Collapse services'),
          expanded: isExpanded('services'),
          component: ServicesTable,
          contentProps: {
            services: this.services,
            full: isExpanded('services'),
            'data-testid': isExpanded('services')
              ? 'services-expanded-table'
              : 'services-mini-table',
          },
          contentListeners: { select: this.openService },
        },
        {
          key: 'deployments',
          title: s__('ContinuousDeployment|Deployments'),
          expandLabel: s__('ContinuousDeployment|Expand deployments'),
          collapseLabel: s__('ContinuousDeployment|Collapse deployments'),
          expanded: isExpanded('deployments'),
        },
        {
          key: 'releases',
          title: s__('ContinuousDeployment|Releases'),
          expandLabel: s__('ContinuousDeployment|Expand releases'),
          collapseLabel: s__('ContinuousDeployment|Collapse releases'),
          expanded: isExpanded('releases'),
          component: ReleasesTable,
          contentProps: {
            releases: this.releases,
            full: isExpanded('releases'),
            selectedId: this.highlightedReleaseId,
            openId: this.openReleaseId,
          },
          contentListeners: { select: this.openRelease },
        },
        {
          key: 'links',
          title: s__('ContinuousDeployment|Links'),
          expandLabel: s__('ContinuousDeployment|Expand links'),
          collapseLabel: s__('ContinuousDeployment|Collapse links'),
          expanded: isExpanded('links'),
        },
      ];
    },
    orderedSections() {
      // Expanded sections float to the top; stable sort keeps the rest in order.
      return [...this.sections].sort((a, b) => Number(b.expanded) - Number(a.expanded));
    },
  },
  methods: {
    toggleExpansion(section) {
      this.expandedSections = {
        ...this.expandedSections,
        [section.key]: !this.expandedSections[section.key],
      };
    },
    openNewRelease() {
      this.$router.push({ name: 'release_new_route', params: { id: this.id } });
    },
    onReleaseCreated(versionSetId) {
      this.highlightedReleaseId = versionSetId;
      this.expandedSections = { ...this.expandedSections, releases: true };
      this.$apollo.queries.application.refetch();
      this.closePanel();
    },
    onDeployTriggered() {
      this.$apollo.queries.application.refetch();
      this.closePanel();
    },
    openService(service) {
      this.$router.push({
        name: 'service_detail_route',
        params: { id: this.id, serviceId: String(getIdFromGraphQLId(service.id)) },
      });
    },
    openRelease(release) {
      this.$router.push({
        name: 'release_detail_route',
        params: { id: this.id, releaseId: String(getIdFromGraphQLId(release.id)) },
      });
    },
    closePanel() {
      this.$router.push({ name: 'applications_show_route', params: { id: this.id } });
    },
  },
};
</script>

<template>
  <div>
    <gl-loading-icon v-if="isLoading" size="lg" class="gl-mt-5" />

    <gl-alert
      v-else-if="hasError"
      variant="danger"
      :dismissible="false"
      class="gl-mt-5"
      data-testid="applications-show-error-alert"
    >
      {{ s__('ContinuousDeployment|Failed to load the application. Please try again later.') }}
    </gl-alert>

    <gl-empty-state
      v-else-if="!application"
      :title="s__('ContinuousDeployment|Application not found')"
      :description="
        s__(
          'ContinuousDeployment|The application may have been removed or you may not have access to it.',
        )
      "
      data-testid="applications-show-empty-state"
    />

    <template v-else>
      <page-heading :heading="application.name">
        <template v-if="application.description" #description>
          {{ application.description }}
        </template>
        <template #actions>
          <gl-button variant="confirm" data-testid="new-release-button" @click="openNewRelease">
            {{ s__('ReleaseCreation|Create release') }}
          </gl-button>
        </template>
      </page-heading>

      <application-flow :application-id="applicationId" class="gl-mt-5" />

      <!-- Expandable overview cards: one flex-wrap container; expanded cards take a
           full row (gl-basis-full), collapsed cards share the row (gl-grow gl-basis-0). -->
      <div class="gl-mt-5 gl-flex gl-flex-wrap gl-gap-4" data-testid="overview-cards">
        <overview-card
          v-for="section in orderedSections"
          :key="section.key"
          :title="section.title"
          :expanded="section.expanded"
          :expand-aria-label="section.expandLabel"
          :collapse-aria-label="section.collapseLabel"
          :data-testid="section.expanded ? `${section.key}-card-expanded` : `${section.key}-card`"
          @toggle="toggleExpansion(section)"
        >
          <component
            :is="section.component"
            v-if="section.component"
            v-bind="section.contentProps"
            v-on="section.contentListeners"
          />
        </overview-card>
      </div>

      <router-view
        @close="closePanel"
        @created="onReleaseCreated"
        @deploy-triggered="onDeployTriggered"
      />
    </template>
  </div>
</template>
