// Runtime Apollo local resolvers standing in for the parts of the Artifact Registry GraphQL
// surface the schema does not carry yet, so the read and write flows are exercisable in a
// browser ahead of the backend, per doc/development/fe_guide/graphql.md ("Mocking API response
// with local Apollo cache"). The precedent for shipping a runtime mock merged is
// ee/app/assets/javascripts/cd/graphql/mock_resolvers.js.
//
// To remove once the backend ships the remaining types, reads, and mutations:
//   1. delete this file and graphql/typedefs.graphql,
//   2. drop the `mockResolvers`, `typeDefs`, and `possibleTypes` arguments in
//      repositories/index.js,
//   3. remove the remaining `@client` directives from the query documents,
//   4. delete the graphql/queries_spec.js document checks, which exist only to police the
//      `@client` split while it lasts.
import {
  REPOSITORY_KIND_REMOTE,
  TYPENAME_ARTIFACT_REGISTRY_REPOSITORY_DETAILS,
  TYPENAME_ARTIFACT_REGISTRY_VERSION_DETAILS,
  TYPENAME_ARTIFACT_REGISTRY_VERSION_STATISTICS,
} from '../constants';
import { isContainerFormat } from '../utils';
import listedVersionFragment from './fragments/listed_version.fragment.graphql';
import { manifestLadderFor, versionDetailFor, versionLadderFor } from './mock_artifacts';

const listedVersion = (cache, id) => {
  if (!cache) return null;

  return cache.readFragment({
    id: cache.identify({ __typename: 'ArtifactRegistryVersion', id }),
    fragment: listedVersionFragment,
  });
};

// Pauses before resolving, so a consuming view renders its loading state.
const delay = () =>
  new Promise((resolve) => {
    const MOCK_LATENCY_MS = 500;

    setTimeout(resolve, MOCK_LATENCY_MS);
  });

// An Artifact Registry cursor is opaque: a caller may only hand one back (ADR-009). This one
// carries the key of the row it points at, encoded rather than bare so no reader starts reading
// it as a name or an id.
export const encodeCursor = (key) => window.btoa(JSON.stringify({ key }));

// A cursor naming a row that has since gone away reads as no cursor at all, so the page fills
// from the unbounded edge rather than coming back empty.
const cursorIndex = (rows, cursor, keyOf) => {
  const index = rows.findIndex((row) => encodeCursor(keyOf(row)) === cursor);

  return index === -1 ? null : index;
};

// `after` names the last row of the page being left and `before` its first, so a forward page
// starts after the one and a backward page ends at the other.
const paginate = (rows, keyOf, listArguments) => {
  const { first, last, before, after } = listArguments ?? {};

  const afterIndex = after ? cursorIndex(rows, after, keyOf) : null;
  const beforeIndex = before ? cursorIndex(rows, before, keyOf) : null;

  const windowStart = afterIndex === null ? 0 : afterIndex + 1;
  const windowEnd = beforeIndex === null ? rows.length : beforeIndex;

  const start = last ? Math.max(windowEnd - last, windowStart) : windowStart;
  const end = first ? Math.min(start + first, windowEnd) : windowEnd;
  const nodes = rows.slice(start, end);

  return {
    nodes,
    pageInfo: {
      __typename: 'PageInfo',
      hasPreviousPage: start > 0,
      hasNextPage: end < rows.length,
      startCursor: nodes.length ? encodeCursor(keyOf(nodes[0])) : null,
      endCursor: nodes.length ? encodeCursor(keyOf(nodes.at(-1))) : null,
    },
  };
};

// Every artifact shape carries an id, while only some carry a name.
const artifactKey = ({ id }) => id;

export const byFileName = (rows) =>
  [...rows].sort((left, right) => left.fileName.localeCompare(right.fileName));

const files = async ({ storedFiles }, listArguments) => {
  await delay();

  return {
    __typename: 'ArtifactRegistryVersionFileConnection',
    ...paginate(byFileName(storedFiles ?? []), artifactKey, listArguments),
  };
};

const statistics = async ({ repositoryKind, storedFiles }) => {
  if (repositoryKind === REPOSITORY_KIND_REMOTE) return null;

  await delay();

  return {
    __typename: TYPENAME_ARTIFACT_REGISTRY_VERSION_STATISTICS,
    filesCount: (storedFiles ?? []).length,
  };
};

export const mockResolvers = {
  [TYPENAME_ARTIFACT_REGISTRY_REPOSITORY_DETAILS]: {
    version: async ({ format, kind }, { id, artifactId }, { cache } = {}) => {
      if (isContainerFormat(format)) return null;

      await delay();

      const listed = listedVersion(cache, id);

      if (listed) {
        return { ...versionDetailFor(listed, { artifactId, format }), repositoryKind: kind };
      }

      // Searching only this artifact's ladder keeps the pairing check: a URL naming one artifact
      // and another's version resolves null.
      const found = versionLadderFor(artifactId, format).find((version) => version.id === id);

      if (!found) return null;

      return { ...found, repositoryKind: kind };
    },
    manifest: async ({ format }, { digest, artifactId }) => {
      if (!isContainerFormat(format)) return null;

      await delay();

      // Scoped to this image, so a URL pairing one image with another's digest resolves null.
      const found = manifestLadderFor(artifactId).find((manifest) => manifest.digest === digest);

      if (!found) return null;

      // Copied, so a caller writing to the answer cannot reach the ladder row behind it.
      return { ...found };
    },
  },
  [TYPENAME_ARTIFACT_REGISTRY_VERSION_DETAILS]: { files, statistics },
};
