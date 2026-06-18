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

/**
 * Whether Agentic SAST Vulnerability Resolution applies to a vulnerability.
 *
 * @see https://docs.gitlab.com/user/application_security/vulnerabilities/agentic_vulnerability_resolution/#automatic-resolution-conditions
 * @param {Object} options
 * @param {Object} options.vulnerability - The vulnerability, with `aiResolutionAvailable`, `duoSastVrWorkflowEnabled`, and `latestFlag`.
 * @param {boolean} options.duoAgentPlatformAvailable - Whether the Duo Agent Platform is available.
 * @param {boolean} options.agenticSastVrUi - Whether the `agentic_sast_vr_ui` feature flag is enabled.
 * @returns {boolean} `true` when all conditions for SAST VR are met.
 */
export const isSastVrApplicable = ({ vulnerability, duoAgentPlatformAvailable, agenticSastVrUi }) =>
  Boolean(
    agenticSastVrUi &&
      duoAgentPlatformAvailable &&
      vulnerability?.aiResolutionAvailable &&
      vulnerability?.duoSastVrWorkflowEnabled &&
      !isAiDetectedAsFalsePositive(vulnerability?.latestFlag),
  );
