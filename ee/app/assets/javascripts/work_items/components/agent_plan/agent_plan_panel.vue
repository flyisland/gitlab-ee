<script>
import { isEmpty } from 'lodash-es';
import {
  GlButton,
  GlCollapsibleListbox,
  GlDisclosureDropdown,
  GlSkeletonLoader,
  GlTooltipDirective,
} from '@gitlab/ui';
import { MountingPortal } from 'portal-vue';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import MarkdownEditor from '~/vue_shared/components/markdown/markdown_editor.vue';
import EditorModeSwitcher from '~/vue_shared/components/markdown/editor_mode_switcher.vue';
import NonGfmMarkdown from '~/vue_shared/components/markdown/non_gfm_markdown.vue';
import { EDITING_MODE_MARKDOWN_FIELD, EDITING_MODE_CONTENT_EDITOR } from '~/vue_shared/constants';
import { s__ } from '~/locale';
import { updateHistory, setUrlParams, removeParams, queryToObject } from '~/lib/utils/url_utility';
import { DETAIL_VIEW_QUERY_PARAM_NAME } from '~/work_items/constants';
import { isWorkplanTemplate } from '~/work_items/utils';
import workplanTemplatesListQuery from '~/work_items/graphql/work_item_description_templates_list.query.graphql';
import workplanTemplateQuery from '~/work_items/graphql/work_item_description_template.query.graphql';
import namespacePathsQuery from '~/work_items/graphql/namespace_paths.query.graphql';

const PANEL_URL_VALUE = 'work-plan';
const RESTRICTED_TOOLBAR_ITEMS = ['full-screen'];
const SWITCHER_VALUE_MARKDOWN = 'markdown';
const SWITCHER_VALUE_RICH_TEXT = 'richText';

export default {
  name: 'AgentPlanPanel',
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    EditorModeSwitcher,
    GlButton,
    GlCollapsibleListbox,
    GlDisclosureDropdown,
    GlSkeletonLoader,
    MarkdownEditor,
    MountingPortal,
    NonGfmMarkdown,
  },
  inject: ['fullPath'],
  inheritAttrs: false,
  props: {
    open: {
      type: Boolean,
      required: true,
    },
    canUpdate: {
      type: Boolean,
      required: false,
      default: false,
    },
    savedContent: {
      type: String,
      required: false,
      default: '',
    },
    draftContent: {
      type: String,
      required: false,
      default: '',
    },
    appliedTemplateName: {
      type: String,
      required: false,
      default: null,
    },
    isEditing: {
      type: Boolean,
      required: false,
      default: false,
    },
    isSaving: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['close', 'save', 'delete', 'draft-change', 'start-edit', 'cancel-edit', 'regenerate'],
  data() {
    return {
      tmpContent: this.draftContent || this.savedContent,
      markdownPaths: {},
      workplanTemplates: [],
      workplanTemplateContent: null,
      selectedWorkplanTemplate: null,
      templateSearchTerm: '',
      editorMode: EDITING_MODE_MARKDOWN_FIELD,
      formFieldProps: {
        id: 'agent-plan',
        name: 'agent-plan',
        'aria-label': s__('AgentPlan|Workplan'),
      },
    };
  },
  computed: {
    areMarkdownPathsLoaded() {
      return !isEmpty(this.markdownPaths);
    },
    isEditingAllowed() {
      return this.canUpdate && !this.isEditing;
    },
    nextEditorMode() {
      return this.editorMode === EDITING_MODE_MARKDOWN_FIELD
        ? EDITING_MODE_CONTENT_EDITOR
        : EDITING_MODE_MARKDOWN_FIELD;
    },
    editorSwitcherValue() {
      return this.editorMode === EDITING_MODE_MARKDOWN_FIELD
        ? SWITCHER_VALUE_MARKDOWN
        : SWITCHER_VALUE_RICH_TEXT;
    },
    emptyStateText() {
      return this.canUpdate
        ? s__(
            'AgentPlan|Describe your intent for Duo. A workplan turns your description into an executable plan for autonomous task completion.',
          )
        : s__(
            "AgentPlan|No workplan has been added yet. You don't have permission to create or edit the workplan.",
          );
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
    panelHeading() {
      return s__('AgentPlan|Workplan');
    },
    editMoreActions() {
      const actions = [];
      if (this.savedContent) {
        actions.push({
          text: s__('AgentPlan|Regenerate workplan'),
          icon: 'tanuki-ai',
          action: () => this.$emit('regenerate'),
        });
        actions.push({
          text: s__('AgentPlan|Delete workplan'),
          icon: 'remove',
          action: () => this.deletePlan(),
          variant: 'danger',
        });
      }
      return actions;
    },
  },
  watch: {
    open: {
      immediate: true,
      handler(value) {
        if (value) {
          updateHistory({
            url: setUrlParams({ [DETAIL_VIEW_QUERY_PARAM_NAME]: PANEL_URL_VALUE }),
          });
        } else {
          const currentValue = queryToObject(window.location.search)?.[
            DETAIL_VIEW_QUERY_PARAM_NAME
          ];
          if (currentValue === PANEL_URL_VALUE) {
            updateHistory({ url: removeParams([DETAIL_VIEW_QUERY_PARAM_NAME]) });
          }
        }
      },
    },
    isEditing(value) {
      if (value) {
        this.tmpContent = this.draftContent || this.savedContent;
      }
    },
    appliedTemplateName: {
      immediate: true,
      handler(newVal) {
        if (newVal) {
          this.selectedWorkplanTemplate = {
            name: newVal,
            projectId: null,
            category: null,
          };
        }
      },
    },
  },
  mounted() {
    document.addEventListener('keydown', this.handleKeydown);
  },
  beforeDestroy() {
    document.removeEventListener('keydown', this.handleKeydown);
  },
  apollo: {
    markdownPaths: {
      query: namespacePathsQuery,
      variables() {
        return {
          fullPath: this.fullPath,
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
    handleClose() {
      const active = document.activeElement;
      const activeTag = active?.tagName;
      if (
        document.body.classList.contains('modal-open') ||
        active?.closest('.js-editor') != null ||
        activeTag === 'INPUT' ||
        activeTag === 'TEXTAREA'
      ) {
        return;
      }
      this.$emit('close');
    },
    handleKeydown({ key }) {
      if (key === 'Escape' && this.open) {
        this.handleClose();
      }
    },
    toggleEditorMode() {
      this.$refs.markdownEditor?.onEditingModeChange(this.nextEditorMode);
    },
    onEditorModeSynced(mode) {
      this.editorMode = mode;
    },
    cancelEdit() {
      this.selectedWorkplanTemplate = this.appliedTemplateName
        ? { name: this.appliedTemplateName, projectId: null, category: null }
        : null;
      this.$emit('cancel-edit');
    },
    savePlan() {
      this.$emit('save', {
        content: this.tmpContent?.trim() || '',
        templateName: this.selectedWorkplanTemplate?.name || null,
      });
    },
    deletePlan() {
      this.tmpContent = '';
      this.selectedWorkplanTemplate = null;
      this.$emit('delete');
    },
    handleInput(value) {
      this.tmpContent = value;
      this.$emit('draft-change', value);
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
  RESTRICTED_TOOLBAR_ITEMS,
  EDITING_MODE_MARKDOWN_FIELD,
  EDITING_MODE_CONTENT_EDITOR,
};
</script>

<template>
  <mounting-portal v-if="open" mount-to="#contextual-panel-portal" append>
    <div data-testid="agent-plan-panel" class="work-item-detail-panel gl-leading-reset">
      <div class="work-item-detail-panel-header">
        <div class="gl-flex gl-h-full gl-min-w-0 gl-grow gl-items-center gl-gap-2">
          <span
            class="gl-truncate gl-text-sm gl-font-bold gl-text-default"
            data-testid="agent-plan-panel-title"
          >
            {{ panelHeading }}
          </span>
        </div>
        <template v-if="isEditingAllowed">
          <gl-button
            size="small"
            category="secondary"
            data-testid="panel-edit-button"
            @click="$emit('start-edit')"
          >
            {{ s__('AgentPlan|Edit') }}
          </gl-button>
          <gl-disclosure-dropdown
            v-if="editMoreActions.length"
            v-gl-tooltip.bottom
            size="small"
            category="tertiary"
            icon="ellipsis_v"
            no-caret
            text-sr-only
            :toggle-text="__('More actions')"
            :title="__('More actions')"
            :items="editMoreActions"
            data-testid="panel-edit-more-actions"
          />
        </template>
        <gl-button
          v-gl-tooltip.bottom
          class="gl-detail-panel-close-button"
          data-testid="panel-close-button"
          category="tertiary"
          icon="close"
          size="small"
          :aria-label="__('Close panel')"
          :title="__('Close panel')"
          @click="handleClose"
        />
      </div>
      <div
        :class="
          isEditing
            ? 'gl-flex gl-min-h-0 gl-flex-1 gl-flex-col'
            : 'work-item-detail-panel-content gl-px-5 gl-pt-4'
        "
      >
        <template v-if="!isEditing">
          <p
            v-if="!savedContent"
            data-testid="agent-plan-empty-state"
            class="gl-mb-0 gl-text-subtle"
          >
            {{ emptyStateText }}
          </p>
          <template v-else>
            <non-gfm-markdown :markdown="savedContent" data-testid="agent-plan-rendered" />
          </template>
        </template>
        <template v-else>
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
          <div class="common-note-form gl-flex gl-min-h-0 gl-flex-1 gl-flex-col">
            <!--
              eslint-disable vue/v-on-event-hyphenation
            -->
            <markdown-editor
              v-if="areMarkdownPathsLoaded"
              ref="markdownEditor"
              :value="tmpContent"
              :render-markdown-path="markdownPaths.markdownPreviewPath"
              :uploads-path="markdownPaths.uploadsPath"
              :form-field-props="formFieldProps"
              :enable-autocomplete="false"
              autofocus
              immersive
              fill-container
              hide-mode-switcher
              enable-content-editor
              :restricted-tool-bar-items="$options.RESTRICTED_TOOLBAR_ITEMS"
              data-testid="agent-plan-editor"
              @input="handleInput"
              @keydown.meta.enter="savePlan"
              @keydown.ctrl.enter="savePlan"
              @markdownField="onEditorModeSynced($options.EDITING_MODE_MARKDOWN_FIELD)"
              @contentEditor="onEditorModeSynced($options.EDITING_MODE_CONTENT_EDITOR)"
            >
              <template #header>
                <div
                  class="gl-flex gl-items-center gl-justify-between gl-gap-2 gl-py-2 gl-pl-2 gl-pr-5"
                >
                  <editor-mode-switcher
                    :value="editorSwitcherValue"
                    data-testid="agent-plan-editor-mode-switcher"
                    @switch="toggleEditorMode"
                  />
                  <div class="gl-flex gl-gap-2">
                    <gl-button
                      :disabled="isSaving"
                      size="small"
                      data-testid="cancel-agent-plan-button"
                      @click="cancelEdit"
                    >
                      {{ __('Cancel') }}
                    </gl-button>
                    <gl-button
                      variant="confirm"
                      size="small"
                      :loading="isSaving"
                      data-testid="save-agent-plan-button"
                      @click="savePlan"
                    >
                      {{ __('Save changes') }}
                    </gl-button>
                  </div>
                </div>
              </template>
            </markdown-editor>
            <!-- eslint-enable vue/v-on-event-hyphenation -->
          </div>
        </template>
      </div>
    </div>
  </mounting-portal>
</template>
