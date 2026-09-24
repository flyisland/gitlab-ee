<script>
import {
  GlTooltipDirective,
  GlAlert,
  GlButton,
  GlDisclosureDropdown,
  GlDisclosureDropdownItem,
  GlSprintf,
} from '@gitlab/ui';
import { parse } from 'yaml';
import { s__ } from '~/locale';
import { glListenersMixin } from '~/lib/utils/vue3compat/gl_listeners_mixin';
import PipelineGraph from '~/ci/pipeline_editor/components/graph/pipeline_graph.vue';
import JobAssistantDrawer from 'jh/ci/pipeline_editor/components/job_assistant_drawer/job_assistant_drawer.vue';
import { groupJobs, filterJobs } from 'jh/ci/pipeline_editor/utils';
import StageCreationModal from '../drawer/stage_creation_modal.vue';
import EmptyState from './empty_state.vue';

const defaultStages = ['.pre', 'build', 'test', 'deploy', '.post'];

export default {
  components: {
    StageCreationModal,
    JobAssistantDrawer,
    GlAlert,
    GlButton,
    GlDisclosureDropdown,
    GlDisclosureDropdownItem,
    EmptyState,
    GlSprintf,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  extends: PipelineGraph,
  mixins: [glListenersMixin],
  props: {
    ciFileContent: {
      type: String,
      required: true,
    },
    showHelpMsg: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      stages: [],
      hasNoStageDeclaration: false,
      jobCreationDrawer: false,
      stageCreationPosition: -1,
      targetStage: '',
      groupedPipeline: {},
    };
  },
  watch: {
    ciFileContent: {
      handler(value) {
        try {
          // using yaml-1.1 to parse the document since the "<<:" syntax is
          // deprecated in yaml-1.2
          const parsedDocument = parse(value, { version: '1.1' });

          const { stages } = parsedDocument;
          const groupedJobs = groupJobs(stages, filterJobs(parsedDocument));
          this.groupedPipeline = groupedJobs;

          if (stages) {
            this.stages = stages;
            this.hasNoStageDeclaration = false;
          } else {
            this.configHasNoStages(groupedJobs);
          }
        } catch (e) {
          this.onError(e);
        }
      },
      immediate: true,
    },
  },
  methods: {
    addStage(stageName) {
      this.$emit('add-stage', stageName, this.stageCreationPosition);
      this.stageCreationPosition = -1;
    },
    deleteStage(stageName) {
      this.$emit('delete-stage', stageName);
    },
    onAddJobClicked(stage) {
      this.toggleJobCreationDrawer(true, stage);
    },
    openStageCreationModal(position) {
      this.$refs.stageCreationModal.open();
      this.stageCreationPosition = position;
    },
    toggleJobCreationDrawer(visibility = false, stage) {
      this.jobCreationDrawer = visibility;
      this.targetStage = stage;
    },
    configHasNoStages(jobs) {
      this.hasNoStageDeclaration = true;
      const mappedStages = Object.keys(jobs);

      const hasUndefinedStages = mappedStages.some((stage) => {
        return !defaultStages.includes(stage);
      });

      if (!hasUndefinedStages) {
        const stages = [];

        defaultStages.forEach((stage) => {
          if (mappedStages.includes(stage)) {
            stages.push(stage);
          }
        });

        this.stages = stages;
      }
    },
  },
  i18n: {
    noStageDeclarations: s__(
      'JH|Pipelines|Stage operation is turned off because no explicit stage declarations were found in config file.',
    ),
    saveWork: s__(
      'JH|pipelineEditorWalkthrough|Use the %{boldStart}Edit%{boldEnd} tab at the left of the tabs to save the your work.',
    ),
  },
  canvasHeight:
    'calc(calc(80vh - calc(calc(var(--header-height) + calc(var(--system-header-height) + var(--performance-bar-height))) + var(--top-bar-height)) - var(--system-footer-height)) - var(--header-height, 48px) - var(--broadcast-message-height, 0px))',
};
</script>
<template>
  <div class="gl-overflow-auto" :style="{ height: $options.canvasHeight }">
    <template v-if="hasError">
      <gl-alert
        v-if="hasError"
        :variant="failure.variant"
        :dismissible="failure.dismissible"
        @dismiss="resetFailure"
      >
        {{ failure.text }}
      </gl-alert>
      <empty-state @add-stage="openStageCreationModal(0)" />
    </template>
    <gl-alert
      v-if="showHelpMsg"
      data-testid="save-work-help-msg"
      class="gl-mb-4"
      dismissible
      @dismiss="$emit('dismiss-help')"
    >
      <gl-sprintf :message="$options.i18n.saveWork">
        <template #bold="{ content }">
          <strong>
            {{ content }}
          </strong>
        </template>
      </gl-sprintf>
    </gl-alert>
    <gl-alert v-if="hasNoStageDeclaration" class="gl-mb-4" variant="danger" :dismissible="false">
      {{ $options.i18n.noStageDeclarations }}
    </gl-alert>
    <div
      :id="containerId"
      :ref="$options.CONTAINER_REF"
      style="height: calc(100% - 68px)"
      class="gl-relative gl-flex"
      data-testid="graph-container"
    >
      <div
        v-for="(name, index) in stages"
        :key="`stage-${name}`"
        :data-testid="`stage-${name}`"
        class="jh-stage-list gl-mr-7 gl-box-border gl-h-full gl-flex-col gl-bg-gray-50 gl-p-5"
        style="min-width: 280px"
      >
        <div class="gl-mb-4 gl-flex gl-w-full gl-items-center gl-justify-between">
          <div>
            <strong>{{ name }}</strong>
            <span>{{ groupedPipeline[name].length }}</span>
          </div>
          <div>
            <gl-button
              :aria-label="s__('JH|Pipelines|Add job')"
              category="primary"
              icon="plus"
              size="small"
              data-testid="add-job-button"
              @click="onAddJobClicked(name)"
            >
              {{ s__('JH|Pipelines|Add job') }}
            </gl-button>
            <gl-disclosure-dropdown
              v-if="!hasNoStageDeclaration"
              v-gl-tooltip.hover
              :title="s__('JH|Pipelines|Stage operations')"
              :toggle-text="s__('JH|Pipelines|Stage operations')"
              data-testid="stage-action-dropdown-trigger"
              placement="right-start"
              icon="ellipsis_v"
              category="tertiary"
              text-sr-only
              no-caret
            >
              <gl-disclosure-dropdown-item
                data-testid="stage-action-insert-before"
                @action="openStageCreationModal(index)"
              >
                <template #list-item>
                  <span>
                    {{ s__('JH|Pipelines|Add stage before') }}
                  </span>
                </template>
              </gl-disclosure-dropdown-item>
              <gl-disclosure-dropdown-item
                data-testid="stage-action-insert-after"
                @action="openStageCreationModal(index + 1)"
              >
                <template #list-item>
                  <span>
                    {{ s__('JH|Pipelines|Add stage after') }}
                  </span>
                </template>
              </gl-disclosure-dropdown-item>
              <gl-disclosure-dropdown-item
                data-testid="stage-action-delete"
                @action="deleteStage(name)"
              >
                <template #list-item>
                  <span class="text-danger">{{ s__('JH|Pipelines|Delete stage') }}</span>
                </template>
              </gl-disclosure-dropdown-item>
            </gl-disclosure-dropdown>
          </div>
        </div>
      </div>
    </div>
    <stage-creation-modal
      ref="stageCreationModal"
      @create-stage="addStage"
      @close="stageCreationPosition = -1"
    />
    <job-assistant-drawer
      :ci-config-data="pipelineData"
      :ci-file-content="ciFileContent"
      :is-visible="jobCreationDrawer"
      :stage="targetStage"
      v-on="glListeners()"
      @switch-drawer="toggleJobCreationDrawer(false, '')"
    />
  </div>
</template>
