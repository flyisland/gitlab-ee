<script>
import { GlTab, GlBadge, GlAlert } from '@gitlab/ui';
import { glListenersMixin } from '~/lib/utils/vue3compat/gl_listeners_mixin';
import CeEditorTab from '~/ci/pipeline_editor/components/ui/editor_tab.vue';
import EmptyState from '../graph/empty_state.vue';

export default {
  components: {
    GlTab,
    GlBadge,
    GlAlert,
    MountSpy: CeEditorTab.components.MountSpy,
    EmptyState,
  },
  extends: CeEditorTab,
  mixins: [glListenersMixin],
};
</script>

<template>
  <gl-tab :lazy="isLazy" v-bind="$attrs" v-on="glListeners()">
    <template #title>
      <span>{{ title }}</span>
      <gl-badge v-if="hasBadgeTitle" class="gl-ml-2" :variant="badgeVariant">{{
        badgeTitle
      }}</gl-badge>
    </template>
    <template v-if="isEmpty">
      <empty-state />
    </template>
    <gl-alert v-else-if="isUnavailable" variant="danger" :dismissible="false">
      {{ $options.i18n.unavailable }}</gl-alert
    >
    <gl-alert v-else-if="isInvalid" variant="danger">{{ $options.i18n.invalid }}</gl-alert>
    <template v-else>
      <slot v-for="slot in slots" :name="slot"></slot>
      <mount-spy @hook:mounted="onContentMounted" />
    </template>
  </gl-tab>
</template>
