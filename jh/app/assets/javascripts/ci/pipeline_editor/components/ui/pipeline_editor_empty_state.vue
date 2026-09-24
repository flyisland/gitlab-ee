<script>
import { GlButton, GlCard, GlEmptyState } from '@gitlab/ui';
import CEPipelineEditorApp from '~/ci/pipeline_editor/components/ui/pipeline_editor_empty_state.vue';
import DuoAnalyzeCard from 'ee_component/ci/pipeline_editor/components/ui/duo_analyze_card.vue';
import glAbilitiesMixin from '~/vue_shared/mixins/gl_abilities_mixin';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import ExternalConfigEmptyState from '~/ci/common/empty_state/external_config_empty_state.vue';

export default {
  name: 'PipelineEditorEmptyState',
  components: {
    DuoAnalyzeCard,
    ExternalConfigEmptyState,
    GlButton,
    GlCard,
    GlEmptyState,
  },
  extends: CEPipelineEditorApp,
  mixins: [glFeatureFlagMixin(), glAbilitiesMixin()],
  computed: {
    jhCiGraphEditorEnabled() {
      return Boolean(this.glFeatures.jhCiGraphEditor);
    },
  },
};
</script>

<template>
  <div>
    <external-config-empty-state v-if="usesExternalConfig" :new-pipeline-path="newPipelinePath" />
    <gl-empty-state
      v-if="usesExternalConfig"
      :title="$options.i18n.externalCiNote"
      :description="$options.i18n.externalCiInstructions"
      :svg-path="emptyStateIllustrationPath"
    />

    <gl-empty-state
      v-else
      :title="__('Get up and running with GitLab CI/CD')"
      :svg-path="$options.emptyStateIllustrationPath"
      :svg-height="100"
      content-class="gl-max-w-full"
    >
      <template #description>
        {{ __('Streamline your development process effortlessly with robust CI/CD pipelines.') }}
      </template>
    </gl-empty-state>
    <div class="gl-w-max-full gl-flex gl-flex-wrap gl-items-stretch gl-justify-center gl-gap-5">
      <duo-analyze-card
        v-if="glAbilities.accessDuoAgenticChat"
        @create-empty-config-file="createEmptyConfigFile"
      />
      <gl-card
        class="gl-w-64 gl-max-w-lg gl-overflow-hidden gl-bg-default gl-shadow-md"
        header-class="gl-border-bottom-none gl-pt-5 gl-pb-3"
        body-class="gl-flex gl-flex-col gl-items-center gl-justify-center gl-bg-default gl-text-center gl-pt-0 gl-pb-6"
      >
        <template #header>
          <span class="gl-block gl-text-center gl-font-bold">{{
            s__('Pipelines|Use a CI/CD component')
          }}</span>
        </template>
        <template #default>
          <p class="gl-h-11">
            {{ s__('Pipelines|Start with a pre-built and customizable CI/CD component.') }}
          </p>
          <gl-button class="gl-mt-3" :href="ciCatalogPath" data-testid="browse-catalog-button">
            {{ s__('Pipelines|Browse catalog') }}
          </gl-button>
        </template>
      </gl-card>
      <gl-card
        class="gl-w-64 gl-max-w-lg gl-bg-default gl-shadow-md"
        header-class="gl-border-bottom-none gl-pt-5 gl-pb-3"
        body-class="gl-flex gl-flex-col gl-items-center gl-justify-center gl-text-center gl-pt-0 gl-pb-6"
      >
        <template #header>
          <span class="gl-block gl-text-center gl-font-bold">{{
            s__('Pipelines|Write your own')
          }}</span>
        </template>
        <template #default>
          <p class="gl-h-11">
            {{
              s__('Pipelines|Write your own CI/CD configuration by hand, starting from scratch.')
            }}
          </p>
          <gl-button
            variant="confirm"
            class="gl-mr-3 gl-mt-3"
            data-testid="create-new-ci-button"
            @click="createEmptyConfigFile"
          >
            {{ s__('Pipelines|Start building') }}
          </gl-button>
          <gl-button
            v-if="jhCiGraphEditorEnabled"
            variant="default"
            class="gl-mt-3"
            data-testid="create-new-ci-with-graph-editor"
            @click="$emit('init-graph-editor')"
          >
            {{ s__('JH|Pipeline|Edit with GUI') }}
          </gl-button>
        </template>
      </gl-card>
    </div>
  </div>
</template>

<style>
.gl-border-bottom-none {
  border-bottom-style: none;
}
</style>
