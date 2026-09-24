<script>
import { GlModal } from '@gitlab/ui';
import { __ } from '~/locale';
import { DRAWER_Z_INDEX } from '~/lib/utils/constants';
import { glListenersMixin } from '~/lib/utils/vue3compat/gl_listeners_mixin';
import JobAssistantDrawer from 'jh_else_ce/ci/pipeline_editor/components/job_assistant_drawer/job_assistant_drawer.vue';
import CommitSection from '~/ci/pipeline_editor/components/commit/commit_section.vue';
import PipelineEditorDrawer from '~/ci/pipeline_editor/components/drawer/pipeline_editor_drawer.vue';
import PipelineEditorFileNav from '~/ci/pipeline_editor/components/file_nav/pipeline_editor_file_nav.vue';
import PipelineEditorHeader from '~/ci/pipeline_editor/components/header/pipeline_editor_header.vue';
import {
  CREATE_TAB,
  FILE_TREE_DISPLAY_KEY,
  EDITOR_APP_DRAWER_HELP,
  EDITOR_APP_DRAWER_JOB_ASSISTANT,
  EDITOR_APP_DRAWER_AI_ASSISTANT,
  EDITOR_APP_DRAWER_NONE,
} from '~/ci/pipeline_editor/constants';
import PipelineEditorTabs from './components/pipeline_editor_tabs.vue';
import CiComponentDrawer from './components/ci_component_drawer/ci_component_drawer.vue';
import { GUI_EDITOR_TAB, EDITOR_APP_DRAWER_COMPONENT_DRAWER } from './constants';

export default {
  EDITOR_APP_DRAWER_HELP,
  EDITOR_APP_DRAWER_JOB_ASSISTANT,
  EDITOR_APP_DRAWER_AI_ASSISTANT,
  commitSectionRef: 'commitSectionRef',
  modal: {
    switchBranch: {
      title: __('You have unsaved changes'),
      body: __('Uncommitted changes will be lost if you change branches. Do you want to continue?'),
      actionPrimary: {
        text: __('Switch Branches'),
      },
      actionSecondary: {
        text: __('Cancel'),
        attributes: { variant: 'default' },
      },
    },
  },
  name: 'PipelineGraphEditor',
  components: {
    CommitSection,
    GlModal,
    PipelineEditorDrawer,
    JobAssistantDrawer,
    PipelineEditorFileNav,
    PipelineEditorHeader,
    PipelineEditorTabs,
    CiComponentDrawer,
  },
  mixins: [glListenersMixin],
  props: {
    ciConfigData: {
      type: Object,
      required: true,
    },
    ciFileContent: {
      type: String,
      required: true,
    },
    commitSha: {
      type: String,
      required: false,
      default: '',
    },
    hasUnsavedChanges: {
      type: Boolean,
      required: false,
      default: false,
    },
    isNewCiConfigFile: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      currentDrawer: EDITOR_APP_DRAWER_NONE,
      currentTab: GUI_EDITOR_TAB,
      scrollToCommitForm: false,
      shouldLoadNewBranch: false,
      currentDrawerIndex: DRAWER_Z_INDEX,
      drawerIndex: {
        [EDITOR_APP_DRAWER_HELP]: DRAWER_Z_INDEX,
        [EDITOR_APP_DRAWER_JOB_ASSISTANT]: DRAWER_Z_INDEX,
        [EDITOR_APP_DRAWER_AI_ASSISTANT]: DRAWER_Z_INDEX,
      },
      showFileTree: false,
      showSwitchBranchModal: false,
    };
  },
  computed: {
    showCommitForm() {
      return this.currentTab === CREATE_TAB;
    },
    // The following is used by upstream component, we are simply overriding it
    // eslint-disable-next-line vue/no-unused-properties
    includesFiles() {
      return this.ciConfigData?.includes || [];
    },
    showHelpDrawer() {
      return this.currentDrawer === EDITOR_APP_DRAWER_HELP;
    },
    showJobAssistantDrawer() {
      return this.currentDrawer === EDITOR_APP_DRAWER_JOB_ASSISTANT;
    },
    showCiComponentDrawer() {
      return this.currentDrawer === EDITOR_APP_DRAWER_COMPONENT_DRAWER;
    },
  },
  mounted() {
    this.showFileTree = JSON.parse(localStorage.getItem(FILE_TREE_DISPLAY_KEY)) || false;
  },
  methods: {
    closeBranchModal() {
      this.showSwitchBranchModal = false;
    },
    handleConfirmSwitchBranch() {
      this.showSwitchBranchModal = true;
    },
    switchDrawer(drawerName) {
      this.currentDrawer = drawerName;
      if (this.drawerIndex[drawerName]) {
        this.currentDrawerIndex += 1;
        this.drawerIndex[drawerName] = this.currentDrawerIndex;
      }
    },
    toggleFileTree() {
      this.showFileTree = !this.showFileTree;
      localStorage.setItem(FILE_TREE_DISPLAY_KEY, this.showFileTree);
    },
    switchBranch() {
      this.showSwitchBranchModal = false;
      this.shouldLoadNewBranch = true;
    },
    setCurrentTab(tabName) {
      this.currentTab = tabName;
    },
    setScrollToCommitForm(newValue = true) {
      this.scrollToCommitForm = newValue;
    },
  },
};
</script>

<template>
  <div class="pipeline-graph-editor">
    <gl-modal
      v-if="showSwitchBranchModal"
      visible
      modal-id="switchBranchModal"
      :title="$options.modal.switchBranch.title"
      :action-primary="$options.modal.switchBranch.actionPrimary"
      :action-secondary="$options.modal.switchBranch.actionSecondary"
      @primary="switchBranch"
      @secondary="closeBranchModal"
      @cancel="closeBranchModal"
      @hide="closeBranchModal"
    >
      {{ $options.modal.switchBranch.body }}
    </gl-modal>
    <pipeline-editor-file-nav
      :has-unsaved-changes="hasUnsavedChanges"
      :is-new-ci-config-file="isNewCiConfigFile"
      :should-load-new-branch="shouldLoadNewBranch"
      @select-branch="handleConfirmSwitchBranch"
      @toggle-file-tree="toggleFileTree"
      v-on="glListeners()"
    />
    <div class="gl-flex gl-w-full gl-flex-col md:gl-flex-row">
      <!-- <pipeline-editor-file-tree
        v-if="showFileTree"
        class="gl-shrink-0"
        :includes="includesFiles"
      /> -->
      <div class="gl-min-w-0 gl-grow">
        <pipeline-editor-header
          :ci-config-data="ciConfigData"
          :commit-sha="commitSha"
          :is-new-ci-config-file="isNewCiConfigFile"
          v-on="glListeners()"
        />
        <pipeline-editor-tabs
          :ci-config-data="ciConfigData"
          :ci-file-content="ciFileContent"
          :commit-sha="commitSha"
          :current-tab="currentTab"
          :is-new-ci-config-file="isNewCiConfigFile"
          :show-help-drawer="showHelpDrawer"
          :show-job-assistant-drawer="showJobAssistantDrawer"
          v-on="glListeners()"
          @switch-drawer="switchDrawer"
          @set-current-tab="setCurrentTab"
          @walkthrough-popover-cta-clicked="setScrollToCommitForm"
        />
      </div>
    </div>
    <commit-section
      v-show="showCommitForm"
      :ref="$options.commitSectionRef"
      :ci-file-content="ciFileContent"
      :commit-sha="commitSha"
      :has-unsaved-changes="hasUnsavedChanges"
      :is-new-ci-config-file="isNewCiConfigFile"
      :scroll-to-commit-form="scrollToCommitForm"
      @scrolled-to-commit-form="setScrollToCommitForm(false)"
      v-on="glListeners()"
    />
    <pipeline-editor-drawer
      :is-visible="showHelpDrawer"
      :z-index="drawerIndex[$options.EDITOR_APP_DRAWER_HELP]"
      v-on="glListeners()"
      @switch-drawer="switchDrawer"
    />
    <job-assistant-drawer
      :ci-config-data="ciConfigData"
      :ci-file-content="ciFileContent"
      :is-visible="showJobAssistantDrawer"
      :z-index="drawerIndex[$options.EDITOR_APP_DRAWER_JOB_ASSISTANT]"
      v-on="glListeners()"
      @switch-drawer="switchDrawer"
    />
    <ci-component-drawer
      :ci-file-content="ciFileContent"
      :is-visible="showCiComponentDrawer"
      :z-index="drawerIndex[$options.EDITOR_APP_DRAWER_JOB_ASSISTANT]"
      v-on="glListeners()"
      @switch-drawer="switchDrawer"
    />
  </div>
</template>
