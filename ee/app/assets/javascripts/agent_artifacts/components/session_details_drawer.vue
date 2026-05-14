<script>
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import { MountingPortal } from 'portal-vue';
import { __ } from '~/locale';
import { formatAgentDefinition } from 'ee/ai/duo_agents_platform/utils';

export default {
  name: 'SessionDetailsDrawer',
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlButton,
    MountingPortal,
  },
  props: {
    activeItem: {
      type: Object,
      required: true,
    },
  },
  emits: ['close'],
  computed: {
    formattedName() {
      return formatAgentDefinition(this.activeItem?.name);
    },
  },
  mounted() {
    document.addEventListener('keydown', this.closeOnEscape);
  },
  beforeDestroy() {
    document.removeEventListener('keydown', this.closeOnEscape);
  },
  methods: {
    handleClose() {
      this.$emit('close');
    },
    closeOnEscape({ key }) {
      if (key === 'Escape') {
        this.handleClose();
      }
    },
  },
  i18n: {
    closePanelText: __('Close panel'),
  },
};
</script>

<template>
  <mounting-portal mount-to="#contextual-panel-portal" append>
    <div data-testid="session-details-drawer" class="work-item-drawer gl-pt-4 gl-leading-reset">
      <div
        class="work-item-drawer-header gl-flex gl-items-center gl-gap-x-2 gl-px-4 @xl/panel:gl-px-6"
      >
        <h2 class="gl-m-0 gl-grow gl-text-sm gl-text-default" data-testid="drawer-title">
          {{ formattedName }}
        </h2>
        <gl-button
          v-gl-tooltip.bottom
          class="gl-drawer-close-button"
          category="tertiary"
          icon="close"
          size="small"
          :aria-label="$options.i18n.closePanelText"
          :title="$options.i18n.closePanelText"
          data-testid="session-details-drawer-close-button"
          @click="handleClose"
        />
      </div>
      <div class="js-dynamic-panel-inner work-item-drawer-content gl-px-4 @xl/panel:gl-px-6">
        <h4 class="gl-mt-6" data-testid="drawer-content-title">
          {{ formattedName }}
        </h4>
      </div>
    </div>
  </mounting-portal>
</template>
