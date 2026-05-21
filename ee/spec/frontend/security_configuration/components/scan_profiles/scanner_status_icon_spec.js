import { GlIcon } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import ScannerStatusIcon from 'ee/security_configuration/components/scan_profiles/scanner_status_icon.vue';
import {
  SCAN_PROFILE_SCANNER_HEALTH_ACTIVE,
  SCAN_PROFILE_SCANNER_HEALTH_FAILED,
  SCAN_PROFILE_SCANNER_HEALTH_WARNING,
  SCAN_PROFILE_SCANNER_HEALTH_STALE,
  SCAN_PROFILE_SCANNER_HEALTH_PENDING,
  SCAN_PROFILE_SCANNER_HEALTH_UNCONFIGURED,
} from '~/security_configuration/constants';

describe('ScannerStatusIcon', () => {
  let wrapper;

  const createComponent = (status) => {
    wrapper = shallowMountExtended(ScannerStatusIcon, {
      propsData: { status },
    });
  };

  const findIcon = () => wrapper.findComponent(GlIcon);

  it.each([
    [SCAN_PROFILE_SCANNER_HEALTH_ACTIVE, 'status-success', 'gl-text-success'],
    [SCAN_PROFILE_SCANNER_HEALTH_FAILED, 'status-failed', 'gl-text-danger'],
    [SCAN_PROFILE_SCANNER_HEALTH_WARNING, 'status_warning', 'gl-text-warning'],
    [SCAN_PROFILE_SCANNER_HEALTH_STALE, 'status-scheduled', 'gl-text-subtle'],
    [SCAN_PROFILE_SCANNER_HEALTH_PENDING, 'status-waiting', 'gl-text-subtle'],
    [SCAN_PROFILE_SCANNER_HEALTH_UNCONFIGURED, 'clear', 'gl-text-subtle'],
  ])('renders correct icon name and class for %s status', (status, expectedIcon, expectedClass) => {
    createComponent(status);
    expect(findIcon().props('name')).toBe(expectedIcon);
    expect(findIcon().classes()).toContain(expectedClass);
  });

  it('renders fallback icon for unknown status', () => {
    createComponent('unknown');
    expect(findIcon().props('name')).toBe('status_failed');
    expect(findIcon().classes()).toContain('gl-text-subtle');
  });
});
