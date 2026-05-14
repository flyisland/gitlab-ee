import MockAdapter from 'axios-mock-adapter';
import {
  executeOrbitQuery,
  fetchOrbitSchema,
  fetchOrbitStatus,
  fetchOrbitTools,
} from 'ee/orbit/api/orbit_api';
import axios from '~/lib/utils/axios_utils';
import { HTTP_STATUS_OK, HTTP_STATUS_INTERNAL_SERVER_ERROR } from '~/lib/utils/http_status';

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
      const queryPayload = { match: [{ type: 'User' }] };
      const responseData = { nodes: [], edges: [] };

      mock.onPost(queryUrl).reply(HTTP_STATUS_OK, responseData);

      const { data } = await executeOrbitQuery(queryPayload);

      expect(data).toEqual(responseData);
      expect(JSON.parse(mock.history.post[0].data)).toEqual({
        query: queryPayload,
        query_type: 'json',
        response_format: 'raw',
      });
    });

    it('forwards custom responseFormat and queryType', async () => {
      const query = 'MATCH (u:User) RETURN u';

      mock.onPost(queryUrl).reply(HTTP_STATUS_OK, {});

      await executeOrbitQuery(query, { responseFormat: 'graph', queryType: 'cypher' });

      expect(JSON.parse(mock.history.post[0].data)).toEqual({
        query,
        query_type: 'cypher',
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
});
