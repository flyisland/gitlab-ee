<script>
import { GlAlert, GlButton, GlKeysetPagination, GlSkeletonLoader } from '@gitlab/ui';
import { fetchPolicies } from '~/lib/graphql';
import { __, s__ } from '~/locale';
import { getPageParams } from '~/packages_and_registries/shared/utils';
import DetailLayout from '~/vue_shared/components/detail_layout.vue';
import NotFound from '../../components/not_found.vue';
import {
  GRAPHQL_PAGE_SIZE,
  REPOSITORY_EDIT_ROUTE_NAME,
  REPOSITORY_KIND_REMOTE,
  SETUP_INSTRUCTIONS_TITLE,
} from '../../constants';
import getRepositoryDetailQuery from '../../graphql/queries/get_repository_detail.query.graphql';
import getRepositoryImagesQuery from '../../graphql/queries/get_repository_images.query.graphql';
import getRepositoryPackagesQuery from '../../graphql/queries/get_repository_packages.query.graphql';
import { buildRepositoryClientUrl, isContainerFormat } from '../../utils';
import ArtifactsSection from './artifacts_section.vue';
import RepositoryActions from './repository_actions.vue';
import RepositoryHeading from './repository_heading.vue';
import RepositorySidebar from './repository_sidebar.vue';
import SetupDrawer from './setup_instructions/setup_drawer.vue';

export default {
  name: 'ArtifactRegistryRepositoryDetail',
  components: {
    ArtifactsSection,
    DetailLayout,
    GlAlert,
    GlButton,
    GlKeysetPagination,
    GlSkeletonLoader,
    NotFound,
    RepositoryActions,
    RepositoryHeading,
    RepositorySidebar,
    SetupDrawer,
  },
  inject: ['organizationGid', 'slug', 'clientBaseUrl'],
  data() {
    return {
      repository: undefined,
      hasError: false,
      artifactConnection: undefined,
      hasArtifactConnectionError: false,
      showSetupDrawer: false,
    };
  },
  apollo: {
    repository: {
      query: getRepositoryDetailQuery,
      fetchPolicy: fetchPolicies.CACHE_AND_NETWORK,
      // Without this, vue-apollo holds the cached repository back until the background read
      // returns, so a revisit falls to the skeleton instead of rendering from cache at once.
      notifyOnNetworkStatusChange: true,
      variables() {
        return { organizationId: this.organizationGid, name: this.repositoryName };
      },
      update: ({ organization }) => organization?.artifactRegistryRepository ?? null,
      // The query re-runs whenever its variables change, so each result has to speak for
      // itself: a read that succeeds after one that failed must clear the flag, or the
      // alert outlives the error it reported. `result` fires for failures too, so it
      // reads the error rather than assuming success.
      result({ error }) {
        this.hasError = Boolean(error);
      },
      error() {
        this.hasError = true;
      },
    },
    artifactConnection: {
      query() {
        return this.readsImages ? getRepositoryImagesQuery : getRepositoryPackagesQuery;
      },
      fetchPolicy: fetchPolicies.CACHE_AND_NETWORK,
      variables() {
        return {
          organizationId: this.organizationGid,
          name: this.repositoryName,
          first: GRAPHQL_PAGE_SIZE,
          ...this.pageParams,
        };
      },
      skip() {
        return !this.isPopulated;
      },
      update({ organization }) {
        const repository = organization?.artifactRegistryRepository;

        return (this.readsImages ? repository?.images : repository?.packages) ?? null;
      },
      result({ error }) {
        this.hasArtifactConnectionError = Boolean(error);
      },
      error() {
        this.hasArtifactConnectionError = true;
      },
    },
  },
  computed: {
    repositoryName() {
      return this.$route.params.id;
    },
    isLoading() {
      return this.$apollo.queries.repository.loading;
    },
    // The skeleton is for the first read only. A revisit has the cached repository already,
    // so it re-reads in the background rather than dropping the page back to a skeleton.
    isInitialLoad() {
      return this.isLoading && this.repository === undefined;
    },
    readsImages() {
      return isContainerFormat(this.repository?.format);
    },
    isLoadingArtifacts() {
      if (this.hasArtifactConnectionError) return false;

      return (
        this.$apollo.queries.artifactConnection.loading || this.artifactConnection === undefined
      );
    },
    artifacts() {
      return this.artifactConnection?.nodes ?? [];
    },
    pageInfo() {
      return this.artifactConnection?.pageInfo ?? {};
    },
    pageParams() {
      return getPageParams(this.$route.query, GRAPHQL_PAGE_SIZE);
    },
    hasNoArtifacts() {
      return (
        !this.isLoadingArtifacts && !this.hasArtifactConnectionError && this.artifacts.length === 0
      );
    },
    // The read resolves null both for a repository that does not exist and for one
    // the viewer may not see, so the view renders one outcome for the two and never
    // confirms the repository exists.
    isNotFound() {
      return (
        this.repository === null ||
        (this.artifactConnection === null && !this.hasArtifactConnectionError)
      );
    },
    isPopulated() {
      return Boolean(this.repository);
    },
    rendersRepository() {
      return this.isPopulated && !this.isInitialLoad && !this.hasError && !this.isNotFound;
    },
    // Every page announces the same sentence, and a live region stays silent on a message
    // identical to the one it holds. The loading pass a cursor change already causes is
    // what separates one page's announcement from the next.
    artifactsMessage() {
      if (this.hasArtifactConnectionError) return this.$options.i18n.unavailable;
      if (this.isLoadingArtifacts) return this.$options.i18n.artifactsLoading;

      return this.$options.i18n.artifactsUpdated;
    },
    editRoute() {
      return { name: REPOSITORY_EDIT_ROUTE_NAME, params: { id: this.repository.name } };
    },
    isRemote() {
      return this.repository.kind === REPOSITORY_KIND_REMOTE;
    },
    clientUrl() {
      return buildRepositoryClientUrl({
        clientBaseUrl: this.clientBaseUrl,
        slug: this.slug,
        format: this.repository.format,
        name: this.repository.name,
      });
    },
    showSetupInstructions() {
      if (!this.clientUrl) return false;

      return this.isRemote || !this.hasNoArtifacts;
    },
  },
  methods: {
    pageTo({ before, after }) {
      this.$router.push({ query: { ...this.$route.query, before, after } });
    },
  },
  i18n: {
    unavailable: s__('ArtifactRegistry|The Artifact Registry service is unavailable.'),
    artifactsLoading: s__('ArtifactRegistry|Loading artifacts.'),
    artifactsUpdated: s__('ArtifactRegistry|Artifact list updated.'),
    edit: __('Edit'),
    setupInstructions: SETUP_INSTRUCTIONS_TITLE,
  },
};
</script>

<template>
  <div>
    <span
      class="gl-sr-only"
      aria-live="polite"
      aria-atomic="true"
      data-testid="artifacts-announcement"
      >{{ artifactsMessage }}</span
    >

    <detail-layout :loading="isInitialLoad">
      <template #loading>
        <gl-skeleton-loader :lines="2" :width="500" />
      </template>

      <template #heading-wrapper>
        <div class="gl-min-w-0 gl-grow">
          <repository-heading v-if="rendersRepository" :repository="repository" />
        </div>
      </template>

      <template v-if="rendersRepository" #actions>
        <gl-button
          v-if="showSetupInstructions"
          data-testid="setup-instructions"
          @click="showSetupDrawer = true"
        >
          {{ $options.i18n.setupInstructions }}
        </gl-button>

        <gl-button :to="editRoute" data-testid="edit-repository">
          {{ $options.i18n.edit }}
        </gl-button>

        <repository-actions :repository="repository" />

        <setup-drawer
          :open="showSetupDrawer"
          :name="repository.name"
          :format="repository.format"
          :kind="repository.kind"
          @close="showSetupDrawer = false"
        />
      </template>

      <template v-if="rendersRepository && repository.description" #description>
        <p class="gl-mb-0" data-testid="repository-description">
          {{ repository.description }}
        </p>
      </template>

      <gl-alert v-if="hasError" variant="danger" :dismissible="false">
        {{ $options.i18n.unavailable }}
      </gl-alert>

      <not-found v-else-if="isNotFound" />

      <template v-else-if="rendersRepository">
        <artifacts-section
          :name="repository.name"
          :format="repository.format"
          :kind="repository.kind"
          :artifacts="artifacts"
          :loading="isLoadingArtifacts"
          :has-error="hasArtifactConnectionError"
        />

        <div class="gl-mt-3 gl-flex gl-justify-center">
          <gl-keyset-pagination
            v-bind="pageInfo"
            @prev="pageTo({ before: $event })"
            @next="pageTo({ after: $event })"
          />
        </div>
      </template>

      <template v-if="rendersRepository" #sidebar>
        <repository-sidebar :repository="repository" :hide-stats="hasNoArtifacts" />
      </template>
    </detail-layout>
  </div>
</template>
