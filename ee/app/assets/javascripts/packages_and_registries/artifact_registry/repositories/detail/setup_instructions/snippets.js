import { escape } from 'lodash-es';
import { s__ } from '~/locale';
import { withoutScheme } from '../../../utils';
import {
  REPOSITORY_FORMAT_DOCKER,
  REPOSITORY_FORMAT_MAVEN,
  REPOSITORY_FORMAT_NPM,
  REPOSITORY_FORMAT_OCI,
  SETUP_SECTION_INSTALL,
  SETUP_TOOL_GRADLE_GROOVY,
  SETUP_TOOL_GRADLE_KOTLIN,
  SETUP_TOOL_PNPM,
  SETUP_TOOL_PODMAN,
  SETUP_TOOL_SBT,
  SETUP_TOOL_YARN,
} from '../../../constants';

/* eslint-disable no-template-curly-in-string */
const TOKEN_PLACEHOLDER = '${ARTIFACT_REGISTRY_TOKEN}';
const MAVEN_TOKEN_PLACEHOLDER = '${env.ARTIFACT_REGISTRY_TOKEN}';
const TOKEN_ENVIRONMENT_VARIABLE = 'ARTIFACT_REGISTRY_TOKEN';
/* eslint-enable no-template-curly-in-string */

const PLACEHOLDER_GROUP_ID = 'com.company';
const PLACEHOLDER_ARTIFACT_ID = 'app';
const PLACEHOLDER_VERSION = '1.0.0';
const PLACEHOLDER_SCOPE = 'scope';
const PLACEHOLDER_PACKAGE = '@scope/package';
const PLACEHOLDER_IMAGE_NAME = 'image';
const PLACEHOLDER_TAG = 'tag';

const YARN_BERRY_PUBLISH_VIA_NPM_PLUGIN = 'yarn npm publish';
// Artifact Registry sends this fixed realm in its Basic authentication challenge.
const SBT_CREDENTIALS_REALM = 'artifact-registry';

// ASCII alphanumerics plus the seven characters Maven, npm, semver, and OCI coordinates use. A
// Maven version range also needs '[](),', but a range is a constraint, not a published version.
const SAFE_COORDINATE = /^[A-Za-z0-9._~@/+-]+$/;

// Separate from SAFE_COORDINATE: adding a colon there would widen every coordinate's guard.
const CANONICAL_DIGEST = /^sha256:[a-f0-9]{64}$/;

const i18n = {
  repositorySetup: s__('ArtifactRegistry|Repository setup'),
  registrySetup: s__('ArtifactRegistry|Registry setup'),
  copyDependency: s__('ArtifactRegistry|Copy the dependency declaration'),
  copyInstallCommand: s__('ArtifactRegistry|Copy the install command'),
  copyPublishCommand: s__('ArtifactRegistry|Copy the publish command'),
  copyDistribution: s__('ArtifactRegistry|Copy the distribution management configuration'),
  copyRepositoryConfig: s__('ArtifactRegistry|Copy the repository configuration'),
  copyAuthConfig: s__('ArtifactRegistry|Copy the authentication configuration'),
  copyRegistryConfig: s__('ArtifactRegistry|Copy the registry configuration'),
  copyPullCommand: s__('ArtifactRegistry|Copy the pull command'),
  copyPullByTagCommand: s__('ArtifactRegistry|Copy the pull-by-tag command'),
  copyPullByDigestCommand: s__('ArtifactRegistry|Copy the pull-by-digest command'),
  copyPushCommand: s__('ArtifactRegistry|Copy the push command'),
  copySignInCommand: s__('ArtifactRegistry|Copy the sign-in command'),
  installCommand: s__('ArtifactRegistry|Install command:'),
  publishCommand: s__('ArtifactRegistry|Publish command:'),
  mavenDependency: s__(
    'ArtifactRegistry|Copy and paste this inside your %{codeStart}pom.xml%{codeEnd} %{codeStart}dependencies%{codeEnd} block:',
  ),
  mavenDistribution: s__('ArtifactRegistry|Add this to your %{codeStart}pom.xml%{codeEnd} file:'),
  mavenRepository: s__(
    "ArtifactRegistry|If you haven't already, add the configuration below to your %{codeStart}pom.xml%{codeEnd} file:",
  ),
  mavenAuthentication: s__(
    'ArtifactRegistry|Authenticate with a token in your %{codeStart}settings.xml%{codeEnd} file:',
  ),
  gradleGroovyDependency: s__(
    'ArtifactRegistry|Add the dependency to your %{codeStart}build.gradle%{codeEnd} file:',
  ),
  gradleGroovyRepository: s__(
    'ArtifactRegistry|Add the repository to your %{codeStart}build.gradle%{codeEnd} file:',
  ),
  gradleKotlinDependency: s__(
    'ArtifactRegistry|Add the dependency to your %{codeStart}build.gradle.kts%{codeEnd} file:',
  ),
  gradleKotlinRepository: s__(
    'ArtifactRegistry|Add the repository to your %{codeStart}build.gradle.kts%{codeEnd} file:',
  ),
  sbtCredentials: s__(
    'ArtifactRegistry|Add this to your %{codeStart}~/.sbt/1.0/credentials.sbt%{codeEnd} file:',
  ),
  sbtDependency: s__(
    'ArtifactRegistry|Add the dependency to your %{codeStart}build.sbt%{codeEnd} file:',
  ),
  sbtRepository: s__('ArtifactRegistry|Add this to your %{codeStart}build.sbt%{codeEnd} file:'),
  npmrc: s__('ArtifactRegistry|Add this to your %{codeStart}.npmrc%{codeEnd} file:'),
  yarnrc: s__('ArtifactRegistry|Add this to your %{codeStart}.yarnrc.yml%{codeEnd} file:'),
  pullImage: s__('ArtifactRegistry|Pull an image:'),
  pullByTag: s__('ArtifactRegistry|Pull by tag:'),
  pullByDigest: s__('ArtifactRegistry|Pull by digest:'),
  pushImage: s__('ArtifactRegistry|Push an image:'),
  signIn: s__('ArtifactRegistry|Sign in to the registry:'),
};

const hostnameOf = (url) => new URL(url).hostname;
const hostOf = (url) => new URL(url).host;

/* eslint-disable @gitlab/require-i18n-strings -- Snippet bodies are code, not interface copy. */

const gradleSections = ({
  tool,
  section,
  repositoryUrl,
  groupId = PLACEHOLDER_GROUP_ID,
  artifactId = PLACEHOLDER_ARTIFACT_ID,
  version = PLACEHOLDER_VERSION,
}) => {
  const kotlin = tool === SETUP_TOOL_GRADLE_KOTLIN;
  const coordinates = `${groupId}:${artifactId}:${version}`;

  return [
    {
      blocks: [
        section === SETUP_SECTION_INSTALL
          ? {
              text: kotlin ? i18n.gradleKotlinDependency : i18n.gradleGroovyDependency,
              code: kotlin ? `implementation("${coordinates}")` : `implementation '${coordinates}'`,
              copyText: i18n.copyDependency,
            }
          : {
              text: i18n.publishCommand,
              code: 'gradle publish',
              copyText: i18n.copyPublishCommand,
            },
      ],
    },
    {
      heading: i18n.repositorySetup,
      blocks: [
        {
          text: kotlin ? i18n.gradleKotlinRepository : i18n.gradleGroovyRepository,
          code: kotlin
            ? `maven {
  url = uri("${repositoryUrl}")
  credentials(PasswordCredentials::class) {
    username = "__token__"
    password = System.getenv("${TOKEN_ENVIRONMENT_VARIABLE}")
  }
}`
            : `maven {
  url '${repositoryUrl}'
  credentials(PasswordCredentials) {
    username = '__token__'
    password = System.getenv('${TOKEN_ENVIRONMENT_VARIABLE}')
  }
}`,
          copyText: i18n.copyRepositoryConfig,
        },
      ],
    },
  ];
};

const mavenSections = ({
  tool,
  section,
  name,
  repositoryUrl,
  groupId = PLACEHOLDER_GROUP_ID,
  artifactId = PLACEHOLDER_ARTIFACT_ID,
  version = PLACEHOLDER_VERSION,
}) => {
  if (tool === SETUP_TOOL_GRADLE_GROOVY || tool === SETUP_TOOL_GRADLE_KOTLIN) {
    return gradleSections({ tool, section, repositoryUrl, groupId, artifactId, version });
  }

  if (tool === SETUP_TOOL_SBT) {
    return [
      {
        blocks: [
          section === SETUP_SECTION_INSTALL
            ? {
                text: i18n.sbtDependency,
                code: `libraryDependencies += "${groupId}" % "${artifactId}" % "${version}"`,
                copyText: i18n.copyDependency,
              }
            : { text: i18n.publishCommand, code: 'sbt publish', copyText: i18n.copyPublishCommand },
        ],
      },
      {
        heading: i18n.repositorySetup,
        blocks: [
          {
            text: i18n.sbtRepository,
            code:
              section === SETUP_SECTION_INSTALL
                ? `resolvers += ("artifact-registry" at "${repositoryUrl}")`
                : `publishTo := Some("artifact-registry" at "${repositoryUrl}")`,
            copyText: i18n.copyRepositoryConfig,
          },
          {
            text: i18n.sbtCredentials,
            code: `credentials += Credentials("${SBT_CREDENTIALS_REALM}", "${hostnameOf(repositoryUrl)}", "__token__", sys.env.getOrElse("${TOKEN_ENVIRONMENT_VARIABLE}", ""))`,
            copyText: i18n.copyAuthConfig,
          },
        ],
      },
    ];
  }

  // The reader pastes these blocks into their own pom.xml and settings.xml, so a
  // repository name carrying an XML metacharacter would inject elements into a build
  // file rather than break a page. Artifact Registry restricts the name charset today
  // (REPOSITORY_NAME_PATTERN), which this does not take on trust.
  const xmlName = escape(name);
  const xmlUrl = escape(repositoryUrl);

  return [
    {
      blocks:
        section === SETUP_SECTION_INSTALL
          ? [
              {
                text: i18n.mavenDependency,
                // groupId, artifactId, and version already passed SAFE_COORDINATE, so these
                // escapes are unreachable; kept so all five interpolations escape the same way.
                code: `<dependency>
  <groupId>${escape(groupId)}</groupId>
  <artifactId>${escape(artifactId)}</artifactId>
  <version>${escape(version)}</version>
</dependency>`,
                copyText: i18n.copyDependency,
              },
              {
                text: i18n.installCommand,
                code: 'mvn install',
                copyText: i18n.copyInstallCommand,
              },
            ]
          : [
              {
                text: i18n.mavenDistribution,
                code: `<distributionManagement>
  <repository>
    <id>${xmlName}</id>
    <url>${xmlUrl}</url>
  </repository>
</distributionManagement>`,
                copyText: i18n.copyDistribution,
              },
              {
                text: i18n.publishCommand,
                code: 'mvn deploy',
                copyText: i18n.copyPublishCommand,
              },
            ],
    },
    {
      heading: i18n.repositorySetup,
      blocks: [
        {
          text: i18n.mavenRepository,
          code: `<repositories>
  <repository>
    <id>${xmlName}</id>
    <url>${xmlUrl}</url>
  </repository>
</repositories>`,
          copyText: i18n.copyRepositoryConfig,
        },
        {
          text: i18n.mavenAuthentication,
          code: `<server>
  <id>${xmlName}</id>
  <username>__token__</username>
  <password>${MAVEN_TOKEN_PLACEHOLDER}</password>
</server>`,
          copyText: i18n.copyAuthConfig,
        },
      ],
    },
  ];
};

const npmSections = ({
  tool,
  section,
  repositoryUrl,
  packageName = PLACEHOLDER_PACKAGE,
  version,
}) => {
  const client = { [SETUP_TOOL_YARN]: 'yarn', [SETUP_TOOL_PNPM]: 'pnpm' }[tool] ?? 'npm';
  const addCommand = client === 'npm' ? 'install' : 'add';
  // `version` takes no placeholder default: the setup drawer passes none, and pinning one there
  // would change the merged snippet it already renders.
  const installTarget = version ? `${packageName}@${version}` : packageName;
  const publishCommand =
    client === 'yarn' ? YARN_BERRY_PUBLISH_VIA_NPM_PLUGIN : `${client} publish`;

  return [
    {
      blocks: [
        section === SETUP_SECTION_INSTALL
          ? {
              text: i18n.installCommand,
              code: `${client} ${addCommand} ${installTarget}`,
              copyText: i18n.copyInstallCommand,
            }
          : {
              text: i18n.publishCommand,
              code: publishCommand,
              copyText: i18n.copyPublishCommand,
            },
      ],
    },
    {
      heading: i18n.registrySetup,
      blocks: [
        tool === SETUP_TOOL_YARN
          ? {
              text: i18n.yarnrc,
              code: `npmScopes:
  ${PLACEHOLDER_SCOPE}:
    npmRegistryServer: "${repositoryUrl}"
    npmAuthToken: "${TOKEN_PLACEHOLDER}"`,
              copyText: i18n.copyRegistryConfig,
            }
          : {
              text: i18n.npmrc,
              code: `@${PLACEHOLDER_SCOPE}:registry=${repositoryUrl}
//${withoutScheme(repositoryUrl)}/:_authToken=${TOKEN_PLACEHOLDER}`,
              copyText: i18n.copyRegistryConfig,
            },
      ],
    },
  ];
};

const containerSections = ({
  tool,
  section,
  repositoryUrl,
  imageName = PLACEHOLDER_IMAGE_NAME,
  tag,
  digest,
}) => {
  const client = tool === SETUP_TOOL_PODMAN ? 'podman' : 'docker';
  const image = `${withoutScheme(repositoryUrl)}/${imageName}`;

  const registrySetup = {
    heading: i18n.registrySetup,
    blocks: [
      {
        text: i18n.signIn,
        code: `echo "${TOKEN_PLACEHOLDER}" | ${client} login ${hostOf(repositoryUrl)} --username "__token__" --password-stdin`,
        copyText: i18n.copySignInCommand,
      },
    ],
  };

  // Install only: a push addresses a tag, never a digest.
  if (digest && section === SETUP_SECTION_INSTALL) {
    return [
      {
        blocks: [
          ...(tag
            ? [
                {
                  text: i18n.pullByTag,
                  code: `${client} pull ${image}:${tag}`,
                  copyText: i18n.copyPullByTagCommand,
                },
              ]
            : []),
          {
            text: i18n.pullByDigest,
            code: `${client} pull ${image}@${digest}`,
            copyText: i18n.copyPullByDigestCommand,
          },
        ],
      },
      registrySetup,
    ];
  }

  // Defaulting `tag` in the destructure instead would make an untagged manifest pull `image:tag`.
  const reference = `${image}:${tag ?? PLACEHOLDER_TAG}`;

  return [
    {
      blocks: [
        section === SETUP_SECTION_INSTALL
          ? {
              text: i18n.pullImage,
              code: `${client} pull ${reference}`,
              copyText: i18n.copyPullCommand,
            }
          : {
              text: i18n.pushImage,
              code: `${client} push ${reference}`,
              copyText: i18n.copyPushCommand,
            },
      ],
    },
    registrySetup,
  ];
};

/* eslint-enable @gitlab/require-i18n-strings */

const SECTION_BUILDERS = {
  [REPOSITORY_FORMAT_DOCKER]: containerSections,
  [REPOSITORY_FORMAT_OCI]: containerSections,
  [REPOSITORY_FORMAT_MAVEN]: mavenSections,
  [REPOSITORY_FORMAT_NPM]: npmSections,
};

export const setupSnippetSections = ({
  format,
  tool,
  section,
  name,
  repositoryUrl,
  groupId,
  artifactId,
  packageName,
  version,
  imageName,
  tag,
  digest,
}) => {
  const build = SECTION_BUILDERS[format];

  if (!build || !repositoryUrl || !name) return [];

  // Absent, not refused: an untagged manifest arrives as `tag: null`, and refusing it would
  // empty the whole panel. The identity coordinates below are deliberately not treated this way.
  const givenTag = tag || undefined;
  const givenDigest = digest || undefined;

  // Only undefined reaches a builder's placeholder default, and GraphQL sends null for an unset
  // field, so a non-string has to be refused rather than coerced into the charset test.
  const isSafe = (coordinate) =>
    coordinate === undefined ||
    (typeof coordinate === 'string' && SAFE_COORDINATE.test(coordinate));

  const isSafeDigest = (value) =>
    value === undefined || (typeof value === 'string' && CANONICAL_DIGEST.test(value));

  if (![groupId, artifactId, packageName, version, imageName, givenTag].every(isSafe)) return [];
  if (!isSafeDigest(givenDigest)) return [];

  return build({
    tool,
    section,
    name,
    repositoryUrl,
    groupId,
    artifactId,
    packageName,
    version,
    imageName,
    tag: givenTag,
    digest: givenDigest,
  });
};

export const installSnippetBlock = (args) =>
  setupSnippetSections({ ...args, section: SETUP_SECTION_INSTALL })[0]?.blocks?.[0] ?? null;
