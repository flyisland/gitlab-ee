import { s__ } from '~/locale';
import { CATEGORY_COMPLIANCE, CATEGORY_DEPLOYMENT } from './categories';

// Triggers a policy can respond to. `id` is persisted as the policy's `trigger_type`, so it
// is the wire value and must match what the metadata endpoint returns.
//
// The CD deployment gate experiment ships the three deployment lifecycle triggers.
// See https://gitlab.com/gitlab-org/gitlab/-/issues/607341 for scope.
export const TRIGGER_DEPLOYMENT_REQUESTED = 'deployment_requested';
export const TRIGGER_ENVIRONMENT_ADVANCED = 'environment_advanced';
export const TRIGGER_DEPLOYMENT_PROMOTED = 'deployment_promoted';

// Settings enforcement (https://gitlab.com/groups/gitlab-org/-/work_items/23462). The store
// records a drift check as `project_settings_drift_checked`, which is engine-internal and
// deliberately absent from its authoring catalogue, so no entry for it belongs here.
export const TRIGGER_PROJECT_SETTINGS_CHANGE_REQUESTED = 'project_settings_change_requested';

// Project lifecycle (https://gitlab.com/gitlab-org/gitlab/-/work_items/630210). None of
// these carry configuration: the event itself is the whole condition, and what a policy
// checks about the project is the rules' job.
export const TRIGGER_PROJECT_CREATED = 'project_created';
export const TRIGGER_PROJECT_TRANSFERRED = 'project_transferred';
export const TRIGGER_PROJECT_CREATION_REQUESTED = 'project_creation_requested';

export const TRIGGERS = [
  {
    id: TRIGGER_DEPLOYMENT_REQUESTED,
    category: CATEGORY_DEPLOYMENT,
    label: s__('PolicyStore|Deployment requested'),
    description: s__('PolicyStore|When a deployment to a gated environment is requested'),
    icon: 'deployments',
    fields: [],
  },
  {
    id: TRIGGER_ENVIRONMENT_ADVANCED,
    category: CATEGORY_DEPLOYMENT,
    label: s__('PolicyStore|Environment advanced'),
    description: s__('PolicyStore|When a deployment advances to the next environment'),
    icon: 'environment',
    fields: [],
  },
  {
    id: TRIGGER_DEPLOYMENT_PROMOTED,
    category: CATEGORY_DEPLOYMENT,
    label: s__('PolicyStore|Deployment promoted'),
    description: s__('PolicyStore|When an existing deployment is promoted to a new environment'),
    icon: 'upgrade',
    fields: [],
  },
  {
    id: TRIGGER_PROJECT_SETTINGS_CHANGE_REQUESTED,
    category: CATEGORY_COMPLIANCE,
    label: s__('PolicyStore|Project settings change requested'),
    description: s__(
      'PolicyStore|When a change to a project setting is requested, before it is saved',
    ),
    icon: 'settings',
    fields: [],
  },
  {
    id: TRIGGER_PROJECT_CREATED,
    category: CATEGORY_COMPLIANCE,
    label: s__('PolicyStore|Project created'),
    description: s__('PolicyStore|When a new project has been created'),
    icon: 'project',
    fields: [],
  },
  {
    id: TRIGGER_PROJECT_TRANSFERRED,
    category: CATEGORY_COMPLIANCE,
    label: s__('PolicyStore|Project transferred'),
    description: s__('PolicyStore|When a project moves to a different namespace'),
    icon: 'arrow-right',
    fields: [],
  },
  {
    id: TRIGGER_PROJECT_CREATION_REQUESTED,
    category: CATEGORY_COMPLIANCE,
    label: s__('PolicyStore|Project creation requested'),
    description: s__('PolicyStore|When a project is about to be created, before it exists'),
    icon: 'folder-new',
    fields: [],
  },
];
