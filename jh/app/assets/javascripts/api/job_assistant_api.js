import axios from '~/lib/utils/axios_utils';
import Api from 'jh/api';

export const getJobTemplateList = (id) => {
  return axios.get(
    Api.buildUrl('/api/:version/projects/:id/repository/job_templates').replace(
      ':id',
      encodeURIComponent(id),
    ),
  );
};
