<script>
import { GlModal, GlSprintf } from '@gitlab/ui';
import { __, s__ } from '~/locale';

export default {
  name: 'OrbitStartTrialModal',
  components: { GlModal, GlSprintf },
  props: {
    visible: { type: Boolean, required: true },
    groupName: { type: String, required: true },
    starting: { type: Boolean, required: true },
  },
  emits: ['start-trial', 'hide'],
  computed: {
    actionPrimary() {
      return {
        text: s__('Orbit|Start free trial'),
        attributes: { variant: 'confirm', loading: this.starting },
      };
    },
  },
  actionCancel: { text: __('Cancel') },
};
</script>

<template>
  <gl-modal
    modal-id="orbit-start-trial-modal"
    :visible="visible"
    :title="s__('Orbit|Start a free Orbit trial?')"
    :action-primary="actionPrimary"
    :action-cancel="$options.actionCancel"
    @primary.prevent="$emit('start-trial')"
    @hidden="$emit('hide')"
  >
    <p>
      <gl-sprintf
        :message="
          s__(
            'Orbit|Orbit turns on for %{groupName} and indexes the group, its subgroups, and projects. Indexing can take up to a few hours.',
          )
        "
      >
        <template #groupName>{{ groupName }}</template>
      </gl-sprintf>
    </p>
    <p class="gl-mb-0">
      {{
        s__(
          'Orbit|The free trial is for this group only. When the trial ends or the credits run out, Orbit pauses until you add GitLab credits.',
        )
      }}
    </p>
  </gl-modal>
</template>
