import { InMemoryCache } from '@apollo/client/core';
import {
  possibleTypes,
  typePolicies,
} from 'ee/packages_and_registries/artifact_registry/graphql/cache_config';
import getArtifactManifestsQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_artifact_manifests.query.graphql';
import getArtifactVersionsQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_artifact_versions.query.graphql';
import getVersionFilesQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_version_files.query.graphql';
import getRepositoryImagesQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_repository_images.query.graphql';
import { ARTIFACT_SORT_DEFAULT } from 'ee/packages_and_registries/artifact_registry/constants';
import {
  ARTIFACT_ID_FOR,
  FIRST_PAGE_END_CURSOR,
  ORGANIZATION_GID,
  mockFirstFilePage,
  mockFirstImagePage,
  mockFirstManifestPage,
  mockFirstVersionPage,
  mockSecondFilePage,
  mockSecondImagePage,
  mockSecondManifestPage,
  mockSecondVersionPage,
  mockUntouchedRepository,
  mockVersionDetails,
} from '../mock_data';

describe('Artifact registry cache config', () => {
  describe('the artifact connection policies', () => {
    let cache;

    // A container repository, because `images` is the connection a container format reads.
    const { name, format } = mockUntouchedRepository;

    const variablesFor = (after) => ({
      organizationId: ORGANIZATION_GID,
      name,
      first: 20,
      after,
    });

    const dataFor = (images) => ({
      organization: {
        __typename: 'Organization',
        id: ORGANIZATION_GID,
        artifactRegistryRepository: {
          __typename: 'ArtifactRegistryRepositoryDetails',
          name,
          format,
          images,
        },
      },
    });

    const writePage = (images, after) =>
      cache.writeQuery({
        query: getRepositoryImagesQuery,
        variables: variablesFor(after),
        data: dataFor(images),
      });

    const readPage = (after) =>
      cache.readQuery({ query: getRepositoryImagesQuery, variables: variablesFor(after) })
        .organization.artifactRegistryRepository.images;

    beforeEach(() => {
      cache = new InMemoryCache({ possibleTypes, typePolicies });
    });

    beforeEach(() => {
      writePage(mockFirstImagePage);
      writePage(mockSecondImagePage, FIRST_PAGE_END_CURSOR);
    });

    it('holds every cursor under one entry the incoming page replaces', () => {
      expect(readPage().nodes).toEqual(mockSecondImagePage.nodes);
    });

    it('replaces the page info with it, so the pager follows the rows', () => {
      expect(readPage().pageInfo).toEqual(mockSecondImagePage.pageInfo);
    });
  });

  describe('the files connection policy', () => {
    let cache;

    const { name } = mockUntouchedRepository;
    const versionId = mockVersionDetails().id;

    const variablesFor = (after) => ({
      organizationId: ORGANIZATION_GID,
      name,
      artifactId: ARTIFACT_ID_FOR.MAVEN,
      versionId,
      first: 20,
      after,
    });

    const dataFor = (page) => ({
      organization: {
        __typename: 'Organization',
        id: ORGANIZATION_GID,
        artifactRegistryRepository: {
          __typename: 'ArtifactRegistryRepositoryDetails',
          name,
          format: 'MAVEN',
          kind: 'HOSTED',
          version: {
            __typename: 'ArtifactRegistryVersionDetails',
            id: versionId,
            files: page,
          },
        },
      },
    });

    const writePage = (page, after) =>
      cache.writeQuery({
        query: getVersionFilesQuery,
        variables: variablesFor(after),
        data: dataFor(page),
      });

    const readPage = (after) =>
      cache.readQuery({ query: getVersionFilesQuery, variables: variablesFor(after) }).organization
        .artifactRegistryRepository.version.files;

    beforeEach(() => {
      cache = new InMemoryCache({ possibleTypes, typePolicies });

      writePage(mockFirstFilePage);
      writePage(mockSecondFilePage, FIRST_PAGE_END_CURSOR);
    });

    // Compared by id so the assertion does not depend on which fields this document selects.
    it('holds every cursor under one entry the incoming page replaces', () => {
      expect(readPage().nodes.map(({ id }) => id)).toEqual(
        mockSecondFilePage.nodes.map(({ id }) => id),
      );
    });

    it('replaces the page info with it, so the pager follows the rows', () => {
      expect(readPage().pageInfo).toEqual(mockSecondFilePage.pageInfo);
    });
  });

  describe.each([
    {
      connection: 'versions',
      artifactField: 'package',
      artifactTypename: 'ArtifactRegistryMavenPackageDetails',
      document: getArtifactVersionsQuery,
      format: 'MAVEN',
      artifactId: ARTIFACT_ID_FOR.MAVEN,
      firstPage: mockFirstVersionPage,
      secondPage: mockSecondVersionPage,
    },
    {
      connection: 'manifests',
      artifactField: 'image',
      artifactTypename: 'ArtifactRegistryImage',
      document: getArtifactManifestsQuery,
      format: 'DOCKER',
      artifactId: ARTIFACT_ID_FOR.DOCKER,
      firstPage: mockFirstManifestPage,
      secondPage: mockSecondManifestPage,
    },
  ])(
    'the $connection connection policy',
    ({
      connection,
      artifactField,
      artifactTypename,
      document,
      format,
      artifactId,
      firstPage,
      secondPage,
    }) => {
      let cache;

      const { name } = mockUntouchedRepository;

      const variablesFor = (after, sort = ARTIFACT_SORT_DEFAULT) => ({
        organizationId: ORGANIZATION_GID,
        name,
        artifactId,
        sort,
        first: 20,
        after,
      });

      const dataFor = (page) => ({
        organization: {
          __typename: 'Organization',
          id: ORGANIZATION_GID,
          artifactRegistryRepository: {
            __typename: 'ArtifactRegistryRepositoryDetails',
            name,
            format,
            [artifactField]: {
              __typename: artifactTypename,
              id: artifactId,
              [connection]: page,
            },
          },
        },
      });

      const writePage = (page, after, sort) =>
        cache.writeQuery({
          query: document,
          variables: variablesFor(after, sort),
          data: dataFor(page),
        });

      const readPage = (after, sort) =>
        cache.readQuery({ query: document, variables: variablesFor(after, sort) }).organization
          .artifactRegistryRepository[artifactField][connection];

      beforeEach(() => {
        cache = new InMemoryCache({ possibleTypes, typePolicies });

        writePage(firstPage);
        writePage(secondPage, FIRST_PAGE_END_CURSOR);
      });

      it('holds every cursor under one entry the incoming page replaces', () => {
        expect(readPage().nodes).toEqual(secondPage.nodes);
      });

      it('replaces the page info with it, so the pager follows the rows', () => {
        expect(readPage().pageInfo).toEqual(secondPage.pageInfo);
      });

      // The sort is applied server-side, so each ordering is a distinct result rather than a
      // view of one cached list.
      it('holds a differently sorted page under its own entry', () => {
        writePage(firstPage, undefined, 'CREATED_AT_ASC');

        expect(readPage(undefined, 'CREATED_AT_ASC').nodes).toEqual(firstPage.nodes);
        expect(readPage().nodes).toEqual(secondPage.nodes);
      });

      it('reads no page for a sort nothing has been written under', () => {
        expect(
          cache.readQuery({
            query: document,
            variables: variablesFor(undefined, 'CREATED_AT_ASC'),
          }),
        ).toBe(null);
      });
    },
  );

  describe('the manifests connection policy and the referrer argument', () => {
    let cache;

    const { name } = mockUntouchedRepository;
    const artifactId = ARTIFACT_ID_FOR.DOCKER;

    const variablesFor = (includeReferrers) => ({
      organizationId: ORGANIZATION_GID,
      name,
      artifactId,
      sort: ARTIFACT_SORT_DEFAULT,
      includeReferrers,
      first: 20,
    });

    const dataFor = (page) => ({
      organization: {
        __typename: 'Organization',
        id: ORGANIZATION_GID,
        artifactRegistryRepository: {
          __typename: 'ArtifactRegistryRepositoryDetails',
          name,
          format: 'DOCKER',
          image: {
            __typename: 'ArtifactRegistryImage',
            id: artifactId,
            manifests: page,
          },
        },
      },
    });

    const writePage = (page, includeReferrers) =>
      cache.writeQuery({
        query: getArtifactManifestsQuery,
        variables: variablesFor(includeReferrers),
        data: dataFor(page),
      });

    const readPage = (includeReferrers) =>
      cache.readQuery({
        query: getArtifactManifestsQuery,
        variables: variablesFor(includeReferrers),
      })?.organization.artifactRegistryRepository.image.manifests;

    beforeEach(() => {
      cache = new InMemoryCache({ possibleTypes, typePolicies });
    });

    it('holds each referrer inclusion under its own entry', () => {
      writePage(mockFirstManifestPage, true);
      writePage(mockSecondManifestPage, false);

      expect(readPage(true).nodes).toEqual(mockFirstManifestPage.nodes);
      expect(readPage(false).nodes).toEqual(mockSecondManifestPage.nodes);
    });

    it('reads no page for an inclusion nothing has been written under', () => {
      writePage(mockFirstManifestPage, true);

      expect(readPage(false)).toBeUndefined();
    });

    it('leaves the versions policy keyed on the sort alone', () => {
      expect(typePolicies.ArtifactRegistryMavenPackageDetails.fields.versions.keyArgs).toEqual([
        'sort',
      ]);
      expect(typePolicies.ArtifactRegistryImage.fields.manifests.keyArgs).toEqual([
        'sort',
        'includeReferrers',
      ]);
    });
  });
});
