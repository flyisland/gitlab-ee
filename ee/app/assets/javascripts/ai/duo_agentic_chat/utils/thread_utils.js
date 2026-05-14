import { DUO_CHAT_VIEWS } from 'ee/ai/constants';
import { MILLISECONDS_IN_DAY } from '~/lib/utils/datetime/date_calculation_utility';
import { THREAD_MAX_AGE_DAYS } from '../constants';

export function resetThreadContent() {
  return {
    multithreadedView: DUO_CHAT_VIEWS.CHAT,
  };
}

export function isThreadExpired(lastUpdatedAt) {
  if (!lastUpdatedAt) return false;

  const updatedDate = new Date(lastUpdatedAt);
  const ageInMs = Date.now() - updatedDate.getTime();

  return ageInMs > THREAD_MAX_AGE_DAYS * MILLISECONDS_IN_DAY;
}
