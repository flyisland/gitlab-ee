import axios from '~/lib/utils/axios_utils';
import { buildApiUrl } from '~/api/api_utils';

export const provincePath = '/-/provinces';

export const getProvinces = () => {
  return axios.get(buildApiUrl(provincePath));
};
