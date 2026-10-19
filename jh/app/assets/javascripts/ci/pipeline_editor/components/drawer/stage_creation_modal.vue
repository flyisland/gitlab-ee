<script>
import { GlModal, GlForm, GlFormGroup, GlFormInput } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  name: 'StageCreationDrawer',
  components: {
    GlModal,
    GlForm,
    GlFormGroup,
    GlFormInput,
  },
  data() {
    return {
      stageName: '',
    };
  },
  methods: {
    onCreateStage() {
      if (!this.stageName) {
        return;
      }

      this.$emit('create-stage', this.stageName);
    },
    // eslint-disable-next-line vue/no-unused-properties
    open() {
      this.stageName = '';
      this.$refs.stageCreationModal.show();
    },
  },
  primaryActions: {
    text: __('OK'),
    attributes: {
      'data-testid': 'stage-creation-modal-confirmation',
      variant: 'info',
    },
  },
  secondaryActions: {
    text: __('Cancel'),
    attributes: {
      'data-testid': 'stage-creation-modal-cancel',
    },
  },
};
</script>

<template>
  <gl-modal
    ref="stageCreationModal"
    :title="s__('JH|Pipelines|Create Stage')"
    :action-primary="$options.primaryActions"
    :action-secondary="$options.secondaryActions"
    modal-id="stage-creation-modal"
    data-testid="stage-creation-modal-content"
    @primary="onCreateStage"
    @canceled="$emit('close')"
  >
    <gl-form>
      <gl-form-group :label="s__('JH|Pipelines|Stage name')" required>
        <gl-form-input
          v-model="stageName"
          data-testid="stage-creation-name-input"
          :placeholder="s__('JH|Pipelines|Please input a stage name')"
        />
      </gl-form-group>
    </gl-form>
  </gl-modal>
</template>
