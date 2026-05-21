<script>
import { defineComponent } from 'vue';
import { GlButton, GlCollapsibleListbox } from '@gitlab/ui';
import { editor as monacoEditor } from 'monaco-editor';
import { EDITOR_READY_EVENT } from '~/editor/constants';
import dark from '~/ide/lib/themes/dark';
import { darkModeEnabled } from '~/lib/utils/color_utils';
import { s__ } from '~/locale';
import SourceEditor from '~/vue_shared/components/source_editor.vue';

export default defineComponent({
  name: 'ExplorerQueryPanel',
  compatConfig: { MODE: 3 },
  components: {
    GlButton,
    GlCollapsibleListbox,
    SourceEditor,
  },
  isDark: darkModeEnabled(),
  editorOptions: {
    minimap: { enabled: false },
    scrollBeyondLastLine: false,
    lineNumbers: 'on',
    renderLineHighlight: 'none',
    glyphMargin: false,
    folding: false,
    lineDecorationsWidth: 0,
    lineNumbersMinChars: 3,
    fontSize: 13,
    tabSize: 2,
  },
  props: {
    queryText: {
      type: String,
      required: true,
    },
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
    templateItems: {
      type: Array,
      required: true,
    },
    selectedTemplate: {
      type: String,
      required: false,
      default: null,
    },
  },
  emits: ['update:query-text', 'execute', 'clear', 'template-select'],
  i18n: {
    templatesPlaceholder: s__('Orbit|Templates'),
  },
  computed: {
    templateToggleText() {
      const match = this.templateItems.find((item) => item.value === this.selectedTemplate);
      return match?.text || this.$options.i18n.templatesPlaceholder;
    },
  },
  methods: {
    onEditorReady() {
      if (this.$options.isDark) {
        monacoEditor.defineTheme('gl-dark', dark);
        monacoEditor.setTheme('gl-dark');
      }
    },
  },
  readyEvent: EDITOR_READY_EVENT,
});
</script>

<template>
  <div
    class="explorer-query-panel gl-flex gl-w-full gl-flex-col"
    data-testid="explorer-query-panel"
  >
    <div
      class="gl-border-b gl-flex gl-items-center gl-justify-between gl-border-default gl-px-4 gl-py-2"
    >
      <span class="gl-text-sm">{{ s__('Orbit|Query Editor') }}</span>
    </div>

    <div class="editor-wrapper gl-h-28">
      <source-editor
        :value="queryText"
        :editor-options="$options.editorOptions"
        :use-dynamic-height="false"
        file-name="query.json"
        file-global-id="orbit-query-editor"
        data-testid="query-editor-textarea"
        @input="$emit('update:query-text', $event)"
        @[$options.readyEvent]="onEditorReady"
      />
    </div>

    <div
      class="gl-flex gl-flex-wrap gl-items-center gl-gap-2 gl-bg-strong gl-px-4 gl-py-3"
      data-testid="query-panel-actions"
    >
      <gl-collapsible-listbox
        :items="templateItems"
        :selected="selectedTemplate"
        :toggle-text="templateToggleText"
        size="small"
        data-testid="template-select"
        @select="$emit('template-select', $event)"
      />
      <div class="gl-flex-1"></div>
      <gl-button size="small" data-testid="clear-query-btn" @click="$emit('clear')">{{
        s__('Orbit|Clear')
      }}</gl-button>
      <gl-button size="small" disabled>{{ s__('Orbit|Save') }}</gl-button>
      <gl-button
        size="small"
        variant="confirm"
        :loading="loading"
        data-testid="execute-query-btn"
        @click="$emit('execute')"
      >
        {{ s__('Orbit|Execute query') }}
      </gl-button>
    </div>
  </div>
</template>
