import { s__ } from '~/locale';
import {
  SCAN_PROFILE_CATEGORIES,
  SCAN_TRIGGER_DEFINITIONS,
} from '~/security_configuration/constants';

export const scanTypeName = (scanType) => SCAN_PROFILE_CATEGORIES[scanType]?.name || scanType;

export const scanTypeHelpLink = (scanType) => SCAN_PROFILE_CATEGORIES[scanType]?.helpLink;

export const resolveTriggers = (triggers) =>
  (triggers ?? []).map((triggerType) => SCAN_TRIGGER_DEFINITIONS[triggerType]).filter(Boolean);

export const managedByLabel = ({ gitlabRecommended }) =>
  gitlabRecommended ? s__('ScanProfiles|GitLab') : s__('ScanProfiles|Custom');
