import { nextTick } from 'vue';
import { GlAlert, GlButton, GlCollapsibleListbox, GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { stubComponent } from 'helpers/stub_component';
import waitForPromises from 'helpers/wait_for_promises';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { sendDuoChatCommand } from 'ee/ai/utils';
import {
  executeOrbitNamedQuery,
  executeOrbitQuery,
  fetchOrbitSchema,
  fetchOrbitTemplates,
} from 'ee/orbit/api/orbit_api';
import OrbitQueryEditorPage from 'ee/orbit/dashboard/query_editor/orbit_query_editor_page.vue';
import QueryDuoRequest from 'ee/orbit/dashboard/query_editor/query_duo_request.vue';
import QueryReferenceDrawer from 'ee/orbit/dashboard/query_editor/query_reference_drawer.vue';
import QueryResults from 'ee/orbit/dashboard/query_editor/query_results.vue';
import QuerySourceEditor from 'ee/orbit/dashboard/query_editor/query_source_editor.vue';
import { normalizeSchema } from 'ee/orbit/dashboard/schema/schema_graph';
import { mockExpandedSchema } from '../../mock_data';

jest.mock('ee/orbit/api/orbit_api');
jest.mock('ee/ai/utils');
jest.mock('~/sentry/sentry_browser_wrapper');

describe('OrbitQueryEditorPage', () => {
  let wrapper;
  const insertText = jest.fn();
  const replaceText = jest.fn();

  const { bindInternalEventDocument } = useMockInternalEventsTracking();

  const gqlTemplate = {
    name: 'merged_mrs',
    description: 'Recently merged merge requests',
    raw_query: 'MATCH (mr:MergeRequest) RETURN mr.title LIMIT 25',
  };
  const jsonTemplate = {
    name: 'search_mrs',
    description: 'Search merge requests',
    raw_query: { query_type: 'search', node: { id: 'mr', entity: 'MergeRequest' }, limit: 25 },
  };
  const userQuery = 'MATCH (p:Pipeline) RETURN p.id LIMIT 2';

  const createComponent = ({
    gqlQueriesEnabled = true,
    canAskDuoForQueries = true,
    currentUserId = 74,
  } = {}) => {
    wrapper = shallowMountExtended(OrbitQueryEditorPage, {
      provide: { gqlQueriesEnabled, canAskDuoForQueries, currentUserId },
      stubs: {
        GlAlert,
        GlSprintf,
        QuerySourceEditor: {
          ...stubComponent(QuerySourceEditor),
          methods: {
            insertText,
            replaceText(text) {
              replaceText(text);
              this.$emit('input', text);
            },
          },
        },
      },
    });
    return waitForPromises();
  };
  const queryResponse = (rows, { hasMore = false } = {}) => ({
    data: { result: { rows, pagination: { has_more: hasMore } } },
  });

  const findEditor = () => wrapper.findComponent(QuerySourceEditor);
  const findDrawer = () => wrapper.findComponent(QueryReferenceDrawer);
  const findResults = () => wrapper.findComponent(QueryResults);
  const findError = () => wrapper.findComponent(GlAlert);
  const findRunButton = () => wrapper.findComponentByTestId('run-query');
  const findExampleButtons = () => wrapper.findByTestId('query-example-buttons');
  const findExampleListbox = () => wrapper.findComponent(GlCollapsibleListbox);
  const findDuoRequest = () => wrapper.findComponent(QueryDuoRequest);
  const findKeyboardHint = () => wrapper.findByTestId('query-keyboard-hint');
  const findButton = (text) =>
    wrapper.findAllComponents(GlButton).wrappers.find((button) => button.text() === text);

  const typeQuery = async (text) => {
    findEditor().vm.$emit('input', text);
    await nextTick();
  };
  const runQuery = async () => {
    findRunButton().vm.$emit('click');
    await waitForPromises();
  };
  const useExample = async ({ description }) => {
    findButton(description).vm.$emit('click');
    await nextTick();
  };

  beforeEach(() => {
    sessionStorage.clear();
    fetchOrbitTemplates.mockResolvedValue({ data: [gqlTemplate] });
    fetchOrbitSchema.mockResolvedValue({ data: mockExpandedSchema });
    executeOrbitQuery.mockResolvedValue(queryResponse([{ id: 1 }, { id: 2 }]));
    executeOrbitNamedQuery.mockResolvedValue(queryResponse([]));
  });

  describe('with GQL on', () => {
    describe('when the page loads', () => {
      beforeEach(() => createComponent());

      it('gives the editor and the drawer the schema, and a ghost query for the user', () => {
        expect(fetchOrbitSchema).toHaveBeenCalledWith({ expand: '*' });
        expect(findEditor().props()).toEqual({
          value: '',
          isGql: true,
          schema: normalizeSchema(mockExpandedSchema),
          ghostQuery: 'MATCH (me:User {id: 74}) RETURN me.username, me.name',
        });
        expect(findDrawer().props()).toEqual({
          open: false,
          schema: normalizeSchema(mockExpandedSchema),
          isGql: true,
        });
      });

      it('shows the examples, the GitLab Duo request, and a Tab hint, and turns off Run query', () => {
        expect(findExampleButtons().text()).toContain('Recently merged merge requests');
        expect(findExampleListbox().exists()).toBe(false);
        expect(findDuoRequest().exists()).toBe(true);
        expect(findKeyboardHint().text()).toBe('Press Tab to use this query.');
        expect(findRunButton().props('disabled')).toBe(true);
        expect(findResults().exists()).toBe(false);
      });

      describe('and the editor asks to run the empty query', () => {
        beforeEach(async () => {
          findEditor().vm.$emit('run');
          await waitForPromises();
        });

        it('sends no request', () => {
          expect(executeOrbitQuery).not.toHaveBeenCalled();
        });
      });
    });

    describe('when the user runs their own query', () => {
      let trackEventSpy;

      beforeEach(async () => {
        await createComponent();
        ({ trackEventSpy } = bindInternalEventDocument(wrapper.element));
        await typeQuery(userQuery);
        await runQuery();
      });

      it('sends the GQL text, shows the rows, and drops the ghost query', () => {
        expect(findEditor().props('ghostQuery')).toBe(null);
        expect(executeOrbitQuery).toHaveBeenCalledWith(userQuery);
        expect(findResults().props()).toEqual({
          rows: [{ id: 1 }, { id: 2 }],
          durationMs: expect.any(Number),
          hasMoreRows: false,
          canAskDuo: true,
        });
      });

      it('tracks the run', () => {
        expect(trackEventSpy).toHaveBeenCalledWith('click_orbit_execute_query', {}, undefined);
      });

      it('replaces the example buttons with the examples listbox', () => {
        expect(findExampleButtons().exists()).toBe(false);
        expect(findExampleListbox().props()).toMatchObject({
          items: [{ value: 'merged_mrs', text: 'Recently merged merge requests' }],
          selected: null,
          toggleText: 'Examples',
        });
      });

      describe('and selects Check the schema', () => {
        beforeEach(async () => {
          findResults().vm.$emit('check-schema');
          await nextTick();
        });

        it('opens the query reference', () => {
          expect(findDrawer().props('open')).toBe(true);
        });
      });
    });

    describe('when the response has no pagination, like a schema call', () => {
      beforeEach(async () => {
        executeOrbitQuery.mockResolvedValue({ data: { result: { rows: [{ id: 1 }] } } });
        await createComponent();
        await typeQuery("CALL db.schema('User')");
        await runQuery();
      });

      it('shows the rows with no notice, no error, and no report', () => {
        expect(findResults().props()).toMatchObject({ rows: [{ id: 1 }], hasMoreRows: false });
        expect(findError().exists()).toBe(false);
        expect(Sentry.captureException).not.toHaveBeenCalled();
      });
    });

    describe('when the query of the user returns no rows', () => {
      beforeEach(async () => {
        executeOrbitQuery.mockResolvedValue(queryResponse([]));
        await createComponent();
        await typeQuery(userQuery);
        await runQuery();
      });

      describe('and the user asks GitLab Duo why', () => {
        beforeEach(async () => {
          findResults().vm.$emit('ask-duo-why');
          await waitForPromises();
        });

        it('sends the query to GitLab Duo Chat', () => {
          expect(findResults().props('rows')).toEqual([]);
          expect(sendDuoChatCommand).toHaveBeenCalledWith(
            expect.objectContaining({
              question: `Why does this Orbit GQL query return no rows?\n\n${userQuery}`,
              resourceId: 'orbit-query-editor',
            }),
          );
        });
      });
    });

    describe('when the user runs the query again before it ends', () => {
      let resolveQuery;

      beforeEach(async () => {
        executeOrbitQuery.mockReturnValue(
          new Promise((resolve) => {
            resolveQuery = resolve;
          }),
        );
        await createComponent();
        await typeQuery(userQuery);
        findRunButton().vm.$emit('click');
        findRunButton().vm.$emit('click');
        await typeQuery('MATCH (p:Pipeline) RETURN p.id LIMIT 500');
        resolveQuery(queryResponse([{ id: 1 }], { hasMore: true }));
        await waitForPromises();
      });

      it('sends one request and takes the notice from the response, not the edited text', () => {
        expect(executeOrbitQuery).toHaveBeenCalledTimes(1);
        expect(findResults().props('hasMoreRows')).toBe(true);
      });
    });

    describe('when the user comes back to the tab', () => {
      beforeEach(async () => {
        await createComponent();
        await typeQuery(userQuery);
        wrapper.destroy();
        await createComponent();
      });

      it('keeps the query', () => {
        expect(findEditor().props('value')).toBe(userQuery);
      });
    });

    describe('when another user opens the tab in the same browser tab', () => {
      beforeEach(async () => {
        await createComponent();
        await typeQuery(userQuery);
        wrapper.destroy();
        await createComponent({ currentUserId: 75 });
      });

      it('does not show the query of the first user', () => {
        expect(findEditor().props('value')).toBe('');
      });
    });

    describe('when the user runs an example', () => {
      beforeEach(async () => {
        await createComponent();
        await useExample(gqlTemplate);
        await runQuery();
      });

      it('puts the example in the editor and runs it by name', () => {
        expect(replaceText).toHaveBeenCalledWith(gqlTemplate.raw_query);
        expect(findEditor().props('value')).toBe(gqlTemplate.raw_query);
        expect(executeOrbitNamedQuery).toHaveBeenCalledWith('merged_mrs');
        expect(executeOrbitQuery).not.toHaveBeenCalled();
        expect(findExampleListbox().props()).toMatchObject({
          selected: 'merged_mrs',
          toggleText: 'Recently merged merge requests',
        });
      });

      describe('and then edits it', () => {
        beforeEach(async () => {
          await typeQuery(`${gqlTemplate.raw_query} SKIP 5`);
          await runQuery();
        });

        it('runs the edited text', () => {
          expect(executeOrbitQuery).toHaveBeenCalledWith(`${gqlTemplate.raw_query} SKIP 5`);
          expect(findExampleListbox().props('selected')).toBe(null);
        });
      });
    });

    describe('when the API rejects the query', () => {
      beforeEach(async () => {
        executeOrbitQuery.mockRejectedValue({
          response: { status: 400, data: { message: 'Unknown relationship type: CLOSED_BY' } },
        });
        await createComponent();
        await typeQuery(userQuery);
        await runQuery();
      });

      it('shows the query error with a GitLab Duo fix and no results', () => {
        expect(findError().props()).toMatchObject({
          title: 'The query has an error',
          primaryButtonText: 'Ask Duo to fix this query',
        });
        expect(findError().text()).toContain('Unknown relationship type: CLOSED_BY');
        expect(findResults().exists()).toBe(false);
        expect(Sentry.captureException).not.toHaveBeenCalled();
      });

      describe('and asks GitLab Duo to fix it', () => {
        beforeEach(async () => {
          findError().vm.$emit('primary-action');
          await waitForPromises();
        });

        it('sends the error and the query to GitLab Duo Chat', () => {
          expect(sendDuoChatCommand).toHaveBeenCalledWith(
            expect.objectContaining({
              question: `Fix this Orbit GQL query. It fails with: Unknown relationship type: CLOSED_BY\n\n${userQuery}`,
            }),
          );
        });
      });

      describe('and dismisses the error', () => {
        beforeEach(async () => {
          findError().vm.$emit('dismiss');
          await nextTick();
        });

        it('hides it', () => {
          expect(findError().exists()).toBe(false);
        });
      });
    });

    describe('when the user has no Orbit default group', () => {
      beforeEach(async () => {
        executeOrbitQuery.mockRejectedValue({
          response: {
            status: 422,
            data: {
              code: 'billing_namespace_required',
              message: 'Select a billing namespace for Orbit to attribute usage.',
              deep_link: 'http://127.0.0.1:3000/-/profile/preferences',
            },
          },
        });
        await createComponent();
        await typeQuery(userQuery);
        await runQuery();
      });

      it('links to the preferences with no query error title, GitLab Duo fix, or report', () => {
        expect(findError().props()).toMatchObject({ title: '', primaryButtonText: '' });
        expect(findError().text()).toContain(
          'Select a billing namespace for Orbit to attribute usage.',
        );
        expect(findError().findComponent(GlLink).attributes('href')).toBe(
          'http://127.0.0.1:3000/-/profile/preferences',
        );
        expect(Sentry.captureException).not.toHaveBeenCalled();
      });
    });

    describe('when the API refuses the request', () => {
      beforeEach(async () => {
        executeOrbitQuery.mockRejectedValue({
          response: {
            status: 429,
            data: { message: 'This endpoint has been requested too many times. Try again later.' },
          },
        });
        await createComponent();
        await typeQuery(userQuery);
        await runQuery();
      });

      it('shows the API message with no query error title, GitLab Duo fix, or report', () => {
        expect(findError().props()).toMatchObject({ title: '', primaryButtonText: '' });
        expect(findError().text()).toContain(
          'This endpoint has been requested too many times. Try again later.',
        );
        expect(Sentry.captureException).not.toHaveBeenCalled();
      });
    });

    describe('when the user has no Orbit access', () => {
      beforeEach(async () => {
        executeOrbitQuery.mockRejectedValue({
          response: { status: 403, data: { message: '403 Forbidden' } },
        });
        await createComponent();
        await typeQuery(userQuery);
        await runQuery();
      });

      it('shows the no eligible groups state with no editor and no report', () => {
        expect(wrapper.findByTestId('query-editor-no-access').text()).toBe(
          'No eligible groups are available for GitLab Orbit.',
        );
        expect(findEditor().exists()).toBe(false);
        expect(Sentry.captureException).not.toHaveBeenCalled();
      });
    });

    describe('when the API fails', () => {
      const error = { response: { status: 503, data: { message: 'upstream connect error' } } };

      beforeEach(async () => {
        executeOrbitQuery.mockRejectedValue(error);
        await createComponent();
        await typeQuery(userQuery);
        await runQuery();
      });

      it('shows a server error with no GitLab Duo fix and reports it', () => {
        expect(findError().props()).toMatchObject({ title: '', primaryButtonText: '' });
        expect(findError().text()).toContain('Failed to execute query. Please try again.');
        expect(Sentry.captureException).toHaveBeenCalledWith(error);
      });
    });

    describe('when the user asks GitLab Duo to write a query', () => {
      beforeEach(async () => {
        await createComponent();
        findDuoRequest().vm.$emit('submit', 'merge requests merged this week');
      });

      it('sends the request to GitLab Duo Chat', () => {
        expect(sendDuoChatCommand).toHaveBeenCalledWith({
          question:
            'Write an Orbit GQL query that answers this question: merge requests merged this week',
          resourceId: 'orbit-query-editor',
          agenticPrompt:
            'Write an Orbit GQL query that answers this question: merge requests merged this week',
          agent: { name: 'GitLab Duo' },
        });
      });
    });

    describe.each`
      context                       | query                        | inserted
      ${'a node binds its entity'}  | ${userQuery}                 | ${'p.id'}
      ${'no node binds its entity'} | ${'MATCH (u:User) RETURN u'} | ${'id'}
    `('when the user selects a property and $context', ({ query, inserted }) => {
      beforeEach(async () => {
        await createComponent();
        await typeQuery(query);
        findDrawer().vm.$emit('insert-property', { entity: 'Pipeline', property: 'id' });
      });

      it(`inserts ${inserted}`, () => {
        expect(insertText).toHaveBeenCalledWith(inserted);
      });
    });

    describe('when the user opens the query reference and selects a name', () => {
      beforeEach(async () => {
        await createComponent();
        findButton('Query reference').vm.$emit('click');
        await nextTick();
        findDrawer().vm.$emit('insert', 'MergeRequest');
      });

      it('opens the drawer and inserts the name in the editor', () => {
        expect(findDrawer().props('open')).toBe(true);
        expect(insertText).toHaveBeenCalledWith('MergeRequest');
      });
    });

    describe('when GitLab Duo is not available', () => {
      beforeEach(async () => {
        await createComponent({ canAskDuoForQueries: false });
        await typeQuery(userQuery);
        await runQuery();
      });

      it('hides the GitLab Duo request and its actions', () => {
        expect(findDuoRequest().exists()).toBe(false);
        expect(findResults().props('canAskDuo')).toBe(false);
      });
    });
  });

  describe('with GQL off', () => {
    beforeEach(async () => {
      fetchOrbitTemplates.mockResolvedValue({ data: [jsonTemplate] });
      await createComponent({ gqlQueriesEnabled: false, canAskDuoForQueries: false });
    });

    it('edits JSON with no ghost query and no GitLab Duo request', () => {
      expect(wrapper.find('h2').text()).toBe('Query');
      expect(findEditor().props()).toMatchObject({ isGql: false, ghostQuery: null });
      expect(findDuoRequest().exists()).toBe(false);
    });

    describe('when the user runs a JSON query', () => {
      beforeEach(async () => {
        await typeQuery('{ "query_type": "search", "limit": 5 }');
        await runQuery();
      });

      it('sends the parsed query', () => {
        expect(executeOrbitQuery).toHaveBeenCalledWith({ query_type: 'search', limit: 5 });
      });
    });

    describe('when the user runs JSON that does not parse', () => {
      let trackEventSpy;

      beforeEach(async () => {
        ({ trackEventSpy } = bindInternalEventDocument(wrapper.element));
        await typeQuery('{ invalid');
        await runQuery();
      });

      it('shows the syntax error, and sends no request and no run event', () => {
        expect(findError().text()).toContain('Invalid JSON query. Please check the syntax.');
        expect(findError().props('primaryButtonText')).toBe('');
        expect(executeOrbitQuery).not.toHaveBeenCalled();
        expect(trackEventSpy).not.toHaveBeenCalled();
        expect(findExampleButtons().exists()).toBe(true);
      });
    });

    describe('when the user runs a JSON example', () => {
      beforeEach(async () => {
        await useExample(jsonTemplate);
        await runQuery();
      });

      it('shows the example as indented JSON and runs it by name', () => {
        expect(findEditor().props('value')).toBe(JSON.stringify(jsonTemplate.raw_query, null, 2));
        expect(executeOrbitNamedQuery).toHaveBeenCalledWith('search_mrs');
      });
    });
  });

  describe('when the examples and the schema fail to load', () => {
    const templatesError = new Error('templates down');
    const schemaError = new Error('schema down');

    beforeEach(async () => {
      fetchOrbitTemplates.mockRejectedValue(templatesError);
      fetchOrbitSchema.mockRejectedValue(schemaError);
      await createComponent();
    });

    it('reports both, says the examples are not available, and keeps the editor', () => {
      expect(Sentry.captureException).toHaveBeenCalledWith(templatesError);
      expect(Sentry.captureException).toHaveBeenCalledWith(schemaError);
      expect(findExampleButtons().exists()).toBe(false);
      expect(wrapper.text()).toContain('The examples are not available. Try again later.');
      expect(findEditor().props('schema')).toEqual({ nodes: [], edges: [] });
    });
  });

  describe('when the user has no Orbit license', () => {
    beforeEach(async () => {
      fetchOrbitTemplates.mockRejectedValue({ response: { status: 403, data: {} } });
      fetchOrbitSchema.mockRejectedValue({ response: { status: 403, data: {} } });
      await createComponent();
    });

    it('shows the no eligible groups state and reports nothing', () => {
      expect(wrapper.findByTestId('query-editor-no-access').exists()).toBe(true);
      expect(findEditor().exists()).toBe(false);
      expect(Sentry.captureException).not.toHaveBeenCalled();
    });
  });
});
