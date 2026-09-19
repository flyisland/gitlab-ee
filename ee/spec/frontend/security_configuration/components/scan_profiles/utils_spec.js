import {
  scanTypeName,
  scanTypeHelpLink,
  resolveTriggers,
  managedByLabel,
} from 'ee/security_configuration/components/scan_profiles/utils';
import {
  SCAN_PROFILE_TYPE_SAST,
  SCAN_PROFILE_TYPE_SECRET_DETECTION,
} from '~/security_configuration/constants';

describe('scan profile utils', () => {
  describe('scanTypeName', () => {
    it('names a known scan type', () => {
      expect(scanTypeName(SCAN_PROFILE_TYPE_SECRET_DETECTION)).toBe('Secret detection');
    });

    it('falls back to the raw value for an unknown scan type', () => {
      expect(scanTypeName('NOT_A_SCANNER')).toBe('NOT_A_SCANNER');
    });
  });

  describe('scanTypeHelpLink', () => {
    it('links to the help page for a known scan type', () => {
      expect(scanTypeHelpLink(SCAN_PROFILE_TYPE_SAST)).toBe(
        '/help/user/application_security/sast/_index',
      );
    });

    it('has no link for an unknown scan type', () => {
      expect(scanTypeHelpLink('NOT_A_SCANNER')).toBeUndefined();
    });
  });

  describe('managedByLabel', () => {
    it.each([
      [true, 'GitLab'],
      [false, 'Custom'],
    ])('labels a profile with gitlabRecommended %s as %s', (gitlabRecommended, label) => {
      expect(managedByLabel({ gitlabRecommended })).toBe(label);
    });
  });

  describe('resolveTriggers', () => {
    it('resolves each trigger type to its definition', () => {
      const triggers = resolveTriggers(['MERGE_REQUEST_PIPELINE', 'GIT_PUSH_EVENT']);

      expect(triggers.map(({ anchor }) => anchor)).toEqual([
        'merge-request-pipeline',
        'secret-push-protection',
      ]);
    });

    it('drops trigger types with no definition', () => {
      const triggers = resolveTriggers(['MERGE_REQUEST_PIPELINE', 'NOT_A_TRIGGER']);

      expect(triggers.map(({ anchor }) => anchor)).toEqual(['merge-request-pipeline']);
    });

    it.each([null, undefined, []])('returns an empty list for %p', (triggers) => {
      expect(resolveTriggers(triggers)).toEqual([]);
    });
  });
});
