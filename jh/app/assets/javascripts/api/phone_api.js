import { isBoolean } from 'lodash-es';
import axios from '~/lib/utils/axios_utils';
import Api from 'jh/api';
import { s__ } from '~/locale';

export const checkPhoneAvailability = (phone, cancelTokenCb) => {
  return axios
    .get(
      Api.buildUrl('/-/users/phone/exists?phone=:phone').replace(
        ':phone',
        encodeURIComponent(phone),
      ),
      {
        cancelToken: new axios.CancelToken(cancelTokenCb),
      },
    )
    .then(({ data }) => {
      if (!isBoolean(data.exists))
        throw new Error(s__('JH|RealName|An error occurred while validating phone'));
      return data.exists;
    });
};
