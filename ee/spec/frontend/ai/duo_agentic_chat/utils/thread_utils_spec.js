import { resetThreadContent, isThreadExpired } from 'ee/ai/duo_agentic_chat/utils/thread_utils';
import { DUO_CHAT_VIEWS } from 'ee/ai/constants';
import { THREAD_MAX_AGE_DAYS } from 'ee/ai/duo_agentic_chat/constants';

describe('thread_utils', () => {
  describe('resetThreadContent', () => {
    describe('when called', () => {
      it('returns clean thread content', () => {
        const result = resetThreadContent();

        expect(result).toEqual({
          multithreadedView: DUO_CHAT_VIEWS.CHAT,
        });
      });
    });
  });

  describe('isThreadExpired', () => {
    const MILLISECONDS_PER_DAY = 24 * 60 * 60 * 1000;

    it('returns true when thread is older than 30 days', () => {
      const oldDate = new Date(Date.now() - 31 * MILLISECONDS_PER_DAY).toISOString();

      expect(isThreadExpired(oldDate)).toBe(true);
    });

    it('returns false when thread is newer than 30 days', () => {
      const recentDate = new Date(Date.now() - 10 * MILLISECONDS_PER_DAY).toISOString();

      expect(isThreadExpired(recentDate)).toBe(false);
    });

    it('returns false when thread is exactly 30 days old', () => {
      const exactDate = new Date(
        Date.now() - THREAD_MAX_AGE_DAYS * MILLISECONDS_PER_DAY,
      ).toISOString();

      expect(isThreadExpired(exactDate)).toBe(false);
    });

    it('returns false when lastUpdatedAt is null', () => {
      expect(isThreadExpired(null)).toBe(false);
    });

    it('returns false when lastUpdatedAt is undefined', () => {
      expect(isThreadExpired(undefined)).toBe(false);
    });
  });
});
