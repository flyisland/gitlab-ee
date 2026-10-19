<script>
import { GlButton, GlLink, GlSprintf, GlTooltip } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  name: 'RepositoryRequiredButton',
  components: {
    GlButton,
    GlLink,
    GlSprintf,
    GlTooltip,
  },
  // Bound by hand so the explicit `disabled` below beats a caller's `:disabled`
  // under Vue 3, where fallthrough attrs would otherwise win.
  inheritAttrs: false,
  props: {
    projectWebPath: {
      type: String,
      required: true,
    },
    size: {
      type: String,
      default: 'small',
      required: false,
    },
    variant: {
      type: String,
      default: 'default',
      required: false,
    },
    category: {
      type: String,
      default: 'primary',
      required: false,
    },
  },
  i18n: {
    repositoryEmptyTooltipMessage: s__(
      "DuoAgentPlatform|This project doesn't have a repository yet. %{linkStart}Add a repository%{linkEnd} to get started with flows.",
    ),
  },
};
</script>
<template>
  <gl-button
    ref="button"
    v-bind="$attrs"
    disabled
    accessible-disabled
    :category="category"
    icon="tanuki-ai"
    :size="size"
    :variant="variant"
    data-testid="duo-workflow-action-button"
  >
    <gl-tooltip
      :target="() => $refs.button && $refs.button.$el"
      triggers="hover focus"
      placement="top"
      boundary="viewport"
    >
      <gl-sprintf :message="$options.i18n.repositoryEmptyTooltipMessage">
        <template #link="{ content }">
          <gl-link :href="projectWebPath">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </gl-tooltip>
    <slot></slot>
  </gl-button>
</template>
