<script>
import { GlModal, GlLoadingIcon } from '@gitlab/ui';
import CEPipelineEditorApp from '~/ci/pipeline_editor/pipeline_editor_app.vue';
import PipelineEditorMessages from '~/ci/pipeline_editor/components/ui/pipeline_editor_messages.vue';
import PipelineEditorHome from '~/ci/pipeline_editor/pipeline_editor_home.vue';
import ConfirmUnsavedChangesDialog from '~/vue_shared/components/confirm_unsaved_changes_dialog.vue';
import { updateHistory, setUrlParams } from '~/lib/utils/url_utility';
import { TAB_QUERY_PARAM } from '~/ci/pipeline_editor/constants';

import { TABS_INDEX, GUI_EDITOR_TAB } from './constants';
import PipelineGraphEditor from './pipeline_graph_editor.vue';
import PipelineEditorEmptyState from './components/ui/pipeline_editor_empty_state.vue';

export default {
  name: 'JHPipelineEditorApp',
  components: {
    ...CEPipelineEditorApp.components,
    PipelineGraphEditor,
    PipelineEditorEmptyState,
    PipelineEditorMessages,
    PipelineEditorHome,
    ConfirmUnsavedChangesDialog,
    GlModal,
    GlLoadingIcon,
  },
  extends: CEPipelineEditorApp,
  data() {
    return {
      showGraphEditor: false,
    };
  },
  methods: {
    initGraphEditor() {
      const newUrl = setUrlParams({ [TAB_QUERY_PARAM]: TABS_INDEX[GUI_EDITOR_TAB] });
      updateHistory({ url: newUrl, title: document.title, replace: true });
      this.setNewEmptyCiConfigFile();
      this.showGraphEditor = true;
    },
  },
};
</script>

<template>
  <div class="gl-relative gl-mt-4">
    <gl-loading-icon v-if="isBlobContentLoading" size="lg" class="gl-m-3" />
    <pipeline-editor-empty-state
      v-else-if="showEmptyState"
      @init-graph-editor="initGraphEditor"
      @create-empty-config-file="setNewEmptyCiConfigFile"
    />
    <template v-else>
      <div v-if="showGraphEditor">
        <pipeline-graph-editor
          :ci-config-data="ciConfigData"
          :ci-file-content="currentCiFileContent"
          :commit-sha="commitSha"
          :has-unsaved-changes="hasUnsavedChanges"
          :is-new-ci-config-file="isNewCiConfigFile"
          @commit="updateOnCommit"
          @reset-content="confirmReset"
          @show-error="showErrorAlert"
          @update-ci-config="updateCiConfig"
          @update-commit-sha="updateCommitSha"
        />
      </div>
      <div v-else>
        <pipeline-editor-messages
          :failure-type="failureType"
          :failure-reasons="failureReasons"
          :show-failure="showFailure"
          @hide-failure="hideFailure"
        />
        <pipeline-editor-home
          :ci-config-data="ciConfigData"
          :ci-file-content="currentCiFileContent"
          :commit-sha="commitSha"
          :has-unsaved-changes="hasUnsavedChanges"
          :is-new-ci-config-file="isNewCiConfigFile"
          @commit="updateOnCommit"
          @reset-content="confirmReset"
          @show-error="showErrorAlert"
          @update-ci-config="updateCiConfig"
          @update-commit-sha="updateCommitSha"
        />
        <gl-modal
          v-model="showResetConfirmationModal"
          modal-id="reset-content"
          :title="$options.i18n.resetModal.title"
          :action-cancel="$options.i18n.resetModal.actionCancel"
          :action-primary="$options.i18n.resetModal.actionPrimary"
          @primary="resetContent"
        >
          {{ $options.i18n.resetModal.body }}
        </gl-modal>
        <confirm-unsaved-changes-dialog :has-unsaved-changes="hasUnsavedChanges" />
      </div>
    </template>
  </div>
</template>
