<script>
import {
  GlAlert,
  GlFormCheckbox,
  GlIcon,
  GlLink,
  GlModal,
  GlSprintf,
  GlTooltipDirective,
} from '@gitlab/ui';
import { __, n__, s__, sprintf } from '~/locale';
import { helpPagePath } from '~/helpers/help_page_helper';
import { formatDefaultModelData } from 'ee/ai/shared/utils/model_selection_utils';

export default {
  name: 'AvailableModelsModal',
  components: {
    GlAlert,
    GlFormCheckbox,
    GlIcon,
    GlLink,
    GlModal,
    GlSprintf,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    availableModels: {
      type: Array,
      required: true,
    },
    featureTitle: {
      type: String,
      required: true,
    },
    chosenModelForFeature: {
      type: Object,
      required: true,
    },
    gitlabDefaultModel: {
      type: Object,
      required: false,
      default: null,
    },
    allowListEnabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    visible: {
      type: Boolean,
      required: false,
      default: false,
    },
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
    errorMessage: {
      type: String,
      required: false,
      default: '',
    },
  },
  emits: ['update:visible', 'update:error-message', 'save'],
  gitlabManagedModelsHelpPage: helpPagePath('administration/gitlab_duo_self_hosted/_index', {
    anchor: 'gitlab-managed-models',
  }),
  data() {
    return {
      enabled: this.allowListEnabled,
      selectedModels: this.availableModels.filter((m) => m.allowed).map((m) => m.ref),
    };
  },
  computed: {
    modalTitle() {
      return sprintf(s__('AdminAIPoweredFeatures|Available models: %{featureTitle}'), {
        featureTitle: this.featureTitle,
      });
    },
    actionPrimary() {
      return {
        text: __('Save'),
        attributes: {
          variant: 'confirm',
          loading: this.loading,
          disabled: this.enabled && this.onlyLockedModelIsSelected,
        },
      };
    },
    actionCancel() {
      return { text: __('Cancel') };
    },
    selectedModelsSummary() {
      if (!this.enabled) {
        return n__(
          'AdminAIPoweredFeatures|All available models (%d model)',
          'AdminAIPoweredFeatures|All available models (%d models)',
          this.availableModels.length,
        );
      }

      return n__(
        'AdminAIPoweredFeatures|%d model selected',
        'AdminAIPoweredFeatures|%d models selected',
        this.selectedModels.length,
      );
    },
    onlyLockedModelIsSelected() {
      return this.selectedModels.length === 1 && this.isLockedModel(this.selectedModels[0]);
    },
  },
  methods: {
    isLockedModel(modelRef) {
      return modelRef === this.chosenModelForFeature.ref;
    },
    isGitLabDefaultModel(modelRef) {
      return modelRef === this.gitlabDefaultModel?.ref;
    },
    getModelDisplayName(model) {
      if (this.isGitLabDefaultModel(model.ref)) {
        const { text } = formatDefaultModelData(model);
        return text;
      }

      return model.name;
    },
    onAllowListEnabledChange(value) {
      this.selectedModels = value ? this.availableModels.map((m) => m.ref) : [];
    },
    onSubmit() {
      this.$emit('save', {
        enabled: this.enabled,
        allowedModelRefs: this.enabled ? [...this.selectedModels] : [],
      });
    },
    onHidden() {
      this.$emit('update:error-message', '');
      this.$emit('update:visible', false);
    },
  },
};
</script>
<template>
  <gl-modal
    modal-id="available-models-modal"
    :visible="visible"
    :title="modalTitle"
    :action-primary="actionPrimary"
    :action-cancel="actionCancel"
    @primary.prevent="onSubmit"
    @hidden="onHidden"
  >
    <gl-alert
      v-if="errorMessage"
      class="gl-mb-4"
      variant="danger"
      data-testid="allow-list-error"
      :dismissible="false"
    >
      {{ errorMessage }}
    </gl-alert>
    <div data-testid="allow-list-checkbox">
      <gl-form-checkbox v-model="enabled" @change="onAllowListEnabledChange">
        {{ s__('AdminAIPoweredFeatures|Restrict to specific models') }}
        <template #help>
          <span class="gl-text-subtle">
            <gl-sprintf
              :message="
                s__(
                  'AdminAIPoweredFeatures|When turned on, users can only use the models selected below, which always includes the currently selected default model. When turned off, users can use all available %{linkStart}GitLab managed models%{linkEnd} (including those added in the future), unless a non-GitLab default model is set as the model for Agentic Chat, in which case users can only use that model.',
                )
              "
            >
              <template #link="{ content }">
                <gl-link :href="$options.gitlabManagedModelsHelpPage" target="_blank">{{
                  content
                }}</gl-link>
              </template>
            </gl-sprintf>
          </span>
        </template>
      </gl-form-checkbox>
    </div>
    <p data-testid="selected-models-summary" class="gl-mt-3 gl-text-subtle">
      {{ selectedModelsSummary }}
    </p>
    <div
      class="gl-mt-4 gl-max-h-34 gl-overflow-y-auto gl-rounded-lg gl-border-1 gl-border-solid gl-border-default"
    >
      <div
        v-for="model in availableModels"
        :key="model.ref"
        data-testid="model-item"
        class="gl-flex gl-px-4 gl-py-3"
      >
        <div v-if="enabled" data-testid="model-checkbox" class="gl-mt-1">
          <gl-form-checkbox
            v-model="selectedModels"
            :value="model.ref"
            :disabled="isLockedModel(model.ref)"
          />
        </div>
        <div data-testid="model-text">
          <div :class="{ 'gl-text-subtle': enabled && isLockedModel(model.ref) }">
            <span data-testid="model-name" class="gl-font-bold">{{
              getModelDisplayName(model)
            }}</span>
            <span>{{ model.costIndicator }}</span>
            <span
              v-if="enabled && isLockedModel(model.ref)"
              v-gl-tooltip
              :title="
                s__(
                  'AdminAIPoweredFeatures|This is the currently selected model for Agentic Chat, which is always available to users. To remove it from the list, select a different model.',
                )
              "
              data-testid="locked-model-indicator"
            >
              <gl-icon name="lock" :size="16" variant="subtle" />
            </span>
          </div>
          <div class="gl-text-subtle">
            {{ model.modelDescription }}
          </div>
        </div>
      </div>
    </div>
  </gl-modal>
</template>
