import createMockApollo from 'helpers/mock_apollo_helper';
import { typePolicies as globalTypePolicies } from '~/lib/graphql';
import {
  CLIENT_BASE_URL,
  ORGANIZATION_GID,
  SLUG,
  mockArtifactRepository,
  mockRepository,
  mockRepositoryResponse,
} from 'ee_jest/packages_and_registries/artifact_registry/mock_data';
import {
  possibleTypes,
  typePolicies as artifactRegistryTypePolicies,
} from '../../../graphql/cache_config';
import { mockArtifacts, versionLadderFor } from '../../../graphql/mock_artifacts';
import { byFileName, encodeCursor, mockResolvers } from '../../../graphql/mock_resolvers';
import getVersionQuery from '../../../graphql/queries/get_version.query.graphql';
import getVersionFilesQuery from '../../../graphql/queries/get_version_files.query.graphql';
import {
  GRAPHQL_PAGE_SIZE,
  TYPENAME_ARTIFACT_REGISTRY_MAVEN_PACKAGE_DETAILS,
  TYPENAME_ARTIFACT_REGISTRY_NPM_PACKAGE_DETAILS,
} from '../../../constants';
import { createRouter } from '../../../router';
import VersionDetail from './version_detail.vue';

const BASE_PATH = '/o/gitlab-org/-/artifact_registry/acme/repositories';

const generatedArtifact = (format) => mockArtifacts(mockRepository.name, format)[0];

// The single-package read returns the detail union, so the package spread on
// `... on ArtifactRegistry*PackageDetails` needs the detail typename; the generator stamps the
// plain one the `packages` list returns.
const asDetailPackage = (format, artifact) => ({
  ...artifact,
  __typename:
    format === 'NPM'
      ? TYPENAME_ARTIFACT_REGISTRY_NPM_PACKAGE_DETAILS
      : TYPENAME_ARTIFACT_REGISTRY_MAVEN_PACKAGE_DETAILS,
});

const repositoryHandler =
  (format, kind = 'HOSTED') =>
  ({ artifactId }) => {
    const artifact = generatedArtifact(format);
    const held = artifactId === artifact.id;

    return Promise.resolve(
      mockRepositoryResponse(
        mockArtifactRepository(format, {
          kind,
          package: held ? asDetailPackage(format, artifact) : null,
        }),
      ),
    );
  };

const generatedVersion = (format, position = 0) =>
  versionLadderFor(generatedArtifact(format).id)[position];

// The Maven ladder holds 25 files against a page size of 20, so a cursor over its last
// first-page row opens the last page: Previous is live and Next is disabled.
const secondFilePageCursor = (format) => {
  const files = versionLadderFor(generatedArtifact(format).id, format)[0].storedFiles ?? [];
  const lastOnFirstPage = byFileName(files)[GRAPHQL_PAGE_SIZE - 1];

  // The resolver reads a cursor naming no row as no cursor, so without this the story would
  // quietly render page one instead of failing.
  if (!lastOnFirstPage) {
    throw new Error(`The ${format} file ladder no longer fills a page, so it has no second page.`);
  }

  return encodeCursor(lastOnFirstPage.id);
};

export default {
  component: VersionDetail,
  title: 'ee/artifact_registry/repositories/versions/detail/version_detail',
};

const Template =
  ({
    format = 'MAVEN',
    handler = repositoryHandler(format),
    artifactId = generatedArtifact(format).id,
    versionId = generatedVersion(format).id,
    query = {},
    versionResolver = mockResolvers.ArtifactRegistryRepositoryDetails.version,
  } = {}) =>
  () => {
    const router = createRouter(BASE_PATH);
    router.push({ path: `/${mockRepository.name}/${artifactId}/versions/${versionId}`, query });

    return {
      components: { VersionDetail },
      router,
      apolloProvider: createMockApollo(
        [
          [getVersionQuery, handler],
          [getVersionFilesQuery, handler],
        ],
        {
          ArtifactRegistryRepositoryDetails: { version: versionResolver },
          ArtifactRegistryVersionDetails: mockResolvers.ArtifactRegistryVersionDetails,
        },
        {
          possibleTypes,
          typePolicies: { ...globalTypePolicies, ...artifactRegistryTypePolicies },
        },
      ),
      provide: {
        breadCrumbState: {
          artifactName: '',
          versionName: '',
          updateArtifactName() {},
          updateVersionName() {},
        },
        organizationGid: ORGANIZATION_GID,
        slug: SLUG,
        clientBaseUrl: CLIENT_BASE_URL,
      },
      template: '<version-detail />',
    };
  };

export const Default = Template();

export const NpmVersion = Template({ format: 'NPM' });

export const NpmVersionWithDescription = Template({
  format: 'NPM',
  versionId: generatedVersion('NPM', 1).id,
});

export const RemoteRepository = Template({ handler: repositoryHandler('MAVEN', 'REMOTE') });

export const MavenFilesTab = Template({ query: { tab: 'files' } });

export const NpmFileTab = Template({ format: 'NPM', query: { tab: 'files' } });

export const MavenFilesTabSecondPage = Template({
  query: { tab: 'files', after: secondFilePageCursor('MAVEN') },
});

export const MavenFilesTabEmpty = Template({
  versionId: generatedVersion('MAVEN', 1).id,
  query: { tab: 'files' },
});

export const NpmFileTabEmpty = Template({
  format: 'NPM',
  versionId: generatedVersion('NPM', 1).id,
  query: { tab: 'files' },
});

export const Loading = Template({ handler: () => new Promise(() => {}) });

export const ServiceUnavailable = Template({
  handler: () => Promise.reject(new Error('Unavailable')),
});

export const NotFound = Template({
  handler: () => Promise.resolve(mockRepositoryResponse(null)),
});

export const ArtifactNotFound = Template({ artifactId: 'unheld-artifact-id' });

export const VersionNotFound = Template({ versionId: 'unheld-version-id' });

export const VersionOfAnotherArtifact = Template({
  versionId: versionLadderFor(mockArtifacts(mockRepository.name, 'MAVEN')[1].id)[0].id,
});
