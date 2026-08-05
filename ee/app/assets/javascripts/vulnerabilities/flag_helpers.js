import { SECURITY_REPORT_TYPE_ENUM_DEPENDENCY_SCANNING } from '~/vue_shared/security_reports/constants';
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

/**
 * Whether the single-vulnerability SCA Vulnerability Resolution action applies.
 *
 * There is no precomputed "fix available" signal for SCA, so eligibility here is
 * just "a supported SCA row": the fix-availability check happens server-side when
 * the action is triggered (check-on-click).
 *
 * @param {Object} options
 * @param {Object} options.vulnerability - The vulnerability, with `reportType`.
 * @param {boolean} options.dependencyManagementAutoRemediation - Whether the `dependency_management_auto_remediation` feature flag is enabled.
 * @param {boolean} options.securityRemediationProfiles - Whether the `security_remediation_profiles` feature flag is enabled.
 * @returns {boolean} `true` when the SCA VR action should be offered.
 */
export const isScaVrApplicable = ({
  vulnerability,
  dependencyManagementAutoRemediation,
  securityRemediationProfiles,
}) =>
  Boolean(
    dependencyManagementAutoRemediation &&
      securityRemediationProfiles &&
      vulnerability?.reportType === SECURITY_REPORT_TYPE_ENUM_DEPENDENCY_SCANNING,
  );
