import {
  FLAG_STATUSES,
  COMPLETED_DETECTION_STATUSES,
  PENDING_DETECTION_STATUSES,
  MANUAL_ORIGIN_PREFIX,
} from './constants';

export const isManualFlag = (flag) => Boolean(flag?.origin?.startsWith(MANUAL_ORIGIN_PREFIX));

export const hasActiveAiFpDetection = (flag) =>
  Boolean(flag?.status) && flag.status !== FLAG_STATUSES.DISMISSED && !isManualFlag(flag);

export const isAiDetectedAsFalsePositive = (flag) =>
  flag?.status === FLAG_STATUSES.DETECTED_AS_FP && !isManualFlag(flag);

export const isPendingFpDetection = (flag) => PENDING_DETECTION_STATUSES.includes(flag?.status);

export const isFailedFpDetection = (flag) => flag?.status === FLAG_STATUSES.FAILED;

export const isCompletedFpDetection = (flag) => COMPLETED_DETECTION_STATUSES.includes(flag?.status);
