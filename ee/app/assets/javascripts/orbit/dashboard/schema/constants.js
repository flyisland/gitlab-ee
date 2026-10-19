import { s__ } from '~/locale';

export const SCHEMA_DOMAINS = [
  { key: 'core', label: s__('Orbit|Projects'), icon: 'project', entryType: 'project' },
  { key: 'plan', label: s__('Orbit|Work items'), icon: 'work-items', entryType: 'workitem' },
  {
    key: 'code_review',
    label: s__('Orbit|Merge requests'),
    icon: 'merge-request',
    entryType: 'mergerequest',
  },
  { key: 'ci', label: s__('Orbit|Pipelines'), icon: 'pipeline', entryType: 'pipeline' },
  { key: 'source_code', label: s__('Orbit|Code'), icon: 'code', entryType: 'file' },
  {
    key: 'security',
    label: s__('Orbit|Vulnerabilities'),
    icon: 'shield',
    entryType: 'vulnerability',
  },
  { key: 'packages', label: s__('Orbit|Packages'), icon: 'package', entryType: 'package' },
  {
    key: 'container_registry',
    label: s__('Orbit|Container registry'),
    icon: 'container-image',
    entryType: 'containerrepository',
  },
];

export const CENTER_DOMAIN_KEY = 'core';

export const MAX_LABELED_NEIGHBORS = 14;

export const DOMAIN_RING_RADIUS = 36;

export const NEIGHBOR_RING_RADIUS = 40;
