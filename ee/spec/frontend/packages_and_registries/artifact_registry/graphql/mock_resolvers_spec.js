import { InMemoryCache } from '@apollo/client/core';
import { visit } from 'graphql';
import { omit } from 'lodash-es';
import { createMockClient } from 'helpers/mock_apollo_helper';
import { typePolicies as globalTypePolicies } from '~/lib/graphql';
import {
  possibleTypes,
  typePolicies as artifactRegistryTypePolicies,
} from 'ee/packages_and_registries/artifact_registry/graphql/cache_config';
import {
  manifestLadderFor,
  mockArtifacts,
  versionDetailFor,
  versionLadderFor,
} from 'ee/packages_and_registries/artifact_registry/graphql/mock_artifacts';
import {
  byFileName,
  mockResolvers,
} from 'ee/packages_and_registries/artifact_registry/graphql/mock_resolvers';
import typeDefs from 'ee/packages_and_registries/artifact_registry/graphql/typedefs.graphql';
import getArtifactQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_artifact.query.graphql';
import getRepositoryDetailQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_repository_detail.query.graphql';
import getVersionQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_version.query.graphql';
import { ORGANIZATION_GID } from '../mock_data';

const REPOSITORY_TYPENAME = 'ArtifactRegistryRepositoryDetails';

// Two names Artifact Registry serves, plus the two edges of the name contract: a single
// character, and one using every separator REPOSITORY_NAME_PATTERN admits.
const NAMES = ['oci-repository', 'maven-repository', 'a', 'x_y.z-9'];

const [NAME] = NAMES;

const ARTIFACT_ID = '019ffef0-842d-7670-b4ea-f350acb3ca56';

const CONTAINER_FORMATS = ['DOCKER', 'OCI'];

const PACKAGE_FORMATS = ['MAVEN', 'NPM'];

const MAVEN_SNAPSHOT_FILES = 25;

const declaredFields = (kinds) => {
  const fields = {};

  const collect = (node) => {
    fields[node.name.value] = (node.fields ?? []).map(({ name }) => name.value).sort();

    return false;
  };

  visit(typeDefs, Object.fromEntries(kinds.map((kind) => [kind, collect])));

  return fields;
};

const locallyDeclaredFields = () => declaredFields(['ObjectTypeDefinition', 'ObjectTypeExtension']);

// A field graphql/typedefs.graphql adds to a type the schema owns has no server backing, so a
// resolver has to answer it. A field on a wholly local type needs no resolver of its own: it is
// read off the object the resolver one level up returned.
const extendedFields = () => declaredFields(['ObjectTypeExtension']);

describe('Artifact registry mock resolvers', () => {
  // The repository parent the schema resolves: its identity and its format, nothing local.
  const serverParent = (name, format) => ({ __typename: REPOSITORY_TYPENAME, name, format });

  const readVersion = (repository, { id, artifactId }, context) =>
    mockResolvers.ArtifactRegistryRepositoryDetails.version(
      repository,
      { id, artifactId },
      context,
    );

  const readManifest = (repository, { digest, artifactId }) =>
    mockResolvers.ArtifactRegistryRepositoryDetails.manifest(repository, { digest, artifactId });

  const readFiles = (version, args) =>
    mockResolvers.ArtifactRegistryVersionDetails.files(version, args);

  const readStatistics = (version) =>
    mockResolvers.ArtifactRegistryVersionDetails.statistics(version);

  const cursorFor = ({ id }) => window.btoa(JSON.stringify({ key: id }));

  beforeEach(() => {
    // The resolvers' delay is scheduled asynchronously, so advancing Jest's timers cannot
    // reach it; collapsing it keeps these assertions about behavior rather than timing.
    jest.spyOn(global, 'setTimeout').mockImplementation((callback) => callback());
  });

  describe('the fields the local layer still answers', () => {
    // Fields answered locally that the schema also declares, so `typedefs.graphql` cannot
    // declare them: redeclaring a field the schema owns fails the Apollo schema build.
    const LOCALLY_ANSWERED_SCHEMA_FIELDS = {
      // The schema owns `version` now, but the version detail read still selects it `@client`, so
      // the local layer keeps serving it until a later step binds that document to the schema.
      [REPOSITORY_TYPENAME]: ['version'],
      // The schema owns the `files` connection now, but the version detail read still selects it
      // `@client` on the detail type, so the local layer keeps serving it until a later step
      // binds that document.
      ArtifactRegistryVersionDetails: ['files'],
    };

    // Fields the `version` resolver already puts on the object it returns, so they are read
    // straight off that object and need no resolver of their own on the version types.
    const PARENT_ANSWERED_FIELDS = {
      ArtifactRegistryVersion: ['gitCommitSha', 'npmMetadata'],
      ArtifactRegistryVersionDetails: ['gitCommitSha', 'npmMetadata'],
    };

    const allowedFor = (typename) => [
      ...(locallyDeclaredFields()[typename] ?? []),
      ...(LOCALLY_ANSWERED_SCHEMA_FIELDS[typename] ?? []),
    ];

    // A resolver standing over a field the schema resolves would override the server for every
    // read selecting it.
    it.each(Object.keys(mockResolvers))(
      'answers no %s field beyond the ones graphql/typedefs.graphql declares',
      (typename) => {
        const allowed = allowedFor(typename);

        expect(
          Object.keys(mockResolvers[typename]).filter((field) => !allowed.includes(field)),
        ).toEqual([]);
      },
    );

    it.each(Object.keys(extendedFields()))(
      'answers every field graphql/typedefs.graphql adds to the schema’s %s',
      (typename) => {
        const answeredHere = [
          ...extendedFields()[typename],
          ...(LOCALLY_ANSWERED_SCHEMA_FIELDS[typename] ?? []),
        ].filter((field) => !(PARENT_ANSWERED_FIELDS[typename] ?? []).includes(field));

        expect(Object.keys(mockResolvers[typename] ?? {}).sort()).toEqual(answeredHere.sort());
      },
    );
  });

  describe('the single-manifest read', () => {
    const imageOf = (name, format, index = 0) => mockArtifacts(name, format)[index];

    const indexManifestOf = (image) =>
      manifestLadderFor(image.id).find(({ children }) => children.length > 0);

    const referrerOf = (image) =>
      manifestLadderFor(image.id).find(({ subjectDigest }) => subjectDigest);

    it.each(CONTAINER_FORMATS)('resolves a manifest of a %s repository', async (format) => {
      const image = imageOf(NAME, format);
      const manifest = indexManifestOf(image);

      expect(
        await readManifest(serverParent(NAME, format), {
          digest: manifest.digest,
          artifactId: image.id,
        }),
      ).toEqual(manifest);
    });

    // The schema owns `ArtifactRegistryManifest` and serves the connection under it, so the
    // detail has to answer under a name of its own or the two would collide in the cache.
    it('answers under the local detail typename', async () => {
      const image = imageOf(NAME, 'DOCKER');
      const manifest = indexManifestOf(image);

      const { __typename: typename } = await readManifest(serverParent(NAME, 'DOCKER'), {
        digest: manifest.digest,
        artifactId: image.id,
      });

      expect(typename).toBe('ArtifactRegistryManifestDetails');
    });

    it.each(PACKAGE_FORMATS)(
      'resolves null for a %s repository without looking a manifest up at all',
      async (format) => {
        expect(
          await readManifest(serverParent(NAME, format), {
            digest: 'any-digest',
            artifactId: 'any-image-id',
          }),
        ).toBe(null);
        expect(setTimeout).not.toHaveBeenCalled();
      },
    );

    it('resolves a referrer, which the default list does not show', async () => {
      const image = imageOf(NAME, 'DOCKER');
      const referrer = referrerOf(image);

      const resolved = await readManifest(serverParent(NAME, 'DOCKER'), {
        digest: referrer.digest,
        artifactId: image.id,
      });

      expect(resolved.subjectDigest).toBe(referrer.subjectDigest);
    });

    it('resolves null for a digest this image does not hold', async () => {
      const image = imageOf(NAME, 'DOCKER');

      expect(
        await readManifest(serverParent(NAME, 'DOCKER'), {
          digest: `sha256:${'0'.repeat(64)}`,
          artifactId: image.id,
        }),
      ).toBe(null);
    });

    it('resolves null for a digest another image of the same repository holds', async () => {
      const [image, other] = mockArtifacts(NAME, 'DOCKER');
      const foreign = indexManifestOf(other);

      expect(foreign.digest).not.toBe(indexManifestOf(image).digest);
      expect(
        await readManifest(serverParent(NAME, 'DOCKER'), {
          digest: foreign.digest,
          artifactId: image.id,
        }),
      ).toBe(null);
    });

    it('hands back a copy, so a caller cannot write through to the next read', async () => {
      const image = imageOf(NAME, 'DOCKER');
      const manifest = indexManifestOf(image);
      const args = { digest: manifest.digest, artifactId: image.id };

      const resolved = await readManifest(serverParent(NAME, 'DOCKER'), args);
      resolved.digest = 'rewritten';

      // Must re-read through the resolver: a fresh `manifestLadderFor` build is pristine
      // whatever the resolver handed out, so comparing against one cannot fail.
      expect((await readManifest(serverParent(NAME, 'DOCKER'), args)).digest).toBe(manifest.digest);
    });
  });

  describe('the single-version read', () => {
    const ladderOf = (name, format, index = 0) => mockArtifacts(name, format)[index];

    it.each(PACKAGE_FORMATS)('resolves a version of a %s repository', async (format) => {
      const artifact = ladderOf(NAME, format);
      const [version] = versionLadderFor(artifact.id, format);

      expect(
        await readVersion(serverParent(NAME, format), {
          id: version.id,
          artifactId: artifact.id,
        }),
      ).toEqual({ ...version, __typename: 'ArtifactRegistryVersionDetails' });
    });

    it.each(CONTAINER_FORMATS)(
      'resolves null for a %s repository without looking a version up at all',
      async (format) => {
        expect(
          await readVersion(serverParent(NAME, format), {
            id: 'any-version-id',
            artifactId: 'any-artifact-id',
          }),
        ).toBe(null);
        expect(setTimeout).not.toHaveBeenCalled();
      },
    );

    it('reaches the lookup for a package repository, so the guard above is the format', async () => {
      await readVersion(serverParent(NAME, 'MAVEN'), {
        id: 'any-version-id',
        artifactId: 'any-artifact-id',
      });

      expect(setTimeout).toHaveBeenCalled();
    });

    it('resolves null when no artifact carries the given id', async () => {
      const artifact = ladderOf(NAME, 'MAVEN');
      const [version] = versionLadderFor(artifact.id);

      expect(
        await readVersion(serverParent(NAME, 'MAVEN'), {
          id: version.id,
          artifactId: 'no-such-artifact-id',
        }),
      ).toBe(null);
    });

    it('resolves null when the artifact holds no version under that id', async () => {
      const artifact = ladderOf(NAME, 'MAVEN');

      expect(
        await readVersion(serverParent(NAME, 'MAVEN'), {
          id: 'no-such-version-id',
          artifactId: artifact.id,
        }),
      ).toBe(null);
    });

    it('resolves null for a version belonging to another artifact of the same repository', async () => {
      const [first, second] = [ladderOf(NAME, 'MAVEN', 0), ladderOf(NAME, 'MAVEN', 1)];
      const [versionOfSecond] = versionLadderFor(second.id);

      expect(
        await readVersion(serverParent(NAME, 'MAVEN'), {
          id: versionOfSecond.id,
          artifactId: first.id,
        }),
      ).toBe(null);
    });

    it('ladders from the artifact id alone, so the repository the read names does not scope it', async () => {
      const artifact = ladderOf('maven-repository', 'MAVEN');
      const [version] = versionLadderFor(artifact.id);

      expect(
        await readVersion(serverParent('a', 'MAVEN'), {
          id: version.id,
          artifactId: artifact.id,
        }),
      ).toMatchObject({ id: version.id, __typename: 'ArtifactRegistryVersionDetails' });
    });

    it('resolves a version a caller cannot write the next read through', async () => {
      const artifact = ladderOf(NAME, 'MAVEN');
      const [version] = versionLadderFor(artifact.id, 'MAVEN');
      const args = { id: version.id, artifactId: artifact.id };

      const resolved = await readVersion(serverParent(NAME, 'MAVEN'), args);
      resolved.version = 'Edited by the caller';

      expect((await readVersion(serverParent(NAME, 'MAVEN'), args)).version).toBe(version.version);
    });
  });

  describe('the single-version read, for a version the schema listed', () => {
    const LISTED_ID = '01a07f75-ec2a-7341-8570-637fb14eab6d';

    const listed = {
      __typename: 'ArtifactRegistryVersion',
      id: LISTED_ID,
      version: '2.0.0-SNAPSHOT',
      createdAt: '2026-09-08T05:20:00Z',
      createdBy: null,
      project: null,
      gitCommitSha: 'f19ac02a8d3b41e57c9f0a4d2b8e6135ac97d40e',
      distTags: [],
      sizeBytes: '4096',
    };

    const cacheHolding = ({ gitCommitSha, ...entity }) =>
      new InMemoryCache().restore({
        [`ArtifactRegistryVersion:${entity.id}`]: { ...entity, commitSha: gitCommitSha },
      });

    const listedRead = (format, cache = cacheHolding(listed)) =>
      readVersion(
        { ...serverParent(NAME, format), kind: 'HOSTED' },
        { id: LISTED_ID, artifactId: ARTIFACT_ID },
        { cache },
      );

    const detailOf = (format) => ({
      ...versionDetailFor(listed, { artifactId: ARTIFACT_ID, format }),
      repositoryKind: 'HOSTED',
    });

    it.each(PACKAGE_FORMATS)(
      'answers the listed %s version off the cache, with the detail layered on',
      async (format) => {
        expect(await listedRead(format)).toEqual(detailOf(format));
      },
    );

    it('keeps the version string and the commit the list rendered', async () => {
      expect(await listedRead('MAVEN')).toMatchObject({
        __typename: 'ArtifactRegistryVersionDetails',
        id: LISTED_ID,
        version: '2.0.0-SNAPSHOT',
        gitCommitSha: listed.gitCommitSha,
      });
    });

    it('reads no partial entity off the cache', async () => {
      const { createdBy, project, ...partial } = listed;

      expect(await listedRead('MAVEN', cacheHolding(partial))).toBe(null);
    });

    it('answers the ladder when the cache holds no such version', async () => {
      const [artifact] = mockArtifacts(NAME, 'MAVEN');
      const [version] = versionLadderFor(artifact.id, 'MAVEN');

      expect(
        await readVersion(
          serverParent(NAME, 'MAVEN'),
          { id: version.id, artifactId: artifact.id },
          { cache: new InMemoryCache() },
        ),
      ).toEqual(version);
    });

    it('answers null when neither the cache nor the ladder holds the id', async () => {
      expect(await listedRead('MAVEN', new InMemoryCache())).toBe(null);
    });
  });

  describe('the files connection', () => {
    const versionAt = ({ name = NAME, format, position, repository = {} }) => {
      const artifact = mockArtifacts(name, format)[0];
      const version = versionLadderFor(artifact.id, format)[position];

      return readVersion(
        { ...serverParent(name, format), ...repository },
        { id: version.id, artifactId: artifact.id },
      );
    };

    it.each(PACKAGE_FORMATS)('resolves a %s version’s files by name ascending', async (format) => {
      const { nodes } = await readFiles(await versionAt({ format, position: 0 }));
      const names = nodes.map(({ fileName }) => fileName);

      expect(names.length).toBeGreaterThan(0);
      expect(names).toEqual([...names].sort((left, right) => left.localeCompare(right)));
    });

    it.each(PACKAGE_FORMATS)(
      'resolves an empty connection for a fileless %s version',
      async (format) => {
        const { nodes, pageInfo } = await readFiles(await versionAt({ format, position: 1 }));

        expect(nodes).toEqual([]);
        expect(pageInfo).toEqual(
          expect.objectContaining({ hasNextPage: false, hasPreviousPage: false }),
        );
      },
    );

    it('cuts a Maven snapshot’s files to the page asked for, and offers the next', async () => {
      const PAGE = 5;
      const { nodes, pageInfo } = await readFiles(
        await versionAt({ format: 'MAVEN', position: 0 }),
        {
          first: PAGE,
        },
      );

      expect(nodes).toHaveLength(PAGE);
      expect(pageInfo.hasNextPage).toBe(true);
    });

    it('walks forward and back to the page it started on', async () => {
      const PAGE = 5;
      const snapshot = await versionAt({ format: 'MAVEN', position: 0 });

      const first = await readFiles(snapshot, { first: PAGE });
      const second = await readFiles(snapshot, { first: PAGE, after: first.pageInfo.endCursor });
      const back = await readFiles(snapshot, { last: PAGE, before: second.pageInfo.startCursor });

      expect(second.nodes.map(({ id }) => id)).not.toEqual(first.nodes.map(({ id }) => id));
      expect(back.nodes.map(({ id }) => id)).toEqual(first.nodes.map(({ id }) => id));
      expect(back.pageInfo.hasPreviousPage).toBe(false);
    });

    describe('the statistics beside it', () => {
      it('counts the version’s files rather than a page of them', async () => {
        const PAGE = 5;
        const version = await versionAt({ format: 'MAVEN', position: 0 });
        const { nodes } = await readFiles(version, { first: PAGE });

        expect(nodes).toHaveLength(PAGE);
        expect(await readStatistics(version)).toEqual({
          __typename: 'ArtifactRegistryVersionStatistics',
          filesCount: MAVEN_SNAPSHOT_FILES,
        });
      });

      it('resolves null on a remote repository', async () => {
        const version = await versionAt({
          format: 'MAVEN',
          position: 0,
          repository: { kind: 'REMOTE' },
        });

        expect(await readStatistics(version)).toBe(null);
      });
    });
  });

  describe('the paging arguments', () => {
    const idsOf = ({ nodes }) => nodes.map(({ id }) => id);

    const snapshot = () => {
      const artifact = mockArtifacts(NAME, 'MAVEN')[0];
      const [version] = versionLadderFor(artifact.id, 'MAVEN');

      return readVersion(serverParent(NAME, 'MAVEN'), { id: version.id, artifactId: artifact.id });
    };

    const rows = async () => byFileName((await snapshot()).storedFiles);

    const page = async (pageArguments) => readFiles(await snapshot(), pageArguments);

    it('answers the whole set when the caller asks for no page', async () => {
      expect(idsOf(await page())).toEqual((await rows()).map(({ id }) => id));
    });

    it('answers the leading rows for a forward page with no cursor', async () => {
      const [first, second] = await rows();

      expect(idsOf(await page({ first: 2 }))).toEqual([first.id, second.id]);
    });

    it('resumes after the row the forward cursor names', async () => {
      const [first, second, third] = await rows();

      expect(idsOf(await page({ first: 2, after: cursorFor(first) }))).toEqual([
        second.id,
        third.id,
      ]);
    });

    it('stops before the row the backward cursor names', async () => {
      const [first, second, third] = await rows();

      expect(idsOf(await page({ last: 2, before: cursorFor(third) }))).toEqual([
        first.id,
        second.id,
      ]);
    });

    it('pages from the unbounded edge when the cursor names no row it holds', async () => {
      const [first, second] = await rows();

      expect(idsOf(await page({ first: 2, after: cursorFor({ id: 'gone' }) }))).toEqual([
        first.id,
        second.id,
      ]);
    });

    it('reports the cursors of the rows the page holds', async () => {
      const [first, second] = await rows();

      expect((await page({ first: 2 })).pageInfo).toEqual({
        __typename: 'PageInfo',
        hasPreviousPage: false,
        hasNextPage: true,
        startCursor: cursorFor(first),
        endCursor: cursorFor(second),
      });
    });

    it('reports no next page on the last page', async () => {
      const ladder = await rows();
      const { pageInfo } = await page({ first: ladder.length, after: cursorFor(ladder[0]) });

      expect(pageInfo).toMatchObject({ hasPreviousPage: true, hasNextPage: false });
    });
  });

  // Calling the resolvers directly says nothing about which parent each one is handed, or how
  // its result merges onto the server's, so these examples compose the map with a client and
  // the app's own documents.
  describe('composed with the query documents into an Apollo client', () => {
    const SERVER_FORMAT = 'NPM';

    const serverRepository = (name, overrides = {}) => ({
      __typename: REPOSITORY_TYPENAME,
      name,
      format: SERVER_FORMAT,
      kind: 'HOSTED',
      visibility: 'PRIVATE',
      description: 'Resolved by the schema',
      artifactsCount: '3',
      downloadsCount: '17',
      sizeBytes: '4096',
      createdAt: '2026-06-01T00:00:00Z',
      lastUpdatedAt: '2026-07-02T00:00:00Z',
      createdBy: null,
      updatedBy: null,
      settings: null,
      ...overrides,
    });

    const organizationResponse = (repository) => ({
      data: {
        organization: {
          __typename: 'Organization',
          id: ORGANIZATION_GID,
          artifactRegistryRepository: repository,
        },
      },
    });

    const repositoryHandler = (repository) => jest.fn(() => organizationResponse(repository));

    const createClient = (handlers) =>
      createMockClient(handlers, mockResolvers, {
        possibleTypes,
        typePolicies: { ...globalTypePolicies, ...artifactRegistryTypePolicies },
      });

    const read = (client, query, variables) =>
      client
        .query({ query, variables: { organizationId: ORGANIZATION_GID, ...variables } })
        .then(({ data }) => data.organization.artifactRegistryRepository);

    describe('the detail read, whose repository the schema resolves', () => {
      const detailRead = (name) =>
        read(
          createClient([[getRepositoryDetailQuery, repositoryHandler(serverRepository(name))]]),
          getRepositoryDetailQuery,
          { name },
        );

      it.each(NAMES)('answers with the schema’s repository whole for %s', async (name) => {
        expect(await detailRead(name)).toEqual(serverRepository(name));
      });
    });

    // graphql/cache_config.js keys the repository on its name, so both reads write one entity
    // between them, with one artifact field per id on it. Both taking the format from the schema
    // keeps the type written under an id and the type read back against it one type.
    describe('the version read, whose repository and package the schema resolves', () => {
      const serverPackage = (id) => ({
        __typename: 'ArtifactRegistryNpmPackageDetails',
        id,
        name: 'listed',
        scope: null,
      });

      const versionRead = (name, artifactId, versionId) =>
        read(
          createClient([
            [
              getVersionQuery,
              repositoryHandler(serverRepository(name, { package: serverPackage(artifactId) })),
            ],
          ]),
          getVersionQuery,
          { name, artifactId, versionId },
        );

      const firstVersionOf = (name) => {
        const [artifact] = mockArtifacts(name, SERVER_FORMAT);

        return { artifact, version: versionLadderFor(artifact.id, SERVER_FORMAT)[0] };
      };

      it.each(NAMES)(
        'answers the version %s generates, under the detail typename',
        async (name) => {
          const { artifact, version } = firstVersionOf(name);
          const repository = await versionRead(name, artifact.id, version.id);

          expect(repository.version).toEqual({
            ...omit(version, ['distTags', 'storedFiles']),
            __typename: 'ArtifactRegistryVersionDetails',
            statistics: {
              __typename: 'ArtifactRegistryVersionStatistics',
              filesCount: version.storedFiles.length,
            },
          });
        },
      );

      it('answers the package the schema resolves beside it, which is what names the artifact', async () => {
        const { artifact, version } = firstVersionOf(NAME);
        const repository = await versionRead(NAME, artifact.id, version.id);

        expect(repository.package).toEqual(
          expect.objectContaining({
            id: artifact.id,
            __typename: 'ArtifactRegistryNpmPackageDetails',
          }),
        );
      });

      it('answers a null version for a version of another artifact of the same repository', async () => {
        const { artifact } = firstVersionOf(NAME);
        const [, other] = mockArtifacts(NAME, SERVER_FORMAT);
        const otherVersion = versionLadderFor(other.id)[0];
        const repository = await versionRead(NAME, artifact.id, otherVersion.id);

        expect(repository.version).toBe(null);
        expect(repository.package).toEqual(expect.objectContaining({ id: artifact.id }));
      });

      it.each(CONTAINER_FORMATS)(
        'answers a null version and a null package for a %s repository, which this page does not serve',
        async (format) => {
          const client = createClient([
            [getVersionQuery, repositoryHandler(serverRepository(NAME, { format, package: null }))],
          ]);
          const repository = await read(client, getVersionQuery, {
            name: NAME,
            artifactId: mockArtifacts(NAME, format)[0].id,
            versionId: 'any-version-id',
          });

          expect(repository).toEqual({
            __typename: REPOSITORY_TYPENAME,
            name: NAME,
            format,
            kind: 'HOSTED',
            package: null,
            version: null,
          });
        },
      );

      it('carries the kind the sidebar reads through from the schema', async () => {
        const { artifact, version } = firstVersionOf(NAME);

        expect(await versionRead(NAME, artifact.id, version.id)).toEqual(
          expect.objectContaining({ kind: 'HOSTED', format: SERVER_FORMAT }),
        );
      });
    });

    describe('the artifact read and the detail read, against one repository', () => {
      // NAME says OCI while the schema resolves Maven, so an answer drawn from anywhere but the
      // schema reads as the wrong artifact type in the cache.
      const RESOLVED_FORMAT = 'MAVEN';

      const ARTIFACT = mockArtifacts(NAME, RESOLVED_FORMAT)[0];

      const ARTIFACT_PARENT = {
        ...serverParent(NAME, RESOLVED_FORMAT),
        image: null,
        package: { ...ARTIFACT, __typename: 'ArtifactRegistryMavenPackageDetails' },
      };

      const variables = { organizationId: ORGANIZATION_GID, name: NAME };

      // The artifact read runs first, which is the order a viewer opening an artifact URL in a
      // fresh tab produces.
      const readArtifactThenDetail = async () => {
        const client = createClient([
          [
            getRepositoryDetailQuery,
            repositoryHandler(serverRepository(NAME, { format: RESOLVED_FORMAT })),
          ],
          [getArtifactQuery, repositoryHandler(ARTIFACT_PARENT)],
        ]);

        await client.query({
          query: getArtifactQuery,
          variables: { ...variables, artifactId: ARTIFACT.id },
        });
        await client.query({ query: getRepositoryDetailQuery, variables });

        return client;
      };

      it('leaves one artifact entity under an id, of the type the format decides', async () => {
        const client = await readArtifactThenDetail();

        expect(
          Object.keys(client.cache.extract()).filter((key) => key.endsWith(`:${ARTIFACT.id}`)),
        ).toEqual([`ArtifactRegistryMavenPackageDetails:${ARTIFACT.id}`]);
      });

      // The cache field key follows the arguments the document names, so an artifact id passed
      // here as well would give this read a field of its own, holding a format no other read
      // could correct.
      it('writes the repository under the field key the detail read writes it under', async () => {
        const client = await readArtifactThenDetail();
        const organization = client.cache.extract()[`Organization:${ORGANIZATION_GID}`];

        expect(
          Object.keys(organization).filter((key) => key.startsWith('artifactRegistryRepository')),
        ).toEqual([`artifactRegistryRepository({"name":"${NAME}"})`]);
      });
    });
  });
});
