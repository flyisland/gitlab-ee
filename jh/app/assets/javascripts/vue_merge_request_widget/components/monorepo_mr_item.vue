<script>
import { GlBadge, GlIcon, GlBreadcrumb, GlTooltipDirective, GlLink } from '@gitlab/ui';
import {
  monorepoItemI18n,
  mrStateI18n,
  mrStateVariants,
  MONO_ITEM_STATUS_CLOSED,
  MONO_ITEM_STATUS_MERGED,
} from '../constants';

export default {
  name: 'MonoRepoMrItem',
  components: {
    GlBadge,
    GlBreadcrumb,
    GlIcon,
    GlLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    mr: {
      type: Object,
      required: true,
    },
  },
  computed: {
    shouldShowStateBadge() {
      return [MONO_ITEM_STATUS_CLOSED, MONO_ITEM_STATUS_MERGED].includes(this.mr.state);
    },
    stateBadgeText() {
      return mrStateI18n[this.mr.state];
    },
    stateBadgeVariant() {
      return mrStateVariants[this.mr.state];
    },
    pipelineStatusIconClass() {
      return `ci-status-icon-${this.mr.head_pipeline.group}`;
    },
  },
  i18n: monorepoItemI18n,
};
</script>

<template>
  <div class="monorepo-mr-item gl-flex gl-items-center gl-justify-between gl-py-3 gl-pl-8 gl-pr-5">
    <div class="monorepo-mr-meta">
      <div class="gl-mb-3 gl-flex">
        <gl-link :href="mr.path" target="_blank" rel="noreferer noopener">
          <span class="monorepo-mr-title gl-mr-3 gl-text-sm gl-font-bold">{{ mr.title }}</span>
        </gl-link>
        <gl-badge v-if="mr.mergeable" size="sm" variant="success">{{
          $options.i18n.mergeable
        }}</gl-badge>
      </div>
      <gl-breadcrumb :items="mr.breadcrumbs" />
    </div>
    <div class="mono-repo-mr-item-status gl-flex gl-items-center">
      <gl-badge
        v-if="shouldShowStateBadge"
        size="sm"
        :variant="stateBadgeVariant"
        class="gl-mr-4"
        >{{ stateBadgeText }}</gl-badge
      >
      <span v-if="mr.head_pipeline" :class="pipelineStatusIconClass">
        <gl-icon
          v-gl-tooltip.left
          :name="mr.head_pipeline.icon"
          :title="mr.head_pipeline.tooltip"
        />
      </span>
    </div>
  </div>
</template>
