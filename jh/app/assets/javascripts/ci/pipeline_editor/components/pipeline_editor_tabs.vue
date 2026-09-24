<script>
import { GlTabs, GlLoadingIcon, GlAlert, GlButton } from '@gitlab/ui';
import { parseDocument, visit, Scalar, isMap } from 'yaml';
import { getParameterValues, setUrlParams, updateHistory } from '~/lib/utils/url_utility';
import { glListenersMixin } from '~/lib/utils/vue3compat/gl_listeners_mixin';
import PipelineEditorTabs from '~/ci/pipeline_editor/components/pipeline_editor_tabs.vue';
import EditorTab from '~/ci/pipeline_editor/components/ui/editor_tab.vue';
import CiConfigMergedPreview from '~/ci/pipeline_editor/components/editor/ci_config_merged_preview.vue';
import CiEditorHeader from '~/ci/pipeline_editor/components/editor/ci_editor_header.vue';
import CiValidate from '~/ci/pipeline_editor/components/validate/ci_validate.vue';
import TextEditor from '~/ci/pipeline_editor/components/editor/text_editor.vue';
import PipelineGraph from '~/ci/pipeline_editor/components/graph/pipeline_graph.vue';
import { TAB_QUERY_PARAM } from '~/ci/pipeline_editor/constants';
import { TABS_INDEX, GUI_EDITOR_TAB, EDITOR_APP_DRAWER_COMPONENT_DRAWER } from '../constants';
import GuiEditor from './graph/pipeline_graph.vue';
import JhEditorTab from './ui/editor_tab.vue';

export default {
  components: {
    GlAlert,
    GlTabs,
    GlButton,
    GlLoadingIcon,
    CiConfigMergedPreview,
    CiEditorHeader,
    CiValidate,
    TextEditor,
    PipelineGraph,
    EditorTab,
    GuiEditor,
    JhEditorTab,
  },
  extends: PipelineEditorTabs,
  mixins: [glListenersMixin],
  data() {
    return {
      showJhHelpMsg: true,
    };
  },
  computed: {
    parsedDocument() {
      return parseDocument(this.ciFileContent);
    },
  },
  created() {
    const [tabQueryParam] = getParameterValues(TAB_QUERY_PARAM);
    const tabName = Object.keys(TABS_INDEX)[tabQueryParam];

    if (tabName) {
      this.setDefaultTab(tabName);
    }
  },

  methods: {
    showCiComponentsDrawer() {
      this.$emit('switch-drawer', EDITOR_APP_DRAWER_COMPONENT_DRAWER);
    },
    addStage(stageName, position) {
      const content = this.parsedDocument;

      visit(content, {
        Pair: (_, pair) => {
          if (pair.key.value === 'stages') {
            if (pair.value.items.some((item) => item.value === stageName)) {
              return;
            }

            const newStage = new Scalar(stageName);
            newStage.type = 'PLAIN';
            newStage.style = 'plain';
            pair.value.items.splice(position, 0, newStage);
            this.$emit('updateCiConfig', content.toString());
          }
        },
      });

      this.updateConfig(content);
    },

    deleteStage(stageName) {
      const content = this.parsedDocument;

      visit(content, {
        Pair: (_, pair) => {
          if (pair.key.value === 'stages') {
            const index = pair.value.items.findIndex((item) => item.value === stageName);
            pair.value.items.splice(index, 1);
            if (pair.value.items.length === 0) {
              return visit.REMOVE;
            }
          } else if (isMap(pair.value)) {
            const { items } = pair.value;
            if (
              items.length > 0 &&
              items.some(({ key, value }) => key.value === 'stage' && value.value === stageName)
            ) {
              return visit.REMOVE;
            }
          }

          return null;
        },
      });

      this.updateConfig(content);
    },

    updateConfig(config) {
      this.$emit('updateCiConfig', config.toString());
    },
    deleteJob(jobName) {
      const content = this.parsedDocument;
      visit(content, {
        // eslint-disable-next-line consistent-return
        Pair(_, pair) {
          if (pair.key.value === jobName) {
            return visit.REMOVE;
          }
        },
      });

      this.updateConfig(content);
    },
    setDefaultTab(tabName) {
      // We associate tab name with the index so that we can use tab name
      // in other part of the app and load the corresponding tab closer to the
      // actual component using a hash that binds the name to the indexes.
      // This also means that if we ever changed tab order, we would justs need to
      // update `TABS_INDEX` hash instead of all the instances in the app
      // where we used the individual indexes
      const newUrl = setUrlParams({ [TAB_QUERY_PARAM]: TABS_INDEX[tabName] });

      this.setCurrentTab(tabName);
      updateHistory({ url: newUrl, title: document.title, replace: true });
    },
  },
  tabConstants: {
    ...PipelineEditorTabs.tabConstants,
    GUI_EDITOR_TAB,
  },
};
</script>
<template>
  <gl-tabs
    class="file-editor gl-mb-3"
    data-testid="file-editor-container"
    :query-param-name="$options.query.TAB_QUERY_PARAM"
    sync-active-tab-with-query-params
  >
    <editor-tab
      class="gl-mb-3"
      :title="$options.i18n.tabEdit"
      lazy
      data-testid="editor-tab"
      @click="setCurrentTab($options.tabConstants.CREATE_TAB)"
    >
      <ci-editor-header
        :show-help-drawer="showHelpDrawer"
        :show-job-assistant-drawer="showJobAssistantDrawer"
        v-on="glListeners()"
      >
        <gl-button icon="applications" @click="showCiComponentsDrawer">
          {{ s__('JH|CiComponents|Add components') }}
        </gl-button>
      </ci-editor-header>
      <text-editor :commit-sha="commitSha" :value="ciFileContent" v-on="glListeners()" />
    </editor-tab>
    <editor-tab
      class="gl-mb-3"
      :empty-message="$options.i18n.empty.visualization"
      :is-empty="isEmpty"
      :is-invalid="isInvalid"
      :is-unavailable="isLintUnavailable"
      :keep-component-mounted="false"
      :title="$options.i18n.tabGraph"
      lazy
      data-testid="visualization-tab"
      @click="setCurrentTab($options.tabConstants.VISUALIZE_TAB)"
    >
      <gl-loading-icon v-if="isLoading" size="lg" class="gl-m-3" />
      <pipeline-graph v-else :pipeline-data="ciConfigData" />
    </editor-tab>
    <editor-tab
      class="gl-mb-3"
      data-testid="validate-tab"
      :badge-title="validateTabBadgeTitle"
      :title="$options.i18n.tabValidate"
      @click="setCurrentTab($options.tabConstants.VALIDATE_TAB)"
    >
      <ci-validate :ci-file-content="ciFileContent" />
    </editor-tab>
    <editor-tab
      class="gl-mb-3"
      :empty-message="$options.i18n.empty.merge"
      :keep-component-mounted="false"
      :is-empty="isEmpty"
      :is-unavailable="isLintUnavailable"
      :title="$options.i18n.tabMergedYaml"
      lazy
      data-testid="merged-tab"
      @click="setCurrentTab($options.tabConstants.MERGED_TAB)"
    >
      <gl-loading-icon v-if="isLoading" size="lg" class="gl-m-3" />
      <gl-alert v-else-if="!isMergedYamlAvailable" variant="danger" :dismissible="false">
        {{ $options.errorTexts.loadMergedYaml }}
      </gl-alert>
      <ci-config-merged-preview v-else :ci-config-data="ciConfigData" v-on="glListeners()" />
    </editor-tab>
    <jh-editor-tab
      class="gl-mb-3"
      :empty-message="$options.i18n.empty.visualization"
      :is-empty="isEmpty"
      :is-invalid="isInvalid"
      :is-unavailable="isLintUnavailable"
      :keep-component-mounted="false"
      :title="s__('JH|Pipelines|GUI Editor')"
      lazy
      data-testid="gui-editor-tab"
      @click="setCurrentTab($options.tabConstants.GUI_EDITOR_TAB)"
    >
      <gl-loading-icon v-if="isLoading" size="lg" class="gl-m-3" />
      <gui-editor
        v-else
        :pipeline-data="ciConfigData"
        :ci-file-content="ciFileContent"
        :show-help-msg="showJhHelpMsg"
        v-on="glListeners()"
        @add-stage="addStage"
        @delete-stage="deleteStage"
        @delete-job="deleteJob"
        @dismiss-help="showJhHelpMsg = false"
      />
    </jh-editor-tab>
  </gl-tabs>
</template>
