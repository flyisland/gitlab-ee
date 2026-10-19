import MockAdapter from 'axios-mock-adapter';
import { buildApiUrl } from '~/api/api_utils';
import axios from '~/lib/utils/axios_utils';
import { HTTP_STATUS_OK, HTTP_STATUS_INTERNAL_SERVER_ERROR } from '~/lib/utils/http_status';
import {
  getVerificationCode,
  verificationCodePath,
  VerificationError,
} from 'jh/api/verification_code_api';
import { i18n } from 'jh/passwords/constants';

const phone = '+86138888888888';

describe('getVerificationCode api', () => {
  let mock;

  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
  });

  describe('resolve', () => {
    it('correctly', async () => {
      mock.onPost(buildApiUrl(verificationCodePath)).reply(HTTP_STATUS_OK, {
        status: 'OK',
      });

      await expect(
        getVerificationCode({
          phone,
        }),
      ).resolves.not.toBeUndefined();
    });
  });

  describe('error', () => {
    it('should throw verification error', async () => {
      mock.onPost().reply(HTTP_STATUS_OK, {
        status: 'SENDING_LIMIT_RATE_ERROR',
      });

      await expect(
        getVerificationCode({
          phone,
        }),
      ).rejects.toEqual(new Error(i18n.SENDING_LIMIT_RATE_ERROR));
    });

    it('should throw normal error', async () => {
      mock.onPost().reply(HTTP_STATUS_INTERNAL_SERVER_ERROR);

      await expect(
        getVerificationCode({
          phone,
        }),
      ).rejects.not.toBeInstanceOf(VerificationError);
      await expect(
        getVerificationCode({
          phone,
        }),
      ).rejects.toBeInstanceOf(Error);
      await expect(
        getVerificationCode({
          phone,
        }),
      ).rejects.toEqual(new Error(i18n.SEND_CODE_ERROR));
    });
  });
});
