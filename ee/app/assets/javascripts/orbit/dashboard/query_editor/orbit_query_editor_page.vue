<script>
import { defineComponent } from 'vue';
import { GlAlert, GlButton, GlCollapsibleListbox, GlLink, GlSprintf } from '@gitlab/ui';
import { getModifierKey } from '~/constants';
import { __, s__, sprintf } from '~/locale';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { InternalEvents } from '~/tracking';
import { DUO_CHAT_AGENT_GITLAB_DUO } from 'ee/ai/constants';
import { sendDuoChatCommand } from 'ee/ai/utils';
import {
  executeOrbitNamedQuery,
  executeOrbitQuery,
  fetchOrbitSchema,
  fetchOrbitTemplates,
} from 'ee/orbit/api/orbit_api';
import { normalizeSchema } from '../schema/schema_graph';
import QueryDuoRequest from './query_duo_request.vue';
import QueryReferenceDrawer from './query_reference_drawer.vue';
import QueryResults from './query_results.vue';
import QuerySourceEditor from './query_source_editor.vue';
import { QUERY_ERROR_KIND, QUERY_STORAGE_KEY_PREFIX } from './constants';
import { boundVariable } from './gql_language';
import { queryErrorFor, queryResultRows, templateQueryText } from './utils';

export default defineComponent({
  name: 'OrbitQueryEditorPage',
  compatConfig: { MODE: 3 },
  components: {
    GlAlert,
    GlButton,
    GlCollapsibleListbox,
    GlLink,
    GlSprintf,
    QueryDuoRequest,
    QueryReferenceDrawer,
    QueryResults,
    QuerySourceEditor,
  },
  mixins: [InternalEvents.mixin()],
  inject: ['gqlQueriesEnabled', 'canAskDuoForQueries', 'currentUserId'],
  data() {
    return {
      templates: [],
      schema: normalizeSchema({}),
      queryText: '',
      isRunning: false,
      hasRun: false,
      result: null,
      queryError: null,
      isReferenceOpen: false,
      hasTemplatesError: false,
      hasNoAccess: false,
    };
  },
  computed: {
    queryStorageKey() {
      return `${QUERY_STORAGE_KEY_PREFIX}:${this.currentUserId}`;
    },
    isQueryEmpty() {
      return !this.queryText.trim();
    },
    selectedTemplate() {
      return this.templates.find((template) => templateQueryText(template) === this.queryText);
    },
    selectedTemplateName() {
      return this.selectedTemplate?.name ?? null;
    },
    templateItems() {
      return this.templates.map(({ name, description }) => ({ value: name, text: description }));
    },
    templateToggleText() {
      return this.selectedTemplate?.description ?? s__('Orbit|Examples');
    },
    hasTemplates() {
      return this.templates.length > 0;
    },
    showsExampleButtons() {
      return this.hasTemplates && !this.hasRun;
    },
    showsExampleListbox() {
      return this.hasTemplates && this.hasRun;
    },
    ghostQuery() {
      if (!this.gqlQueriesEnabled || !this.isQueryEmpty) return null;

      return `MATCH (me:User {id: ${this.currentUserId}}) RETURN me.username, me.name`;
    },
    heading() {
      return this.gqlQueriesEnabled ? s__('Orbit|Query your graph with GQL') : s__('Orbit|Query');
    },
    queryErrorTitle() {
      return this.isInvalidQuery ? s__('Orbit|The query has an error') : '';
    },
    fixQueryButtonText() {
      return this.canAskDuoToFix ? s__('Orbit|Ask Duo to fix this query') : '';
    },
    isInvalidQuery() {
      return this.queryError.kind === QUERY_ERROR_KIND.INVALID_QUERY;
    },
    canAskDuoToFix() {
      return this.canAskDuoForQueries && this.isInvalidQuery;
    },
  },
  watch: {
    queryText(text) {
      sessionStorage.setItem(this.queryStorageKey, text);
    },
  },
  created() {
    this.queryText = sessionStorage.getItem(this.queryStorageKey) ?? '';
  },
  mounted() {
    this.loadTemplates();
    this.loadSchema();
  },
  methods: {
    async loadTemplates() {
      try {
        const { data } = await fetchOrbitTemplates();
        this.templates = data;
      } catch (error) {
        this.hasTemplatesError = true;
        this.handleLoadError(error);
      }
    },
    async loadSchema() {
      try {
        const { data } = await fetchOrbitSchema({ expand: '*' });
        this.schema = normalizeSchema(data);
      } catch (error) {
        this.handleLoadError(error);
      }
    },
    handleLoadError(error) {
      if (queryErrorFor(error).kind === QUERY_ERROR_KIND.NO_ACCESS) {
        this.hasNoAccess = true;
      } else {
        Sentry.captureException(error);
      }
    },
    useTemplate(name) {
      const template = this.templates.find((item) => item.name === name);
      this.$refs.editor.replaceText(templateQueryText(template));
    },
    requestQuery(query) {
      if (this.selectedTemplate) return executeOrbitNamedQuery(this.selectedTemplate.name);

      return executeOrbitQuery(query);
    },
    async runQuery() {
      if (this.isRunning || this.isQueryEmpty) return;

      let query;
      try {
        query = this.gqlQueriesEnabled ? this.queryText : JSON.parse(this.queryText);
      } catch (error) {
        this.showQueryError(error);
        return;
      }

      this.trackEvent('click_orbit_execute_query');
      this.queryError = null;
      this.isRunning = true;
      const startedAt = performance.now();

      try {
        const { data } = await this.requestQuery(query);
        this.result = {
          rows: queryResultRows(data.result),
          durationMs: Math.round(performance.now() - startedAt),
          hasMoreRows: Boolean(data.result.pagination?.has_more),
        };
      } catch (error) {
        this.showQueryError(error);
      } finally {
        this.isRunning = false;
        this.hasRun = true;
      }
    },
    showQueryError(error) {
      this.result = null;
      this.queryError = queryErrorFor(error);
      if (this.queryError.kind === QUERY_ERROR_KIND.NO_ACCESS) this.hasNoAccess = true;
      if (this.queryError.kind === QUERY_ERROR_KIND.SERVER) Sentry.captureException(error);
    },
    insertAtCursor(text) {
      this.$refs.editor.insertText(text);
    },
    insertProperty({ entity, property }) {
      const variable = boundVariable(this.queryText, entity);
      this.insertAtCursor(variable ? `${variable}.${property}` : property);
    },
    askDuo(question) {
      sendDuoChatCommand({
        question,
        resourceId: 'orbit-query-editor',
        agenticPrompt: question,
        agent: { name: DUO_CHAT_AGENT_GITLAB_DUO },
      });
    },
    askDuoToWriteQuery(question) {
      this.askDuo(
        sprintf(s__('Orbit|Write an Orbit GQL query that answers this question: %{question}'), {
          question,
        }),
      );
    },
    askDuoToFixQuery() {
      const intro = sprintf(s__('Orbit|Fix this Orbit GQL query. It fails with: %{error}'), {
        error: this.queryError.message,
      });
      this.askDuo(`${intro}\n\n${this.queryText}`);
    },
    askDuoWhyNoRows() {
      const intro = s__('Orbit|Why does this Orbit GQL query return no rows?');
      this.askDuo(`${intro}\n\n${this.queryText}`);
    },
  },
  runShortcut: `${getModifierKey()}${__('Enter')}`,
});
</script>

<template>
  <p
    v-if="hasNoAccess"
    class="gl-border gl-mb-0 gl-mt-5 gl-rounded-lg gl-border-subtle gl-bg-subtle gl-p-5 gl-font-bold"
    data-testid="query-editor-no-access"
  >
    {{ s__('Orbit|No eligible groups are available for GitLab Orbit.') }}
  </p>
  <div v-else class="gl-flex gl-flex-col gl-gap-4 gl-pt-5" data-testid="orbit-query-editor-page">
    <query-reference-drawer
      :open="isReferenceOpen"
      :schema="schema"
      :is-gql="gqlQueriesEnabled"
      @insert="insertAtCursor"
      @insert-property="insertProperty"
      @close="isReferenceOpen = false"
    />

    <div class="gl-flex gl-flex-wrap gl-items-end gl-justify-between gl-gap-3">
      <div>
        <h2 class="gl-heading-4 gl-mb-1">{{ heading }}</h2>
        <p class="gl-mb-0 gl-text-subtle">
          {{
            s__(
              'Orbit|Get exact, repeatable results, like exports. Results include only data you have permission to see.',
            )
          }}
        </p>
      </div>
      <div class="gl-flex gl-flex-wrap gl-items-center gl-gap-3">
        <gl-collapsible-listbox
          v-if="showsExampleListbox"
          :items="templateItems"
          :selected="selectedTemplateName"
          :toggle-text="templateToggleText"
          data-testid="query-examples-listbox"
          @select="useTemplate"
        />
        <gl-button
          category="tertiary"
          icon="book"
          :selected="isReferenceOpen"
          @click="isReferenceOpen = !isReferenceOpen"
        >
          {{ s__('Orbit|Query reference') }}
        </gl-button>
      </div>
    </div>

    <gl-alert
      v-if="queryError"
      variant="danger"
      :title="queryErrorTitle"
      :primary-button-text="fixQueryButtonText"
      data-testid="query-error"
      @primary-action="askDuoToFixQuery"
      @dismiss="queryError = null"
    >
      {{ queryError.message }}
      <gl-link v-if="queryError.preferencesUrl" :href="queryError.preferencesUrl">
        {{ s__('Orbit|Go to preferences') }}
      </gl-link>
    </gl-alert>

    <div class="gl-border gl-overflow-hidden gl-rounded-base gl-border-default">
      <query-source-editor
        ref="editor"
        :value="queryText"
        :is-gql="gqlQueriesEnabled"
        :schema="schema"
        :ghost-query="ghostQuery"
        @input="queryText = $event"
        @run="runQuery"
      />
      <query-duo-request v-if="canAskDuoForQueries" @submit="askDuoToWriteQuery" />
    </div>

    <p v-if="hasTemplatesError" class="gl-mb-0 gl-text-sm gl-text-subtle">
      {{ s__('Orbit|The examples are not available. Try again later.') }}
    </p>
    <div
      v-else-if="showsExampleButtons"
      class="gl-flex gl-flex-wrap gl-items-center gl-gap-3"
      data-testid="query-example-buttons"
    >
      <span class="gl-text-sm gl-text-subtle">{{ s__('Orbit|Try an example:') }}</span>
      <gl-button
        v-for="template in templates"
        :key="template.name"
        size="small"
        @click="useTemplate(template.name)"
      >
        {{ template.description }}
      </gl-button>
    </div>

    <div class="gl-flex gl-flex-wrap gl-items-center gl-gap-3">
      <gl-button
        variant="confirm"
        icon="play"
        :loading="isRunning"
        :disabled="isQueryEmpty"
        data-testid="run-query"
        @click="runQuery"
      >
        {{ s__('Orbit|Run query') }}
      </gl-button>
      <span class="gl-text-sm gl-text-subtle" data-testid="query-keyboard-hint">
        <gl-sprintf v-if="ghostQuery" :message="s__('Orbit|Press %{keys} to use this query.')">
          <template #keys>
            <kbd>{{ __('Tab') }}</kbd>
          </template>
        </gl-sprintf>
        <gl-sprintf v-else :message="s__('Orbit|Press %{keys} to run.')">
          <template #keys>
            <kbd>{{ $options.runShortcut }}</kbd>
          </template>
        </gl-sprintf>
      </span>
    </div>

    <query-results
      v-if="result"
      :rows="result.rows"
      :duration-ms="result.durationMs"
      :has-more-rows="result.hasMoreRows"
      :can-ask-duo="canAskDuoForQueries"
      @ask-duo-why="askDuoWhyNoRows"
      @check-schema="isReferenceOpen = true"
    />
  </div>
</template>
