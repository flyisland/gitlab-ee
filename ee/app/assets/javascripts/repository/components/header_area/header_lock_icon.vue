<script>
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

export default {
  name: 'HeaderLockIcon',
  components: {
    GlButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    isLocked: {
      type: Boolean,
      required: true,
      default: false,
    },
    lockUser: {
      type: Object,
      required: false,
      default: null,
    },
  },
  computed: {
    lockIconTooltip() {
      if (!this.lockUser?.name) {
        return __('Directory locked');
      }
      return sprintf(__('Directory locked by %{name}'), { name: this.lockUser.name }, false);
    },
  },
};
</script>

<template>
  <gl-button
    v-if="glFeatures.repositoryLockInformation && isLocked"
    v-gl-tooltip
    :title="lockIconTooltip"
    :aria-label="lockIconTooltip"
    category="tertiary"
    variant="default"
    icon="lock"
  />
</template>
