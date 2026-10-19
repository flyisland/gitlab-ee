import { s__ } from '~/locale';

export const GROUPS_PAGE_SIZE = 20;
export const EXCLUDED_GROUPS_PAGE_SIZE = 100;
export const INDEXING_POLL_INTERVAL_MS = 30000;
export const BULK_ACTION_CONCURRENCY = 5;
export const LISTED_FAILURES_LIMIT = 5;

export const GROUP_FILTER_ALL = 'all';
export const GROUP_FILTER_ON = 'on';
export const GROUP_FILTER_EXCLUDED = 'excluded';

export const GROUP_FILTER_OPTIONS = [
  { value: GROUP_FILTER_ALL, text: s__('Orbit|All') },
  { value: GROUP_FILTER_ON, text: s__('Orbit|On') },
  { value: GROUP_FILTER_EXCLUDED, text: s__('Orbit|Excluded') },
];

export const ACTION_TURN_ON = 'turnOn';
export const ACTION_TURN_OFF = 'turnOff';
export const ACTION_EXCLUDE = 'exclude';
export const ACTION_INCLUDE = 'include';

export const ACTION_LABELS = {
  [ACTION_TURN_ON]: s__('Orbit|Turn on Orbit'),
  [ACTION_TURN_OFF]: s__('Orbit|Turn off Orbit'),
  [ACTION_EXCLUDE]: s__('Orbit|Exclude from automatic indexing'),
  [ACTION_INCLUDE]: s__('Orbit|Remove exclusion'),
};

export const ACTION_PROGRESS_LABELS = {
  [ACTION_TURN_ON]: s__('Orbit|Turning on Orbit'),
  [ACTION_TURN_OFF]: s__('Orbit|Turning off Orbit'),
  [ACTION_EXCLUDE]: s__('Orbit|Excluding groups'),
  [ACTION_INCLUDE]: s__('Orbit|Removing exclusions'),
};

export const CONFIRM_TURN_OFF = 'turnOff';
export const CONFIRM_EXCLUDE = 'exclude';
export const CONFIRM_AUTO_INDEX = 'autoIndex';
export const CONFIRM_KINDS = [CONFIRM_TURN_OFF, CONFIRM_EXCLUDE, CONFIRM_AUTO_INDEX];

export const CONFIRMED_ACTIONS = {
  [CONFIRM_TURN_OFF]: ACTION_TURN_OFF,
  [CONFIRM_EXCLUDE]: ACTION_EXCLUDE,
};

export const SETTING_AUTO_INDEX = 'orbit_auto_index_root_namespace';
export const SETTING_DUO_DEFAULT = 'orbit_dap_enabled_by_default';

export const INDEXING_PHASE = {
  NOT_STARTED: 'NOT_STARTED',
  SYNCING: 'SYNCING',
  READY: 'READY',
  ERROR: 'ERROR',
  UNKNOWN: 'UNKNOWN',
};

export const INDEXING_PHASE_LABELS = {
  [INDEXING_PHASE.NOT_STARTED]: s__('Orbit|Queued to start'),
  [INDEXING_PHASE.SYNCING]: s__('Orbit|Indexing'),
  [INDEXING_PHASE.READY]: s__('Orbit|Indexed'),
  [INDEXING_PHASE.ERROR]: s__('Orbit|Indexing failed'),
  [INDEXING_PHASE.UNKNOWN]: s__('Orbit|Status unknown'),
};

export const ACTIVE_INDEXING_PHASES = [INDEXING_PHASE.NOT_STARTED, INDEXING_PHASE.SYNCING];

export const ACTION_ERROR_KIND = {
  REJECTED: 'rejected',
  NO_ACCESS: 'noAccess',
  NETWORK: 'network',
  SERVER: 'server',
};
