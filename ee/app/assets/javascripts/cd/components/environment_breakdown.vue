<script>
import { GlBadge } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import { SYNC_VARIANTS, SYNC_LABELS, TIER_ORDER, TIER_LABELS } from '../constants';

export default {
  name: 'EnvironmentBreakdown',
  components: {
    GlBadge,
  },
  props: {
    environments: {
      type: Array,
      required: true,
    },
  },
  tierLabels: TIER_LABELS,
  computed: {
    groupedByTier() {
      const groups = this.environments.reduce((acc, env) => {
        const tier = env.tier ?? 'unknown';
        if (!acc[tier]) {
          acc[tier] = [];
        }
        acc[tier].push(env);
        return acc;
      }, {});
      const knownTiers = TIER_ORDER.filter((tier) => groups[tier]?.length > 0).map((tier) => ({
        tier,
        environments: groups[tier],
      }));
      const remainingTiers = Object.keys(groups)
        .filter((tier) => !TIER_ORDER.includes(tier))
        .map((tier) => ({
          tier,
          environments: groups[tier],
        }));
      return [...knownTiers, ...remainingTiers];
    },
  },
  methods: {
    syncVariant(value) {
      return SYNC_VARIANTS[value] ?? 'neutral';
    },
    syncLabel(value) {
      return SYNC_LABELS[value] ?? value ?? '';
    },
    podsLabel(pods) {
      return sprintf(s__('ContinuousDeployment|%{pods} pods'), { pods });
    },
  },
};
</script>

<template>
  <div v-if="groupedByTier.length > 0" data-testid="environment-breakdown">
    <div
      v-for="group in groupedByTier"
      :key="group.tier"
      class="gl-mb-4"
      :data-testid="`tier-group-${group.tier}`"
    >
      <h4
        class="gl-mb-2 gl-text-xs gl-font-bold gl-uppercase gl-text-secondary"
        data-testid="tier-heading"
      >
        {{ $options.tierLabels[group.tier] ?? group.tier }}
      </h4>
      <div
        v-for="env in group.environments"
        :key="env.name"
        class="gl-border-b gl-flex gl-flex-wrap gl-items-center gl-gap-3 gl-border-default gl-py-2 gl-text-sm"
        :data-testid="`env-row-${env.name}`"
      >
        <span class="gl-min-w-28 gl-font-bold" data-testid="env-name">{{ env.name }}</span>
        <span class="gl-font-monospace gl-text-secondary" data-testid="env-version">
          {{ env.version }}
        </span>
        <span class="gl-text-secondary" data-testid="env-pods">
          {{ podsLabel(env.pods) }}
        </span>
        <span v-if="env.restarts" class="gl-text-secondary" data-testid="env-restarts">
          · {{ env.restarts }}
        </span>
        <gl-badge
          v-if="syncLabel(env.sync)"
          :variant="syncVariant(env.sync)"
          size="sm"
          class="gl-ml-auto"
          data-testid="env-sync-badge"
        >
          {{ syncLabel(env.sync) }}
        </gl-badge>
      </div>
    </div>
  </div>
</template>
