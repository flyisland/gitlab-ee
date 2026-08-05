import { s__ } from '~/locale';

export const STATUS_ALL = 'ALL';
export const STATUS_DEGRADED = 'DEGRADED';
export const STATUS_DEPLOYING = 'DEPLOYING';
export const STATUS_HEALTHY = 'HEALTHY';
export const STATUS_PENDING = 'PENDING';

export const ENVIRONMENT_FILTERS = {
  ALL: s__('ContinuousDeployment|All types'),
  DEVELOPMENT: s__('ContinuousDeployment|Development'),
  QA: s__('ContinuousDeployment|QA'),
  STAGING: s__('ContinuousDeployment|Staging'),
  PRODUCTION: s__('ContinuousDeployment|Production'),
};

export const statusDescriptionMap = {
  [STATUS_DEGRADED]: s__('ContinuousDeployment|Degradation detected'),
  [STATUS_DEPLOYING]: s__('ContinuousDeployment|Deployment in progress'),
  [STATUS_HEALTHY]: s__('ContinuousDeployment|All systems healthy'),
  [STATUS_PENDING]: s__('ContinuousDeployment|Waiting for your approval'),
};

export const statusSortOrderMap = {
  [STATUS_PENDING]: 0,
  [STATUS_DEGRADED]: 1,
  [STATUS_DEPLOYING]: 2,
  [STATUS_HEALTHY]: 3,
};

export const statusTextMap = {
  [STATUS_DEGRADED]: s__('ContinuousDeployment|Degraded'),
  [STATUS_DEPLOYING]: s__('ContinuousDeployment|Deploying'),
  [STATUS_HEALTHY]: s__('ContinuousDeployment|Healthy'),
  [STATUS_PENDING]: s__('ContinuousDeployment|Approval needed'),
};

export const statusVariantMap = {
  [STATUS_DEGRADED]: 'warning',
  [STATUS_DEPLOYING]: 'info',
  [STATUS_HEALTHY]: 'success',
  [STATUS_PENDING]: 'warning',
};

// Constraints
export const MAX_NAME_LENGTH = 255;

export const APPLICATION_FILTERS = [
  {
    id: 'ALL',
    text: s__('ContinuousDeployment|All'),
  },
  {
    id: 'RUNNING',
    text: s__('ContinuousDeployment|Running'),
  },
  {
    id: 'DEGRADED',
    text: s__('ContinuousDeployment|Degraded'),
  },
];

export const SYNC_VARIANTS = {
  synced: 'success',
  'out-of-sync': 'warning',
};

export const SYNC_LABELS = {
  synced: s__('ContinuousDeployment|Synced'),
  'out-of-sync': s__('ContinuousDeployment|Out of sync'),
};

export const HEALTH_VARIANTS = {
  ok: 'success',
  alert: 'danger',
  degraded: 'warning',
  deploying: 'info',
};

export const HEALTH_LABELS = {
  ok: s__('ContinuousDeployment|Healthy'),
  alert: s__('ContinuousDeployment|Alert'),
  degraded: s__('ContinuousDeployment|Degraded'),
  deploying: s__('ContinuousDeployment|Deploying'),
};

export const ROLLOUT_STATE_VARIANTS = {
  PENDING: 'warning',
  IN_PROGRESS: 'info',
  PAUSED: 'neutral',
  COMPLETED: 'success',
  FAILED: 'danger',
  CANCELLED: 'neutral',
};

export const ROLLOUT_STATE_LABELS = {
  PENDING: s__('ContinuousDeployment|Pending'),
  IN_PROGRESS: s__('ContinuousDeployment|In progress'),
  PAUSED: s__('ContinuousDeployment|Paused'),
  COMPLETED: s__('ContinuousDeployment|Available'),
  FAILED: s__('ContinuousDeployment|Failed'),
  CANCELLED: s__('ContinuousDeployment|Cancelled'),
};

// TODO: Consumed by upcoming service-type badge rendering in ServiceSidePanel detail mode.

export const HEALTH_DOT_CLASSES = {
  ok: 'gl-bg-green-500',
  alert: 'gl-bg-red-500',
  degraded: 'gl-bg-orange-500',
  deploying: 'gl-bg-blue-500',
  default: 'gl-bg-gray-400',
};

export const TIER_ORDER = ['dev', 'qa', 'preprod', 'prod'];

export const TIER_LABELS = {
  dev: s__('ContinuousDeployment|Dev'),
  qa: s__('ContinuousDeployment|QA'),
  preprod: s__('ContinuousDeployment|Pre-production'),
  prod: s__('ContinuousDeployment|Production'),
};

export const TH_CLASS = 'gl-pb-2 !gl-text-sm !gl-text-secondary';
export const TD_CLASS = 'gl-py-2 !gl-text-sm';

export const ROW_CLASS = 'gl-cursor-pointer hover:gl-bg-subtle';
export const ROW_OPEN_CLASS = 'gl-bg-blue-50 gl-shadow-[inset_2px_0_0_0_var(--blue-500)]';
export const ROW_SELECTED_CLASS = 'gl-bg-purple-50';
