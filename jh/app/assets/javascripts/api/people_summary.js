import { buildApiUrl } from '~/api/api_utils';
import axios from '~/lib/utils/axios_utils';

const PEOPLE_SUMMARY_PATH = '/-/performance_measurement/people/summary';
const ORG_TREE_PATH = '/-/performance_measurement/org_tree';
const BRANCHES_PATH = '/-/performance_measurement/branches';
const MEMBERS_PATH = '/-/performance_measurement/users';

export const getPeopleSummary = (params) => axios.get(buildApiUrl(PEOPLE_SUMMARY_PATH), { params });
export const getOrgTree = (params) => axios.get(buildApiUrl(ORG_TREE_PATH), { params });
export const getBranches = (params) => axios.get(buildApiUrl(BRANCHES_PATH), { params });
export const getMembers = (params) => axios.get(buildApiUrl(MEMBERS_PATH), { params });
