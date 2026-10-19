import { s__ } from '~/locale';

export const ORBIT_CLI_SETUP_COMMAND = 'glab orbit setup';

// `key` is the graph_status domain name.
export const OVERVIEW_AREAS = [
  { key: 'core', label: s__('Orbit|Core') },
  { key: 'plan', label: s__('Orbit|Planning') },
  { key: 'code_review', label: s__('Orbit|Code review') },
  { key: 'ci', label: s__('Orbit|CI/CD') },
  { key: 'source_code', label: s__('Orbit|Source code') },
  { key: 'security', label: s__('Orbit|Security') },
];
