import { s__ } from '~/locale';

export const ENVIRONMENT_FILTERS = [
  {
    id: 'ALL',
    text: s__('ContinuousDeployment|All types'),
  },
  {
    id: 'PRODUCTION',
    text: s__('ContinuousDeployment|Production'),
  },
  {
    id: 'STAGING',
    text: s__('ContinuousDeployment|Staging'),
  },
];

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
