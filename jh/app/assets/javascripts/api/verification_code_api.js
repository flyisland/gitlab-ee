import axios from '~/lib/utils/axios_utils';
import { buildApiUrl } from '~/api/api_utils';
import { i18n } from '../passwords/constants';

export class VerificationError extends Error {}

export const verificationCodePath = '/-/sms/verification_code';

export const getVerificationCode = (params) => {
  const url = buildApiUrl(verificationCodePath);
  return axios
    .post(url, params)
    .catch(() => {
      throw new Error(i18n.SEND_CODE_ERROR);
    })
    .then(({ data }) => {
      if (data.status !== 'OK') throw new Error(i18n[data.status] || i18n.SEND_CODE_ERROR);
      return data;
    });
};

export const getResetPasswordTokenPath = '/users/reset_password_token';
export const getResetPasswordToken = (params) => {
  const url = buildApiUrl(getResetPasswordTokenPath);
  return axios.post(url, params);
};
