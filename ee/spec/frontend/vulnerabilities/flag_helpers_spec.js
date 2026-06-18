import {
  isManualFlag,
  hasActiveAiFpDetection,
  isAiDetectedAsFalsePositive,
  isPendingFpDetection,
  isFailedFpDetection,
  isCompletedFpDetection,
  isSastVrApplicable,
} from 'ee/vulnerabilities/flag_helpers';
import { FLAG_STATUSES } from 'ee/vulnerabilities/constants';

describe('Vulnerability flag helpers', () => {
  describe('isManualFlag', () => {
    it.each`
      origin           | expected
      ${'manual_user'} | ${true}
      ${'manual_'}     | ${true}
      ${'ai_sast_fp'}  | ${false}
      ${''}            | ${false}
      ${undefined}     | ${false}
    `('returns $expected for origin "$origin"', ({ origin, expected }) => {
      expect(isManualFlag({ origin })).toBe(expected);
    });

    it('returns false for null/undefined flag', () => {
      expect(isManualFlag(null)).toBe(false);
      expect(isManualFlag(undefined)).toBe(false);
    });
  });

  describe('hasActiveAiFpDetection', () => {
    it.each`
      flag                                                                  | expected
      ${{ status: FLAG_STATUSES.IN_PROGRESS, origin: 'ai_sast_fp' }}        | ${true}
      ${{ status: FLAG_STATUSES.DETECTED_AS_FP, origin: 'ai_sast_fp' }}     | ${true}
      ${{ status: FLAG_STATUSES.DETECTED_AS_NOT_FP, origin: 'ai_sast_fp' }} | ${true}
      ${{ status: FLAG_STATUSES.FAILED, origin: 'ai_sast_fp' }}             | ${true}
      ${{ status: FLAG_STATUSES.NOT_STARTED, origin: 'ai_sast_fp' }}        | ${true}
      ${{ status: FLAG_STATUSES.DISMISSED, origin: 'ai_sast_fp' }}          | ${false}
      ${{ status: FLAG_STATUSES.DETECTED_AS_FP, origin: 'manual_user' }}    | ${false}
      ${{ status: null, origin: 'ai_sast_fp' }}                             | ${false}
      ${null}                                                               | ${false}
      ${undefined}                                                          | ${false}
    `('returns $expected for flag $flag', ({ flag, expected }) => {
      expect(hasActiveAiFpDetection(flag)).toBe(expected);
    });
  });

  describe('isAiDetectedAsFalsePositive', () => {
    it.each`
      flag                                                                  | expected
      ${{ status: FLAG_STATUSES.DETECTED_AS_FP, origin: 'ai_sast_fp' }}     | ${true}
      ${{ status: FLAG_STATUSES.DETECTED_AS_FP, origin: 'manual_user' }}    | ${false}
      ${{ status: FLAG_STATUSES.DETECTED_AS_NOT_FP, origin: 'ai_sast_fp' }} | ${false}
      ${{ status: FLAG_STATUSES.IN_PROGRESS, origin: 'ai_sast_fp' }}        | ${false}
      ${null}                                                               | ${false}
      ${undefined}                                                          | ${false}
    `('returns $expected for flag $flag', ({ flag, expected }) => {
      expect(isAiDetectedAsFalsePositive(flag)).toBe(expected);
    });
  });

  describe('isPendingFpDetection', () => {
    it.each`
      status                          | expected
      ${FLAG_STATUSES.NOT_STARTED}    | ${true}
      ${FLAG_STATUSES.IN_PROGRESS}    | ${true}
      ${FLAG_STATUSES.DETECTED_AS_FP} | ${false}
      ${FLAG_STATUSES.FAILED}         | ${false}
      ${FLAG_STATUSES.DISMISSED}      | ${false}
      ${undefined}                    | ${false}
    `('returns $expected for status $status', ({ status, expected }) => {
      expect(isPendingFpDetection({ status })).toBe(expected);
    });

    it('returns false for null/undefined flag', () => {
      expect(isPendingFpDetection(null)).toBe(false);
      expect(isPendingFpDetection(undefined)).toBe(false);
    });
  });

  describe('isFailedFpDetection', () => {
    it('returns true only for FAILED status', () => {
      expect(isFailedFpDetection({ status: FLAG_STATUSES.FAILED })).toBe(true);
      expect(isFailedFpDetection({ status: FLAG_STATUSES.IN_PROGRESS })).toBe(false);
      expect(isFailedFpDetection(null)).toBe(false);
      expect(isFailedFpDetection(undefined)).toBe(false);
    });
  });

  describe('isSastVrApplicable', () => {
    const baseVulnerability = {
      aiResolutionAvailable: true,
      duoSastVrWorkflowEnabled: true,
      latestFlag: null,
    };
    const baseContext = { duoAgentPlatformAvailable: true, agenticSastVrUi: true };

    it('returns true when all conditions are met', () => {
      expect(isSastVrApplicable({ vulnerability: baseVulnerability, ...baseContext })).toBe(true);
    });

    it.each`
      override                                                                                              | expected
      ${{ context: { agenticSastVrUi: false } }}                                                            | ${false}
      ${{ context: { duoAgentPlatformAvailable: false } }}                                                  | ${false}
      ${{ vulnerability: { aiResolutionAvailable: false } }}                                                | ${false}
      ${{ vulnerability: { duoSastVrWorkflowEnabled: false } }}                                             | ${false}
      ${{ vulnerability: { latestFlag: { status: FLAG_STATUSES.DETECTED_AS_FP, origin: 'ai_sast_fp' } } }}  | ${false}
      ${{ vulnerability: { latestFlag: { status: FLAG_STATUSES.DETECTED_AS_FP, origin: 'manual_user' } } }} | ${true}
    `('returns $expected when $override', ({ override, expected }) => {
      expect(
        isSastVrApplicable({
          vulnerability: { ...baseVulnerability, ...(override.vulnerability ?? {}) },
          ...baseContext,
          ...(override.context ?? {}),
        }),
      ).toBe(expected);
    });

    it('returns false when vulnerability is null', () => {
      expect(isSastVrApplicable({ vulnerability: null, ...baseContext })).toBe(false);
    });
  });

  describe('isCompletedFpDetection', () => {
    it.each`
      status                              | expected
      ${FLAG_STATUSES.DETECTED_AS_FP}     | ${true}
      ${FLAG_STATUSES.DETECTED_AS_NOT_FP} | ${true}
      ${FLAG_STATUSES.IN_PROGRESS}        | ${false}
      ${FLAG_STATUSES.FAILED}             | ${false}
      ${FLAG_STATUSES.DISMISSED}          | ${false}
      ${undefined}                        | ${false}
    `('returns $expected for status $status', ({ status, expected }) => {
      expect(isCompletedFpDetection({ status })).toBe(expected);
    });
  });
});
