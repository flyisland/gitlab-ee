import MockAdapter from 'axios-mock-adapter';
import {
  executeOrbitQuery,
  fetchGraphStatus,
  fetchOrbitSchema,
  fetchOrbitStatus,
  fetchOrbitTools,
} from 'ee/orbit/api/orbit_api';
import axios from '~/lib/utils/axios_utils';
import { HTTP_STATUS_OK, HTTP_STATUS_INTERNAL_SERVER_ERROR } from '~/lib/utils/http_status';

const GRAPH_STATUS_TIMEOUT_MS = 15000;

describe('orbit_api', () => {
  let mock;

  beforeEach(() => {
    mock = new MockAdapter(axios);
    gon.api_version = 'v4';
  });

  afterEach(() => {
    mock.restore();
  });

  describe('executeOrbitQuery', () => {
    const queryUrl = '/api/v4/orbit/query';

    it('sends a POST with the query and default options', async () => {
      const queryPayload = { query_type: 'traversal', node: { id: 'u', entity: 'User' } };
      const responseData = { nodes: [], edges: [] };

      mock.onPost(queryUrl).reply(HTTP_STATUS_OK, responseData);

      const { data } = await executeOrbitQuery(queryPayload);

      expect(data).toEqual(responseData);
      expect(JSON.parse(mock.history.post[0].data)).toEqual({
        query: queryPayload,
        response_format: 'raw',
      });
    });

    it('forwards custom responseFormat', async () => {
      const query = { query_type: 'traversal', node: { id: 'u', entity: 'User' } };

      mock.onPost(queryUrl).reply(HTTP_STATUS_OK, {});

      await executeOrbitQuery(query, { responseFormat: 'graph' });

      expect(JSON.parse(mock.history.post[0].data)).toEqual({
        query,
        response_format: 'graph',
      });
    });

    it('rejects on server error', async () => {
      mock.onPost(queryUrl).reply(HTTP_STATUS_INTERNAL_SERVER_ERROR);

      await expect(executeOrbitQuery({})).rejects.toThrow();
    });
  });

  describe('fetchOrbitSchema', () => {
    const schemaUrl = '/api/v4/orbit/schema';

    it('sends a GET with default params', async () => {
      const schemaData = { nodes: [], edges: [] };

      mock.onGet(schemaUrl).reply(HTTP_STATUS_OK, schemaData);

      const { data } = await fetchOrbitSchema();

      expect(data).toEqual(schemaData);
      expect(mock.history.get[0].params).toEqual({ response_format: 'raw' });
    });

    it('includes expand param when provided', async () => {
      mock.onGet(schemaUrl).reply(HTTP_STATUS_OK, {});

      await fetchOrbitSchema({ expand: 'properties' });

      expect(mock.history.get[0].params).toEqual({
        response_format: 'raw',
        expand: 'properties',
      });
    });

    it('forwards custom responseFormat', async () => {
      mock.onGet(schemaUrl).reply(HTTP_STATUS_OK, {});

      await fetchOrbitSchema({ responseFormat: 'graph' });

      expect(mock.history.get[0].params).toEqual({ response_format: 'graph' });
    });

    it('rejects on server error', async () => {
      mock.onGet(schemaUrl).reply(HTTP_STATUS_INTERNAL_SERVER_ERROR);

      await expect(fetchOrbitSchema()).rejects.toThrow();
    });
  });

  describe('fetchOrbitStatus', () => {
    const statusUrl = '/api/v4/orbit/status';

    it('sends a GET with raw response_format', async () => {
      const statusData = { status: 'ok' };

      mock.onGet(statusUrl).reply(HTTP_STATUS_OK, statusData);

      const { data } = await fetchOrbitStatus();

      expect(data).toEqual(statusData);
      expect(mock.history.get[0].params).toEqual({ response_format: 'raw' });
    });

    it('rejects on server error', async () => {
      mock.onGet(statusUrl).reply(HTTP_STATUS_INTERNAL_SERVER_ERROR);

      await expect(fetchOrbitStatus()).rejects.toThrow();
    });
  });

  describe('fetchOrbitTools', () => {
    const toolsUrl = '/api/v4/orbit/tools';

    it('sends a GET request', async () => {
      const toolsData = [{ name: 'tool1' }];

      mock.onGet(toolsUrl).reply(HTTP_STATUS_OK, toolsData);

      const { data } = await fetchOrbitTools();

      expect(data).toEqual(toolsData);
    });

    it('rejects on server error', async () => {
      mock.onGet(toolsUrl).reply(HTTP_STATUS_INTERNAL_SERVER_ERROR);

      await expect(fetchOrbitTools()).rejects.toThrow();
    });
  });

  describe('fetchGraphStatus', () => {
    const graphStatusUrl = '/api/v4/orbit/graph_status';

    it('sends a GET request with the selected namespace full path', async () => {
      const graphStatusData = {
        projects: { indexed: 2, total_known: 3 },
        domains: [],
        indexing: { state: 'indexed' },
      };

      mock.onGet(graphStatusUrl).reply(HTTP_STATUS_OK, graphStatusData);

      const { data } = await fetchGraphStatus('gitlab-org/gitlab');

      expect(data).toEqual(graphStatusData);
      expect(mock.history.get[0].params).toEqual({
        full_path: 'gitlab-org/gitlab',
        response_format: 'raw',
      });
      expect(mock.history.get[0].timeout).toBe(GRAPH_STATUS_TIMEOUT_MS);
    });

    it('forwards the abort signal to axios', async () => {
      const controller = new AbortController();
      mock.onGet(graphStatusUrl).reply(HTTP_STATUS_OK, {});

      await fetchGraphStatus('gitlab-org/gitlab', { signal: controller.signal });

      expect(mock.history.get[0].signal).toBe(controller.signal);
    });

    it('rejects on server error', async () => {
      mock.onGet(graphStatusUrl).reply(HTTP_STATUS_INTERNAL_SERVER_ERROR);

      await expect(fetchGraphStatus('gitlab-org')).rejects.toThrow();
    });
  });
});
