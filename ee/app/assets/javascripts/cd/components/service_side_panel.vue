<script>
import { GlBadge, GlButton, GlEmptyState, GlSprintf } from '@gitlab/ui';
import { MountingPortal } from 'portal-vue';
import { s__ } from '~/locale';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import { TYPENAME_CD_SERVICE } from 'ee/graphql_shared/constants';
import DynamicPanel from '~/vue_shared/components/dynamic_panel.vue';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import { SYNC_VARIANTS, SYNC_LABELS, HEALTH_VARIANTS, HEALTH_LABELS } from '../constants';
import cdServiceQuery from '../graphql/cd_service.query.graphql';
import ArtifactSourceCard from './artifact_source_card.vue';
import EnvironmentBreakdown from './environment_breakdown.vue';

export default {
  name: 'ServiceSidePanel',
  components: {
    GlBadge,
    GlButton,
    GlEmptyState,
    GlSprintf,
    DynamicPanel,
    MountingPortal,
    ArtifactSourceCard,
    TimeAgo,
    EnvironmentBreakdown,
  },
  props: {
    serviceId: {
      type: String,
      required: false,
      default: null,
    },
  },
  emits: ['close'],
  data() {
    return {
      selectedService: null,
    };
  },
  apollo: {
    selectedService: {
      query: cdServiceQuery,
      variables() {
        return { id: this.serviceGid };
      },
      update: (data) => data?.organization?.cdService ?? null,
      skip() {
        return !this.serviceId;
      },
    },
  },
  computed: {
    serviceGid() {
      return convertToGraphQLId(TYPENAME_CD_SERVICE, this.serviceId);
    },
    hasService() {
      return this.selectedService != null;
    },
    syncVariant() {
      return SYNC_VARIANTS[this.selectedService?.sync] ?? 'neutral';
    },
    syncLabel() {
      return SYNC_LABELS[this.selectedService?.sync] ?? this.selectedService?.sync ?? '';
    },
    healthVariant() {
      return HEALTH_VARIANTS[this.selectedService?.health] ?? 'neutral';
    },
    healthLabel() {
      return HEALTH_LABELS[this.selectedService?.health] ?? this.selectedService?.health;
    },
    hasHealth() {
      return this.selectedService?.health != null;
    },
    sourceRef() {
      return this.selectedService?.artifactSources?.nodes?.[0]?.sourceRef ?? '';
    },
    lastDeployedMessage() {
      if (!this.selectedService?.lastDeployed) return '';
      if (this.selectedService?.deployedBy) {
        return s__('ContinuousDeployment|%{timeAgo} by %{user}');
      }
      return s__('ContinuousDeployment|%{timeAgo}');
    },
    hasSyncLabel() {
      return Boolean(this.syncLabel);
    },
    artifactSources() {
      return this.selectedService?.artifactSources?.nodes ?? [];
    },
    hasArtifactSources() {
      return this.artifactSources.length > 0;
    },
    hasEnvironments() {
      return this.selectedService?.environments?.length > 0;
    },
  },
};
</script>

<template>
  <mounting-portal mount-to="#contextual-panel-portal" append>
    <dynamic-panel data-testid="service-side-panel" @close="$emit('close')">
      <template #header>
        <div class="gl-flex gl-w-full gl-items-center gl-justify-between gl-py-3">
          <div class="gl-flex gl-items-center gl-gap-3">
            <gl-button
              icon="chevron-left"
              category="tertiary"
              size="small"
              :aria-label="s__('ContinuousDeployment|Back to services')"
              data-testid="back-button"
              @click="$emit('close')"
            />
            <div v-if="hasService">
              <p
                class="gl-mb-2 gl-text-xs gl-font-bold gl-uppercase gl-tracking-wider gl-text-status-brand"
                data-testid="detail-eyebrow"
              >
                {{ s__('ContinuousDeployment|Service') }}
              </p>
              <h3 class="gl-my-0 gl-text-base" data-testid="detail-title">
                {{ selectedService.name }}
              </h3>
            </div>
          </div>
          <div v-if="hasService" class="gl-flex gl-gap-2" data-testid="detail-header-badges">
            <gl-badge v-if="hasHealth" :variant="healthVariant" data-testid="detail-health-badge">
              {{ healthLabel }}
            </gl-badge>
            <gl-badge v-if="hasSyncLabel" :variant="syncVariant" data-testid="detail-sync-badge">
              {{ syncLabel }}
            </gl-badge>
          </div>
        </div>
      </template>

      <div v-if="hasService" class="gl-pt-4" data-testid="detail-mode">
        <div class="gl-mb-5" data-testid="detail-meta">
          <div class="gl-grid gl-grid-cols-1 gl-gap-3 gl-text-sm sm:gl-grid-cols-2">
            <div>
              <p class="gl-mb-1 gl-text-xs gl-font-bold gl-uppercase gl-text-secondary">
                {{ s__('ContinuousDeployment|Source') }}
              </p>
              <span v-if="sourceRef" class="gl-font-monospace" data-testid="detail-source-ref">
                {{ sourceRef }}
              </span>
            </div>
            <div>
              <p class="gl-mb-1 gl-text-xs gl-font-bold gl-uppercase gl-text-secondary">
                {{ s__('ContinuousDeployment|Last deployed') }}
              </p>
              <span v-if="lastDeployedMessage" data-testid="detail-last-deployed">
                <gl-sprintf :message="lastDeployedMessage">
                  <template #timeAgo>
                    <time-ago :time="selectedService.lastDeployed" />
                  </template>
                  <template v-if="selectedService.deployedBy" #user>
                    {{ selectedService.deployedBy }}
                  </template>
                </gl-sprintf>
              </span>
            </div>
          </div>
        </div>

        <environment-breakdown
          v-if="hasEnvironments"
          :environments="selectedService.environments"
          class="gl-mb-5"
        />

        <div v-if="hasArtifactSources" data-testid="artifact-sources">
          <artifact-source-card
            v-for="source in artifactSources"
            :key="source.id"
            :artifact-source="source"
            class="gl-mb-4"
          />
        </div>
        <p v-else class="gl-text-secondary" data-testid="artifact-sources-empty">
          {{ s__('ContinuousDeployment|No artifact sources configured.') }}
        </p>
      </div>

      <gl-empty-state
        v-else
        :title="s__('ContinuousDeployment|Service not found')"
        :description="
          s__('ContinuousDeployment|It may have been removed or you may not have access to it.')
        "
      />
    </dynamic-panel>
  </mounting-portal>
</template>
