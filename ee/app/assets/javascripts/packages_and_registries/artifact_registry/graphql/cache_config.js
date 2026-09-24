import {
  TYPENAME_ARTIFACT_REGISTRY_IMAGE,
  TYPENAME_ARTIFACT_REGISTRY_MAVEN_PACKAGE,
  TYPENAME_ARTIFACT_REGISTRY_MAVEN_PACKAGE_DETAILS,
  TYPENAME_ARTIFACT_REGISTRY_MAVEN_VERSION_FILE,
  TYPENAME_ARTIFACT_REGISTRY_NPM_PACKAGE,
  TYPENAME_ARTIFACT_REGISTRY_NPM_PACKAGE_DETAILS,
  TYPENAME_ARTIFACT_REGISTRY_NPM_VERSION_FILE,
  TYPENAME_ARTIFACT_REGISTRY_PACKAGE,
  TYPENAME_ARTIFACT_REGISTRY_PACKAGE_DETAILS,
  TYPENAME_ARTIFACT_REGISTRY_REPOSITORY,
  TYPENAME_ARTIFACT_REGISTRY_REPOSITORY_DETAILS,
  TYPENAME_ARTIFACT_REGISTRY_VERSION_DETAILS,
  TYPENAME_ARTIFACT_REGISTRY_VERSION_FILE,
  TYPENAME_ORGANIZATION,
} from '../constants';

export const possibleTypes = {
  [TYPENAME_ARTIFACT_REGISTRY_PACKAGE]: [
    TYPENAME_ARTIFACT_REGISTRY_MAVEN_PACKAGE,
    TYPENAME_ARTIFACT_REGISTRY_NPM_PACKAGE,
  ],
  [TYPENAME_ARTIFACT_REGISTRY_PACKAGE_DETAILS]: [
    TYPENAME_ARTIFACT_REGISTRY_MAVEN_PACKAGE_DETAILS,
    TYPENAME_ARTIFACT_REGISTRY_NPM_PACKAGE_DETAILS,
  ],
  [TYPENAME_ARTIFACT_REGISTRY_VERSION_FILE]: [
    TYPENAME_ARTIFACT_REGISTRY_MAVEN_VERSION_FILE,
    TYPENAME_ARTIFACT_REGISTRY_NPM_VERSION_FILE,
  ],
};

const ARTIFACT_CONNECTION_POLICY = {
  keyArgs: [],
  merge: (_, incoming) => incoming,
};

const SORTED_ARTIFACT_CONNECTION_POLICY = {
  ...ARTIFACT_CONNECTION_POLICY,
  keyArgs: ['sort'],
};

const MANIFEST_CONNECTION_POLICY = {
  ...SORTED_ARTIFACT_CONNECTION_POLICY,
  keyArgs: ['sort', 'includeReferrers'],
};

// Neither repository type carries an `id` — AR addresses a repository by name, and ADR-009
// makes the name unique within the namespace and immutable — so both key on `name`. That is
// what lets a post-update mutation patch a repository in place.
//
// Both are listed because the list and the single-repository read return unrelated schema
// types, so one repository occupies two entries. Only the list's entry is reachable from a
// mutation payload, so the detail entry is maintained by hand: `evictDeletedRepository` and
// `evictUpdatedRepositoryDetails` in graphql/utils/cache_update.js are the two places that do
// it, and a third mutation touching a repository needs the same treatment.
export const typePolicies = {
  [TYPENAME_ARTIFACT_REGISTRY_REPOSITORY]: {
    keyFields: ['name'],
  },
  [TYPENAME_ARTIFACT_REGISTRY_REPOSITORY_DETAILS]: {
    keyFields: ['name'],
    fields: {
      images: ARTIFACT_CONNECTION_POLICY,
      packages: ARTIFACT_CONNECTION_POLICY,
    },
  },
  // `versions` is only ever selected under the single-package read, which returns the detail
  // union, so the pager's page-merge policy hangs off the detail types Apollo keys the cache by.
  [TYPENAME_ARTIFACT_REGISTRY_MAVEN_PACKAGE_DETAILS]: {
    fields: {
      versions: SORTED_ARTIFACT_CONNECTION_POLICY,
    },
  },
  [TYPENAME_ARTIFACT_REGISTRY_NPM_PACKAGE_DETAILS]: {
    fields: {
      versions: SORTED_ARTIFACT_CONNECTION_POLICY,
    },
  },
  [TYPENAME_ARTIFACT_REGISTRY_IMAGE]: {
    fields: {
      manifests: MANIFEST_CONNECTION_POLICY,
    },
  },
  [TYPENAME_ARTIFACT_REGISTRY_VERSION_DETAILS]: {
    fields: {
      files: ARTIFACT_CONNECTION_POLICY,
    },
  },
  [TYPENAME_ORGANIZATION]: {
    fields: {
      // The filters and the sort are applied server-side, so each combination is a
      // distinct result rather than a view of one cached list. Without keying on them, a
      // re-sorted page overwrites the entry another one wrote.
      artifactRegistryRepositories: {
        keyArgs: ['format', 'kind', 'sort'],
      },
    },
  },
};
