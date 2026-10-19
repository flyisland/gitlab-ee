import { buildApiUrl } from '~/api/api_utils';
import axios from '~/lib/utils/axios_utils';

const MONOREPO_MR_LIST_PATH =
  '/:project_path/-/merge_requests/:merge_request_iid.json?serializer=monorepo';
const MONOREPO_MR_MERGE_PATH = '/:project_path/-/merge_requests/:merge_request_iid/bulk_merge';

export const getMonorepoMergeRequests = (projectPath, mergeRequestIid) => {
  const url = buildApiUrl(MONOREPO_MR_LIST_PATH)
    .replace(':project_path', projectPath)
    .replace(':merge_request_iid', mergeRequestIid);

  return axios.get(url);
};

export const mergeMonorepoMergeRequests = (projectPath, mergeRequestIid) => {
  const url = buildApiUrl(MONOREPO_MR_MERGE_PATH)
    .replace(':project_path', projectPath)
    .replace(':merge_request_iid', mergeRequestIid);

  return axios.post(url);
};
