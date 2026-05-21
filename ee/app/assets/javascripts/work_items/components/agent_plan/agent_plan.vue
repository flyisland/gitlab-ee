<script>
import { isEmpty } from 'lodash-es';
import {
  GlButton,
  GlCollapsibleListbox,
  GlExperimentBadge,
  GlIcon,
  GlSkeletonLoader,
  GlTooltipDirective,
} from '@gitlab/ui';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import CrudComponent from '~/vue_shared/components/crud_component.vue';
import MarkdownEditor from '~/vue_shared/components/markdown/markdown_editor.vue';
import { s__, sprintf } from '~/locale';
import { clearDraft, getDraft, updateDraft } from '~/lib/utils/autosave';
import { isWorkplanTemplate } from '~/work_items/utils';
import workplanTemplatesListQuery from '~/work_items/graphql/work_item_description_templates_list.query.graphql';
import workplanTemplateQuery from '~/work_items/graphql/work_item_description_template.query.graphql';
import namespacePathsQuery from '~/work_items/graphql/namespace_paths.query.graphql';
import DuoChatQuickAction from 'ee/ai/shared/widgets/duo_chat_quick_action.vue';

// TODO: If we like this setup, we'd move this over to become a System Prompt of a Custom Agent.
// Then the user query can be more succinct, like "Prepare Workplan for Work Item ID #XYZ"
// Additionally, it should make use the the workplan templates that we define in https://gitlab.com/gitlab-org/gitlab/-/merge_requests/234690
const AGENTIC_PROMPT = s__(
  `AgentPlan|You are here to help refine a plan for the user from the Work Item context to a Markdown output with key information required for Agent to pick off the work. The template should have a Why, How, What format with key insights and list of steps. If the issue is lacking details, start by reading the comments. Then, ask clarifying questions to the users in Chat until you are confident. If there are pending questions, please preserve them inside the plan. Then, please proceed with updating the work item 'Workplan' widget with your output. You can erase everything was there before and add your new plan entirely. Don't preserve existing notes if they dont align with what you wrote. If there is enough information but the title or description is lacking, please propose to update it minimally with key insights. Try to preserve anything that is already present, just add on top and dont repeat the full plan. What is important is syncing up enough to preserve the intent and adding data where we had none before.`,
);

export default {
  name: 'AgentPlan',
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    CrudComponent,
    DuoChatQuickAction,
    GlButton,
    GlCollapsibleListbox,
    GlExperimentBadge,
    GlIcon,
    GlSkeletonLoader,
    MarkdownEditor,
  },
  inject: {
    fullPath: {
      default: '',
    },
  },
  props: {
    canUpdate: {
      type: Boolean,
      required: false,
      default: false,
    },
    content: {
      type: String,
      required: false,
      default: '',
    },
    workItemId: {
      type: String,
      required: false,
      default: null,
    },
  },
  emits: ['save', 'delete'],
  data() {
    return {
      isEditing: false,
      isCollapsed: false,
      markdownPaths: {},
      // TODO: add a watcher to update tmpContent when content updates
      // It will be easer to implement and test with real backend data later
      tmpContent: this.content,
      savedContent: this.content,
      formFieldProps: {
        id: 'agent-plan',
        name: 'agent-plan',
        'aria-label': s__('AgentPlan|Workplan'),
      },
      workplanTemplates: [],
      workplanTemplateContent: null,
      selectedWorkplanTemplate: null,
      templateSearchTerm: '',
      appliedTemplateName: null,
    };
  },
  computed: {
    areMarkdownPathsLoaded() {
      return !isEmpty(this.markdownPaths);
    },
    displayContent() {
      return this.savedContent;
    },
    planStorageKey() {
      return this.workItemId ? `agent-plan-draft-${this.workItemId}` : null;
    },
    templateStorageKey() {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      return this.planStorageKey ? `${this.planStorageKey}-template` : null;
    },
    planSummaryText() {
      return this.appliedTemplateName
        ? sprintf(s__('AgentPlan|Plan defined based on %{templateName}'), {
            templateName: this.appliedTemplateName,
          })
        : s__('AgentPlan|Plan defined');
    },
    areWorkplanTemplatesLoading() {
      return this.$apollo.queries.workplanTemplates.loading;
    },
    hasWorkplanTemplates() {
      return this.workplanTemplates.some(({ name }) => isWorkplanTemplate(name));
    },
    workplanTemplateItems() {
      return this.workplanTemplates
        .filter(({ name }) => isWorkplanTemplate(name))
        .filter(({ name }) =>
          this.templateSearchTerm
            ? name.toLowerCase().includes(this.templateSearchTerm.toLowerCase())
            : true,
        )
        .reduce((groups, current) => {
          const category =
            // eslint-disable-next-line @gitlab/require-i18n-strings
            current.category === 'Project Templates'
              ? s__('WorkItem|Project Workplan Templates')
              : current.category;
          const idx = groups.findIndex((group) => group.text === category);
          const option = {
            value: this.makeWorkplanTemplateValue(current),
            text: current.name,
          };
          if (idx > -1) {
            groups[idx].options.push(option);
          } else {
            groups.push({
              text: category,
              options: [option],
            });
          }
          return groups;
        }, []);
    },
    selectedWorkplanTemplateValue() {
      if (!this.selectedWorkplanTemplate) {
        return undefined;
      }
      return this.makeWorkplanTemplateValue(this.selectedWorkplanTemplate);
    },
    workplanTemplateToggleText() {
      return this.selectedWorkplanTemplate?.name || s__('AgentPlan|Choose a workplan template');
    },
  },
  watch: {
    content(newVal) {
      this.savedContent = newVal;
      this.tmpContent = newVal;
    },
  },
  created() {
    const { content, templateName } = this.loadFromStorage();
    if (content) {
      this.savedContent = content;
      this.tmpContent = content;
    }
    if (templateName) {
      this.appliedTemplateName = templateName;
    }
  },
  apollo: {
    markdownPaths: {
      query: namespacePathsQuery,
      variables() {
        return {
          fullPath: this.fullPath,
          iidForMarkdownPreview: this.workItemIid,
        };
      },
      update(data) {
        return data?.namespace?.markdownPaths || {};
      },
      skip() {
        return !this.fullPath;
      },
    },
    workplanTemplates: {
      query: workplanTemplatesListQuery,
      variables() {
        return {
          fullPath: this.fullPath,
        };
      },
      update(data) {
        return data?.namespace?.workItemDescriptionTemplates?.nodes || [];
      },
      skip() {
        return !this.fullPath;
      },
      error(e) {
        Sentry.captureException(e);
      },
    },
    workplanTemplateContent: {
      query: workplanTemplateQuery,
      variables() {
        return {
          name: this.selectedWorkplanTemplate.name,
          projectId: this.selectedWorkplanTemplate.projectId,
          fromNamespace: this.fullPath,
        };
      },
      update(data) {
        return data?.workItemDescriptionTemplateContent?.content;
      },
      skip() {
        return !this.selectedWorkplanTemplate?.projectId;
      },
      result() {
        if (this.workplanTemplateContent != null) {
          this.applyWorkplanTemplate(this.workplanTemplateContent);
        }
      },
      error(e) {
        Sentry.captureException(e);
      },
    },
  },
  methods: {
    persistField(key, value) {
      if (!key) return;
      if (value) {
        updateDraft(key, value);
      } else {
        clearDraft(key);
      }
    },
    loadFromStorage() {
      return {
        content: this.planStorageKey ? getDraft(this.planStorageKey) : null,
        templateName: this.templateStorageKey ? getDraft(this.templateStorageKey) : null,
      };
    },
    persistToStorage({ content, templateName }) {
      this.persistField(this.planStorageKey, content);
      this.persistField(this.templateStorageKey, templateName);
    },
    clearStorage() {
      this.persistField(this.planStorageKey, null);
      this.persistField(this.templateStorageKey, null);
    },
    startEditing() {
      this.isEditing = true;
      this.isCollapsed = false;
      const { content } = this.loadFromStorage();
      if (content !== null && content !== undefined) {
        this.tmpContent = content;
      }
      if (this.appliedTemplateName) {
        this.selectedWorkplanTemplate = {
          name: this.appliedTemplateName,
          projectId: null,
          category: null,
        };
      }
    },
    cancelEdit() {
      this.isEditing = false;
      this.tmpContent = this.savedContent;
      this.selectedWorkplanTemplate = null;
      this.persistToStorage({
        content: this.savedContent,
        templateName: this.appliedTemplateName,
      });
    },
    savePlan() {
      this.$emit('save', this.tmpContent);
      this.isEditing = false;
      this.savedContent = this.tmpContent;
      this.appliedTemplateName = this.selectedWorkplanTemplate?.name || null;
      this.persistToStorage({
        content: this.savedContent,
        templateName: this.appliedTemplateName,
      });
    },
    deletePlan() {
      this.$emit('delete');
      this.tmpContent = '';
      this.savedContent = '';
      this.appliedTemplateName = null;
      this.selectedWorkplanTemplate = null;
      this.clearStorage();
    },
    handleInput(value) {
      this.tmpContent = value;
      this.persistField(this.planStorageKey, value);
    },
    handleSelectWorkplanTemplate(value) {
      try {
        const { name, projectId, category } = JSON.parse(value);
        this.selectedWorkplanTemplate = { name, projectId, category };
      } catch (e) {
        Sentry.captureException(e);
      }
    },
    handleWorkplanTemplateSearch(term) {
      this.templateSearchTerm = term;
    },
    applyWorkplanTemplate(content) {
      this.handleInput(content);
    },
    makeWorkplanTemplateValue({ name, category, projectId }) {
      return JSON.stringify({ name, category, projectId });
    },
  },
  duoQuickAction: {
    command: {
      agenticPrompt: AGENTIC_PROMPT,
    },
    tracking: { label: 'create_work_plan' },
    buttonOptions: { icon: 'tanuki-ai', category: 'primary' },
  },
};
</script>

<template>
  <crud-component
    :is-collapsible="true"
    :collapsed="isCollapsed"
    anchor-id="agent-plan"
    @collapsed="isCollapsed = true"
    @expanded="isCollapsed = false"
  >
    <template #title>
      <div class="gl-flex gl-flex-wrap gl-gap-4">
        {{ s__('AgentPlan|Workplan') }}
        <gl-icon name="tanuki-ai" variant="subtle" />
        <gl-experiment-badge class="!gl-mx-0 -gl-my-1 gl-self-center" />
      </div>
    </template>

    <template #actions>
      <gl-button
        v-if="canUpdate && !isEditing"
        v-gl-tooltip
        icon="pencil"
        category="tertiary"
        size="small"
        :aria-label="s__('AgentPlan|Edit workplan')"
        :title="s__('AgentPlan|Edit workplan')"
        data-testid="edit-agent-plan-button"
        @click="startEditing"
      />
    </template>

    <template v-if="!isEditing">
      <p v-if="!displayContent" data-testid="agent-plan-empty-state" class="gl-mb-0 gl-text-subtle">
        {{
          canUpdate
            ? s__(
                'AgentPlan|Describe your intent for Duo. A workplan structures context into an agent-ready input for autonomous execution.',
              )
            : s__(
                "AgentPlan|No workplan has been added yet. You don't have permission to edit the workplan.",
              )
        }}
      </p>
      <div
        v-else
        data-testid="agent-plan-defined"
        class="gl-flex gl-items-center gl-justify-between gl-gap-3 gl-rounded-base gl-p-3"
      >
        <div class="gl-flex gl-items-center gl-gap-3">
          <gl-icon name="markdown-mark" variant="subtle" />
          <span class="gl-hyphens-auto gl-break-words gl-font-semibold">
            {{ planSummaryText }}
          </span>
        </div>
        <div>
          <gl-button
            v-gl-tooltip
            class="gl-relative gl-z-2 -gl-mr-2 -gl-mt-1"
            category="tertiary"
            size="small"
            icon="remove"
            :aria-label="__('Delete')"
            :title="__('Delete')"
            data-testid="delete-agent-plan-button"
            @click="deletePlan"
          />
        </div>
      </div>
    </template>

    <template v-else>
      <div class="gl-mb-3 gl-flex gl-justify-end">
        <duo-chat-quick-action
          v-if="workItemId"
          :resource-id="workItemId"
          :button-text="s__('AgentPlan|Generate workplan with Duo')"
          :command="$options.duoQuickAction.command"
          :tracking-info="$options.duoQuickAction.tracking"
          :button-options="$options.duoQuickAction.buttonOptions"
          data-testid="generate-with-duo-button"
        />
      </div>
      <gl-skeleton-loader v-if="areWorkplanTemplatesLoading" />
      <gl-collapsible-listbox
        v-else-if="hasWorkplanTemplates"
        :items="workplanTemplateItems"
        :toggle-text="workplanTemplateToggleText"
        :selected="selectedWorkplanTemplateValue"
        :header-text="s__('AgentPlan|Select workplan template')"
        searchable
        block
        class="gl-mb-3 gl-w-30"
        data-testid="agent-plan-template-dropdown"
        @select="handleSelectWorkplanTemplate"
        @search="handleWorkplanTemplateSearch"
      >
        <template #list-item="{ item }">
          <span class="gl-break-words" data-testid="agent-plan-template-item">
            {{ item.text }}
          </span>
        </template>
      </gl-collapsible-listbox>
      <div class="common-note-form">
        <markdown-editor
          v-if="areMarkdownPathsLoaded"
          :value="tmpContent"
          :render-markdown-path="markdownPaths.markdownPreviewPath"
          :uploads-path="markdownPaths.uploadsPath"
          :form-field-props="formFieldProps"
          :enable-autocomplete="false"
          :autofocus="true"
          data-testid="agent-plan-editor"
          @input="handleInput"
          @keydown.meta.enter="savePlan"
          @keydown.ctrl.enter="savePlan"
        />
      </div>
      <div class="gl-mt-4 gl-flex gl-gap-3">
        <gl-button variant="confirm" data-testid="save-agent-plan-button" @click="savePlan">
          {{ __('Save changes') }}
        </gl-button>
        <gl-button data-testid="cancel-agent-plan-button" @click="cancelEdit">
          {{ __('Cancel') }}
        </gl-button>
      </div>
    </template>
  </crud-component>
</template>
