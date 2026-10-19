import { s__ } from '~/locale';
import {
  SCAN_PROFILE_TYPE_SAST,
  SCAN_PROFILE_TYPE_SECRET_DETECTION,
} from '~/security_configuration/constants';

export const VALUE_TYPE_BOOLEAN = 'boolean';
export const VALUE_TYPE_ENUM = 'enum';
export const VALUE_TYPE_STRING = 'string';
export const VALUE_TYPE_STRING_LIST = 'stringList';

// envVar mirrors Security::ScanProfiles::Configuration::CiVariables::MAPPINGS in
// ee/app/models/security/scan_profiles/configuration/ci_variables.rb, the source of truth for
// which CI/CD variable each field becomes. Only secureAnalyzersPrefix is shared between scan
// types there; imageSuffix and excludedPaths use a different variable name per scan type even
// though the GraphQL field and UI copy are otherwise identical.
const IMAGE_SUFFIX_OPTIONS = [
  { value: '', text: s__('ScanProfiles|Default') },
  // eslint-disable-next-line @gitlab/require-i18n-strings -- backend suffix value, not prose
  { value: '-fips', text: s__('ScanProfiles|FIPS') },
];

const secureAnalyzersPrefix = {
  label: s__('ScanProfiles|Analyzer image registry'),
  description: s__(
    "ScanProfiles|Pull analyzer images from your own container registry instead of GitLab's public one.",
  ),
  valueType: VALUE_TYPE_STRING,
  placeholder: 'registry.example.com/analyzers',
  envVar: 'SECURE_ANALYZERS_PREFIX',
};

const imageSuffix = (envVar) => ({
  label: s__('ScanProfiles|Image variant'),
  description: s__('ScanProfiles|Which build of the analyzer image to pull.'),
  valueType: VALUE_TYPE_ENUM,
  options: IMAGE_SUFFIX_OPTIONS,
  envVar,
});

const excludedPaths = (envVar) => ({
  label: s__('ScanProfiles|Paths to exclude'),
  description: s__('ScanProfiles|Paths left out of the scan.'),
  valueType: VALUE_TYPE_STRING_LIST,
  placeholder: 'spec/**',
  envVar,
});

// Mirrors SecretDetectionConfigurationInputType in
// ee/app/graphql/types/security/scan_profiles/secret_detection_configuration_input_type.rb
const SECRET_DETECTION_VARIABLE_DEFINITIONS = {
  secureAnalyzersPrefix,
  imageSuffix: imageSuffix('SECRET_DETECTION_IMAGE_SUFFIX'),
  historicScan: {
    label: s__('ScanProfiles|Historic scan'),
    description: s__('ScanProfiles|Scan the full Git history instead of only the current state.'),
    valueType: VALUE_TYPE_BOOLEAN,
    envVar: 'SECRET_DETECTION_HISTORIC_SCAN',
  },
  logOptions: {
    label: s__('ScanProfiles|Log options'),
    description: s__('ScanProfiles|Options passed to git log to control the commit range scanned.'),
    valueType: VALUE_TYPE_STRING,
    placeholder: '--since=1.year.ago',
    envVar: 'SECRET_DETECTION_LOG_OPTIONS',
  },
  excludedPaths: excludedPaths('SECRET_DETECTION_EXCLUDED_PATHS'),
  rulesetGitReference: {
    label: s__('ScanProfiles|Ruleset Git reference'),
    description: s__('ScanProfiles|Git reference of the remote ruleset configuration to use.'),
    valueType: VALUE_TYPE_STRING,
    placeholder: 'gitlab.com/example-group/remote-ruleset-project',
    envVar: 'SECRET_DETECTION_RULESET_GIT_REFERENCE',
  },
};

// Mirrors SastConfigurationInputType in
// ee/app/graphql/types/security/scan_profiles/sast_configuration_input_type.rb
const SAST_VARIABLE_DEFINITIONS = {
  secureAnalyzersPrefix,
  imageSuffix: imageSuffix('SAST_IMAGE_SUFFIX'),
  analyzerImageTag: {
    label: s__('ScanProfiles|Analyzer image tag'),
    description: s__('ScanProfiles|Pin the analyzer image to a specific tag.'),
    valueType: VALUE_TYPE_STRING,
    placeholder: '3.7',
    envVar: 'SAST_ANALYZER_IMAGE_TAG',
  },
  excludedAnalyzers: {
    label: s__('ScanProfiles|Analyzers to skip'),
    description: s__('ScanProfiles|Analyzers that should not run for this profile.'),
    valueType: VALUE_TYPE_STRING_LIST,
    placeholder: 'semgrep',
    envVar: 'SAST_EXCLUDED_ANALYZERS',
  },
  excludedPaths: excludedPaths('SAST_EXCLUDED_PATHS'),
  advancedSastPartialScan: {
    label: s__('ScanProfiles|Advanced SAST partial scanning'),
    description: s__('ScanProfiles|Controls GitLab Advanced SAST diff-based scanning.'),
    valueType: VALUE_TYPE_ENUM,
    options: [
      { value: 'differential', text: s__('ScanProfiles|Enabled') },
      { value: 'false', text: s__('ScanProfiles|Disabled') },
    ],
    envVar: 'ADVANCED_SAST_PARTIAL_SCAN',
  },
  gitlabAdvSastIncrScan: {
    label: s__('ScanProfiles|Advanced SAST incremental scanning'),
    description: s__('ScanProfiles|Whether GitLab Advanced SAST incremental scanning is enabled.'),
    valueType: VALUE_TYPE_BOOLEAN,
    envVar: 'GITLAB_ADV_SAST_INCR_SCAN',
  },
};

const VARIABLE_DEFINITIONS_BY_SCAN_TYPE = {
  [SCAN_PROFILE_TYPE_SECRET_DETECTION]: SECRET_DETECTION_VARIABLE_DEFINITIONS,
  [SCAN_PROFILE_TYPE_SAST]: SAST_VARIABLE_DEFINITIONS,
};

export const variableDefinitionsFor = (scanType) =>
  VARIABLE_DEFINITIONS_BY_SCAN_TYPE[scanType] ?? {};
