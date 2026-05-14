<script>
import { GlButton, GlIcon, GlModal } from '@gitlab/ui';
import { __, s__ } from '~/locale';

export default {
  actionCancel: {
    text: __('Cancel'),
  },
  actionPrimary: {
    text: __('Disable'),
    attributes: {
      variant: 'confirm',
    },
  },
  name: 'WorkItemTypesCustomization',
  components: {
    GlButton,
    GlIcon,
    GlModal,
  },
  data() {
    return {
      enabled: false,
      showModal: false,
    };
  },
  computed: {
    buttonText() {
      return this.enabled ? s__('WorkItem|Disable') : s__('WorkItem|Enable');
    },
    statusIcon() {
      return this.enabled ? 'check' : 'cancel';
    },
    statusText() {
      return this.enabled ? s__('WorkItem|Enabled') : s__('WorkItem|Disabled');
    },
    statusTextColor() {
      return this.enabled ? 'gl-text-success' : 'gl-text-danger';
    },
  },
  methods: {
    handleClick() {
      if (this.enabled) {
        this.showModal = true;
      } else {
        this.enabled = true;
      }
    },
    handleModal() {
      this.enabled = false;
    },
  },
};
</script>

<template>
  <div
    class="gl-border gl-mb-5 gl-flex gl-items-center gl-justify-between gl-gap-3 gl-rounded-xl gl-bg-subtle gl-p-4"
  >
    <div>
      <h3 class="gl-m-0 gl-mb-1 gl-text-base">
        {{ s__('WorkItem|Type customization in projects') }}
      </h3>
      <span class="gl-text-subtle">
        {{ s__('WorkItem|Allow types to be disabled in projects.') }}
      </span>
    </div>
    <div
      class="gl-flex gl-items-center gl-whitespace-nowrap"
      :class="statusTextColor"
      data-testid="status-block"
    >
      <gl-icon class="gl-mr-2" :name="statusIcon" />
      {{ statusText }}
      <gl-button class="gl-ml-4" size="small" @click="handleClick">{{ buttonText }}</gl-button>
    </div>
    <gl-modal
      v-model="showModal"
      :action-cancel="$options.actionCancel"
      :action-primary="$options.actionPrimary"
      modal-id="type-customization-modal"
      :title="s__('WorkItem|Disable type customization in projects')"
      @primary="handleModal"
    >
      {{
        s__(
          'WorkItem|All available types will be enabled in all groups and projects. Re-enabling this setting later will return each group or project to its current configuration.',
        )
      }}
    </gl-modal>
  </div>
</template>
