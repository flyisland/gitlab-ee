import { buildApiUrl } from '~/api/api_utils';
import axios from '~/lib/utils/axios_utils';

export const appealPath = '/api/:version/content_blocked_states/:id/complaint';
export const treeContentBlockedStatePath =
  '/api/:version/projects/:id/repository/tree/content_blocked_state';
export const getTreeContentBlockedState = (id, { ref, path }) => {
  const url = buildApiUrl(treeContentBlockedStatePath).replace(':id', encodeURIComponent(id));
  return axios.get(url, { params: { ref, path } });
};
export const createAppeal = (id, { description }) => {
  const url = buildApiUrl(appealPath).replace(':id', encodeURIComponent(id));
  return axios.post(url, { description });
};
