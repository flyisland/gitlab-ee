import {
  SCAN_PROFILE_SCANNER_HEALTH_ACTIVE,
  SCAN_PROFILE_SCANNER_HEALTH_FAILED,
  SCAN_PROFILE_SCANNER_HEALTH_STALE,
  SCAN_PROFILE_SCANNER_HEALTH_UNCONFIGURED,
  SCAN_PROFILE_SCANNER_HEALTH_WARNING,
} from '~/security_configuration/constants';

export const statusIcon = (status) => {
  const icons = {
    [SCAN_PROFILE_SCANNER_HEALTH_UNCONFIGURED]: 'status_failed',
    [SCAN_PROFILE_SCANNER_HEALTH_ACTIVE]: 'status-success',
    [SCAN_PROFILE_SCANNER_HEALTH_WARNING]: 'status_warning',
    [SCAN_PROFILE_SCANNER_HEALTH_FAILED]: 'status-failed',
    [SCAN_PROFILE_SCANNER_HEALTH_STALE]: 'status-scheduled',
  };
  return icons[status?.toLowerCase()] || 'status_failed';
};

export const statusIconClass = (status) => {
  const classes = {
    [SCAN_PROFILE_SCANNER_HEALTH_UNCONFIGURED]: 'gl-text-subtle',
    [SCAN_PROFILE_SCANNER_HEALTH_ACTIVE]: 'gl-text-success',
    [SCAN_PROFILE_SCANNER_HEALTH_WARNING]: 'gl-text-warning',
    [SCAN_PROFILE_SCANNER_HEALTH_FAILED]: 'gl-text-danger',
    [SCAN_PROFILE_SCANNER_HEALTH_STALE]: 'gl-text-subtle',
  };
  return classes[status?.toLowerCase()] || 'gl-text-subtle';
};
