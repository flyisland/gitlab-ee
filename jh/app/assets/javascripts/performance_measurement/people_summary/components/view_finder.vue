<script>
import {
  GlButton,
  GlFormSelect,
  GlModal,
  GlFormGroup,
  GlFormInput,
  GlFormRadioGroup,
  GlFormRadio,
} from '@gitlab/ui';
import { BV_SHOW_MODAL } from '~/lib/utils/constants';
import { s__, __ } from '~/locale';

export default {
  components: {
    GlButton,
    GlFormSelect,
    GlModal,
    GlFormGroup,
    GlFormInput,
    GlFormRadioGroup,
    GlFormRadio,
  },
  data() {
    return {
      views: [{ text: s__('JH|PerformanceMeasurement|Default view'), value: 'default_view' }],
      selectedView: 'default_view',
      viewType: 'private',
      viewName: this.$options.i18n.defaultViewName,
    };
  },
  methods: {
    onSaveClicked() {
      this.resetView();
      this.$root.$emit(BV_SHOW_MODAL, this.$options.MODAL_ID);
    },
    onSave() {
      this.$emit('save', {
        name: this.viewName,
        type: this.viewType,
      });
    },
    resetView() {
      this.viewType = 'private';
      this.viewName = this.$options.i18n.defaultViewName;
    },
  },
  MODAL_ID: 'save-view-modal',
  i18n: {
    defaultViewName: s__('JH|PerformanceMeasurement|Default view'),
    viewSelectPlaceholder: s__('JH|PerformanceMeasurement|Select a view'),
  },
  primaryActions: { text: __('Save') },
  secondaryActions: { text: __('Cancel') },
};
</script>

<template>
  <div class="align-items-center gl-mb-5 gl-flex gl-gap-3">
    <strong>{{ s__('JH|PerformanceMeasurement|View') }}</strong>
    <gl-form-select
      v-model="selectedView"
      :placeholder="$options.i18n.viewSelectPlaceholder"
      :options="views"
      class="gl-max-w-15"
    />
    <gl-button @click="onSaveClicked">
      {{ __('Save') }}
    </gl-button>
    <gl-modal
      :modal-id="$options.MODAL_ID"
      :action-primary="$options.primaryActions"
      :action-cancel="$options.secondaryActions"
      @primary="onSave"
    >
      <gl-form-group :label="s__('JH|PerformanceMeasurement|View name')">
        <gl-form-input v-model="viewName" />
      </gl-form-group>
      <gl-form-group :label="s__('JH|PerformanceMeasurement|View type')">
        <gl-form-radio-group v-model="viewType" class="flex-row gl-flex gl-gap-5">
          <gl-form-radio value="private">
            {{ s__('JH|PerformanceMeasurement|Private') }}
          </gl-form-radio>
          <gl-form-radio value="public">
            {{ s__('JH|PerformanceMeasurement|Public') }}
          </gl-form-radio>
        </gl-form-radio-group>
      </gl-form-group>
    </gl-modal>
  </div>
</template>
