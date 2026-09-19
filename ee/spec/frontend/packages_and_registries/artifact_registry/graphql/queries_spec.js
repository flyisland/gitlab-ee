import { removeClientSetsFromDocument } from '@apollo/client/utilities';
import { visit } from 'graphql';
import getManifestQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_manifest.query.graphql';
import getRepositoriesQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_repositories.query.graphql';
import getRepositoryQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_repository.query.graphql';
import getRepositoryDetailQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_repository_detail.query.graphql';
import getRepositoryImagesQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_repository_images.query.graphql';
import getRepositoryPackagesQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_repository_packages.query.graphql';
import getVersionQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_version.query.graphql';
import getVersionFilesQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_version_files.query.graphql';

// A variable left declared but unused is rejected by the endpoint, and nothing before the
// request catches it: the source document does use the variable, so schema validation passes.
const unusedVariablesInServerDocument = (document) => {
  const serverDocument = removeClientSetsFromDocument(document);

  if (!serverDocument) return [];

  const referenced = new Set();

  visit(serverDocument, {
    VariableDefinition: () => false,
    Variable: ({ name }) => {
      referenced.add(name.value);
    },
  });

  return serverDocument.definitions
    .flatMap(({ variableDefinitions = [] }) => variableDefinitions)
    .map(({ variable }) => variable.name.value)
    .filter((name) => !referenced.has(name));
};

const variableNames = (document) =>
  document.definitions
    .flatMap(({ variableDefinitions = [] }) => variableDefinitions)
    .map(({ variable }) => variable.name.value);

// The top-level field names a repository selection carries, without descending into it.
const fieldsUnder = (document, fieldName) => {
  const fields = [];

  visit(document, {
    Field: ({ name, selectionSet }) => {
      if (name.value !== fieldName) return undefined;

      fields.push(...selectionSet.selections.map((selection) => selection.name.value));

      return false;
    },
  });

  return fields;
};

const repositoryFields = (document) => {
  const fields = [];

  if (!document) return fields;

  visit(document, {
    Field: ({ name, selectionSet }) => {
      if (name.value !== 'artifactRegistryRepository') return undefined;

      fields.push(...selectionSet.selections.map((selection) => selection.name.value));

      return false;
    },
  });

  return fields;
};

describe('Artifact registry query documents', () => {
  describe.each([
    ['getArtifactRegistryManifest', getManifestQuery],
    ['getArtifactRegistryRepositories', getRepositoriesQuery],
    ['getArtifactRegistryRepository', getRepositoryQuery],
    ['getArtifactRegistryRepositoryDetail', getRepositoryDetailQuery],
    ['getArtifactRegistryRepositoryImages', getRepositoryImagesQuery],
    ['getArtifactRegistryRepositoryPackages', getRepositoryPackagesQuery],
    ['getArtifactRegistryVersion', getVersionQuery],
    ['getArtifactRegistryVersionFiles', getVersionFilesQuery],
  ])('%s, with its client fields stripped as Apollo strips them', (_name, document) => {
    it('leaves behind no variable the server rejects as declared but not used', () => {
      expect(unusedVariablesInServerDocument(document)).toEqual([]);
    });
  });

  describe('getArtifactRegistryRepositoryDetail', () => {
    it('sends every field it renders, so the read is the schema’s answer whole', () => {
      expect(repositoryFields(removeClientSetsFromDocument(getRepositoryDetailQuery))).toEqual([
        'name',
        'format',
        'kind',
        'visibility',
        'description',
        'artifactsCount',
        'downloadsCount',
        'sizeBytes',
        'createdAt',
        'lastUpdatedAt',
        'createdBy',
        'updatedBy',
        'settings',
      ]);
    });
  });

  describe.each([
    ['getArtifactRegistryRepositoryImages', getRepositoryImagesQuery, 'images'],
    ['getArtifactRegistryRepositoryPackages', getRepositoryPackagesQuery, 'packages'],
  ])('%s', (_name, document, connection) => {
    it('asks the server for the connection itself, so the page it renders is the schema’s', () => {
      expect(repositoryFields(removeClientSetsFromDocument(document))).toEqual([
        'name',
        'format',
        connection,
      ]);
    });

    it('declares every paging variable to the server, so a cursor reaches Artifact Registry', () => {
      expect(variableNames(removeClientSetsFromDocument(document))).toEqual([
        'organizationId',
        'name',
        'first',
        'last',
        'before',
        'after',
      ]);
    });
  });

  describe('getArtifactRegistryVersion', () => {
    it('asks the server for the repository, its kind, and the package the version hangs off', () => {
      expect(repositoryFields(removeClientSetsFromDocument(getVersionQuery))).toEqual([
        'name',
        'format',
        'kind',
        'package',
      ]);
    });

    it('keeps back the version alone', () => {
      expect(repositoryFields(getVersionQuery)).toEqual([
        'name',
        'format',
        'kind',
        'package',
        'version',
      ]);
    });

    it('declares the identity variables and the artifact id, leaving no version id behind', () => {
      expect(variableNames(removeClientSetsFromDocument(getVersionQuery))).toEqual([
        'organizationId',
        'name',
        'artifactId',
      ]);
    });
  });

  describe('getArtifactRegistryManifest', () => {
    it('asks the server for the repository identity, the format, the kind, and the image', () => {
      expect(repositoryFields(removeClientSetsFromDocument(getManifestQuery))).toEqual([
        'name',
        'format',
        'kind',
        'image',
      ]);
    });

    it('keeps back the manifest alone, which the schema does not serve yet', () => {
      expect(repositoryFields(getManifestQuery)).toEqual([
        'name',
        'format',
        'kind',
        'image',
        'manifest',
      ]);
    });

    it('selects the two fields that tell a referrer from an image', () => {
      expect(fieldsUnder(getManifestQuery, 'manifest')).toEqual(
        expect.arrayContaining(['artifactType', 'subjectDigest']),
      );
    });

    it('leaves the digest behind with the client field, keeping the image id', () => {
      expect(variableNames(removeClientSetsFromDocument(getManifestQuery))).toEqual([
        'organizationId',
        'name',
        'artifactId',
      ]);
    });
  });

  describe('getArtifactRegistryVersionFiles', () => {
    it('declares the identity variables alone, leaving no id or page size behind', () => {
      expect(variableNames(removeClientSetsFromDocument(getVersionFilesQuery))).toEqual([
        'organizationId',
        'name',
      ]);
    });
  });

  describe('getArtifactRegistryRepositoryByName', () => {
    it('asks the server for every field the form prefills from', () => {
      const fields = ['name', 'format', 'kind', 'visibility', 'description', 'settings'];

      expect(repositoryFields(removeClientSetsFromDocument(getRepositoryQuery))).toEqual(fields);
      expect(repositoryFields(getRepositoryQuery)).toEqual(fields);
    });
  });
});
