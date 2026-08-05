<script>
import { GlBadge, GlEmptyState, GlLoadingIcon } from '@gitlab/ui';
import { MountingPortal } from 'portal-vue';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import { TYPENAME_CD_VERSION_SET } from 'ee/graphql_shared/constants';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import DynamicPanel from '~/vue_shared/components/dynamic_panel.vue';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import { ROLLOUT_STATE_VARIANTS, ROLLOUT_STATE_LABELS } from '../constants';
import cdVersionSetQuery from '../graphql/cd_version_set.query.graphql';
import TriggerDeployment from './trigger_deployment.vue';

export default {
  name: 'ReleaseSidePanel',
  components: {
    GlBadge,
    GlEmptyState,
    GlLoadingIcon,
    DynamicPanel,
    MountingPortal,
    TimeAgo,
    TriggerDeployment,
  },
  props: {
    releaseId: {
      type: String,
      required: true,
    },
  },
  emits: ['close', 'deploy-triggered'],
  data() {
    return {
      versionSet: null,
      organizationId: null,
    };
  },
  apollo: {
    versionSet: {
      query: cdVersionSetQuery,
      variables() {
        return { id: this.versionSetGid };
      },
      update: (data) => {
        return data?.organization?.cdVersionSet ?? null;
      },
      result({ data }) {
        this.organizationId = data?.organization?.id ?? this.organizationId;
      },
      error(error) {
        Sentry.captureException(error);
      },
    },
  },
  computed: {
    versionSetGid() {
      return convertToGraphQLId(TYPENAME_CD_VERSION_SET, this.releaseId);
    },
    selectedRelease() {
      return this.versionSet;
    },
    isLoading() {
      return this.$apollo.queries.versionSet.loading;
    },
    hasRelease() {
      return this.selectedRelease != null;
    },
    applicationName() {
      return this.selectedRelease?.application?.name ?? '';
    },
    rolloutState() {
      return this.selectedRelease?.rollouts?.nodes?.[0]?.state ?? null;
    },
    statusVariant() {
      return ROLLOUT_STATE_VARIANTS[this.rolloutState] ?? 'neutral';
    },
    statusLabel() {
      return ROLLOUT_STATE_LABELS[this.rolloutState] ?? '';
    },
    entries() {
      const nodes = this.selectedRelease?.versionSetEntries?.nodes ?? [];

      return nodes.map((entry) => ({
        service: entry.service?.name,
        version: entry.version?.name,
      }));
    },
    hasEntries() {
      return this.entries.length > 0;
    },
  },
};
</script>

<template>
  <mounting-portal mount-to="#contextual-panel-portal" append>
    <dynamic-panel data-testid="release-side-panel" @close="$emit('close')">
      <template v-if="hasRelease" #header>
        <div class="gl-py-3">
          <p
            class="gl-mb-2 gl-text-xs gl-font-bold gl-uppercase gl-tracking-wider gl-text-status-brand"
          >
            {{ s__('ContinuousDeployment|Release') }}
          </p>
          <h3 class="gl-my-0 gl-text-base" data-testid="release-title">
            {{ selectedRelease.name }}
          </h3>
        </div>
      </template>

      <gl-loading-icon v-if="isLoading" size="lg" class="gl-mt-5" />

      <template v-else-if="hasRelease">
        <div
          v-if="statusLabel"
          class="gl-flex gl-gap-2 gl-pt-4"
          data-testid="release-header-badges"
        >
          <gl-badge :variant="statusVariant" data-testid="release-status-badge">
            {{ statusLabel }}
          </gl-badge>
        </div>

        <div class="gl-mb-5 gl-mt-4" data-testid="release-meta">
          <div class="gl-grid gl-grid-cols-1 gl-gap-3 gl-text-sm sm:gl-grid-cols-2">
            <div>
              <p class="gl-mb-1 gl-text-xs gl-font-bold gl-uppercase gl-text-secondary">
                {{ s__('ContinuousDeployment|Created') }}
              </p>
              <time-ago
                v-if="selectedRelease.createdAt"
                :time="selectedRelease.createdAt"
                data-testid="release-created"
              />
            </div>
            <div>
              <p class="gl-mb-1 gl-text-xs gl-font-bold gl-uppercase gl-text-secondary">
                {{ s__('ContinuousDeployment|Application') }}
              </p>
              <span v-if="applicationName" data-testid="release-application">
                {{ applicationName }}
              </span>
            </div>
          </div>
        </div>

        <p
          class="gl-mb-2 gl-mt-5 gl-text-xs gl-font-bold gl-uppercase gl-tracking-wider gl-text-secondary"
          data-testid="services-title"
        >
          {{ s__('ContinuousDeployment|Services in this release') }}
        </p>

        <ul
          v-if="hasEntries"
          class="gl-border gl-m-0 gl-list-none gl-rounded-lg gl-border-default gl-p-0"
        >
          <li
            v-for="(entry, index) in entries"
            :key="index"
            class="gl-border-b gl-flex gl-items-center gl-justify-between gl-border-default gl-px-3 gl-py-2 last:gl-border-b-0"
            data-testid="service-row"
          >
            <span class="gl-text-sm gl-font-semibold">{{ entry.service }}</span>
            <code
              class="gl-mb-0 gl-rounded-base gl-border-none gl-bg-subtle gl-px-2 gl-py-1 gl-text-sm gl-text-secondary"
              >{{ entry.version }}</code
            >
          </li>
        </ul>
        <p v-else class="gl-text-xs gl-text-subtle">
          {{ s__('ContinuousDeployment|No services in this release.') }}
        </p>

        <trigger-deployment
          v-if="organizationId"
          :organization-id="organizationId"
          :version-set-id="versionSetGid"
          :release-name="selectedRelease.name"
          @deploy-triggered="$emit('deploy-triggered')"
        />
      </template>

      <gl-empty-state
        v-else
        :title="s__('ContinuousDeployment|Release not found')"
        :description="
          s__('ContinuousDeployment|It may have been removed or you may not have access to it.')
        "
      />
    </dynamic-panel>
  </mounting-portal>
</template>
