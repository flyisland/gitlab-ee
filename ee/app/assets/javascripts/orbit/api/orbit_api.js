// REST API bindings for the Orbit query engine and schema endpoint.
import { buildApiUrl } from '~/api/api_utils';
import axios from '~/lib/utils/axios_utils';

const ORBIT_QUERY_PATH = '/api/:version/orbit/query';
const ORBIT_SCHEMA_PATH = '/api/:version/orbit/schema';
const ORBIT_STATUS_PATH = '/api/:version/orbit/status';
const ORBIT_TOOLS_PATH = '/api/:version/orbit/tools';

/** POST a structured query to the Orbit query engine. */
export const executeOrbitQuery = (query, { responseFormat = 'raw', queryType = 'json' } = {}) =>
  axios.post(buildApiUrl(ORBIT_QUERY_PATH), {
    query,
    query_type: queryType,
    response_format: responseFormat,
  });

/** GET the Orbit schema introspection (node types, edges, domains). */
export const fetchOrbitSchema = ({ expand, responseFormat = 'raw' } = {}) => {
  const params = { response_format: responseFormat };
  if (expand) params.expand = expand;
  return axios.get(buildApiUrl(ORBIT_SCHEMA_PATH), { params });
};

/** GET Orbit cluster health status. */
export const fetchOrbitStatus = () =>
  axios.get(buildApiUrl(ORBIT_STATUS_PATH), { params: { response_format: 'raw' } });

/** GET the list of available Orbit tools. */
export const fetchOrbitTools = () => axios.get(buildApiUrl(ORBIT_TOOLS_PATH));
