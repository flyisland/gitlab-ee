import {
  REPOSITORY_FORMAT_VALUES,
  SETUP_SECTION_INSTALL,
  SETUP_SECTION_PUBLISH,
  SETUP_TOOLS,
} from 'ee/packages_and_registries/artifact_registry/constants';
import {
  installSnippetBlock,
  setupSnippetSections,
} from 'ee/packages_and_registries/artifact_registry/repositories/detail/setup_instructions/snippets';
import { buildRepositoryClientUrl } from 'ee/packages_and_registries/artifact_registry/utils';
import { CLIENT_BASE_URL, SLUG } from '../../../mock_data';

const NAME = 'my-repository';
const SECTIONS = [SETUP_SECTION_INSTALL, SETUP_SECTION_PUBLISH];
const DIGEST = `sha256:${'a1b2c3d4'.repeat(8)}`;
/* eslint-disable no-template-curly-in-string -- The snippets display a shell-style placeholder. */
const MAVEN_TOKEN_PLACEHOLDER = '${env.ARTIFACT_REGISTRY_TOKEN}';
/* eslint-enable no-template-curly-in-string */

const urlFor = (format) =>
  buildRepositoryClientUrl({ clientBaseUrl: CLIENT_BASE_URL, slug: SLUG, format, name: NAME });

const build = ({ format, tool, section }) =>
  setupSnippetSections({ format, tool, section, name: NAME, repositoryUrl: urlFor(format) });

const codeOf = (sections) =>
  sections.flatMap(({ blocks }) => blocks.map(({ code }) => code).filter(Boolean));

// Every format, tool, and section the selector can put on screen.
const everyCombination = REPOSITORY_FORMAT_VALUES.flatMap((format) =>
  SETUP_TOOLS[format].flatMap(({ value: tool }) =>
    SECTIONS.map((section) => [format, tool, section]),
  ),
);

describe('setupSnippetSections', () => {
  describe('what a format, tool, and section produce', () => {
    it.each(everyCombination)(
      'gives a %s repository on %s a %s section with at least one command',
      (format, tool, section) => {
        expect(codeOf(build({ format, tool, section }))).not.toHaveLength(0);
      },
    );

    it.each(everyCombination)(
      'follows the %s / %s / %s content with a setup section a client needs to reach the repository',
      (format, tool, section) => {
        const sections = build({ format, tool, section });

        expect(sections).toHaveLength(2);
        expect(sections[1].heading).toEqual(expect.any(String));
      },
    );

    it('reads the repository name back in the Maven coordinates that identify the repository', () => {
      const [, setup] = build({
        format: 'MAVEN',
        tool: 'maven',
        section: SETUP_SECTION_PUBLISH,
      });

      expect(setup.blocks[0].code).toContain(`<id>${NAME}</id>`);
    });
  });

  describe('the repository URL every snippet is composed on', () => {
    it.each(everyCombination)(
      'addresses this repository, not a placeholder, for %s on %s (%s)',
      (format, tool, section) => {
        const url = urlFor(format);
        const address = url;
        const withUrl = codeOf(build({ format, tool, section })).filter(
          (code) => code.includes(address) || code.includes(address.replace('https://', '')),
        );

        expect(withUrl).not.toHaveLength(0);
      },
    );

    it('strips the scheme where a container reference cannot carry one', () => {
      const [pull] = codeOf(
        build({ format: 'DOCKER', tool: 'docker', section: SETUP_SECTION_INSTALL }),
      );

      expect(pull).toBe(
        'docker pull artifact-registry.example.com/acme/container/my-repository/image:tag',
      );
    });

    it.each(['docker', 'podman'])('signs %s in against the registry host and port', (tool) => {
      const [, signIn] = codeOf(
        setupSnippetSections({
          format: 'OCI',
          tool,
          section: SETUP_SECTION_INSTALL,
          name: NAME,
          repositoryUrl: 'https://artifact-registry.example.com:8443/acme/container/my-repository',
        }),
      );

      expect(signIn).toContain(`${tool} login artifact-registry.example.com:8443 --username`);
    });

    it('uses a port-free registry host for sbt credentials', () => {
      const snippets = setupSnippetSections({
        format: 'MAVEN',
        tool: 'sbt',
        section: SETUP_SECTION_INSTALL,
        name: NAME,
        repositoryUrl: 'https://artifact-registry.example.com:8443/acme/maven/my-repository',
      });

      expect(codeOf(snippets).join('\n')).toContain(
        'Credentials("artifact-registry", "artifact-registry.example.com", "__token__"',
      );
    });
  });

  describe('switching the build tool', () => {
    it.each(REPOSITORY_FORMAT_VALUES)(
      'gives a %s repository different commands for each of its tools',
      (format) => {
        const perTool = SETUP_TOOLS[format].map(({ value: tool }) =>
          JSON.stringify(codeOf(build({ format, tool, section: SETUP_SECTION_PUBLISH }))),
        );

        expect(new Set(perTool).size).toBe(perTool.length);
      },
    );

    it('offers Gradle its own DSL rather than repeating the Maven command', () => {
      const groovy = codeOf(
        build({ format: 'MAVEN', tool: 'gradle_groovy', section: SETUP_SECTION_PUBLISH }),
      );
      const kotlin = codeOf(
        build({ format: 'MAVEN', tool: 'gradle_kotlin', section: SETUP_SECTION_PUBLISH }),
      );

      expect(groovy).toContain('gradle publish');
      expect(kotlin).toContain('gradle publish');
      expect(groovy.join()).not.toContain('mvn');
    });

    it.each([SETUP_SECTION_INSTALL, SETUP_SECTION_PUBLISH])(
      'varies only the DSL between the Gradle tools in %s, never the Gradle install',
      (section) => {
        const forTool = (tool) => codeOf(build({ format: 'MAVEN', tool, section }));

        expect(forTool('gradle_groovy').join()).not.toContain('./gradlew');
        expect(forTool('gradle_kotlin').join()).not.toContain('./gradlew');
      },
    );

    it('publishes yarn through the Berry npm plugin, not the Classic `yarn publish`', () => {
      const [publish, registry] = codeOf(
        build({ format: 'NPM', tool: 'yarn', section: SETUP_SECTION_PUBLISH }),
      );

      expect(publish).toBe('yarn npm publish');
      expect(registry).toContain('npmScopes:');
    });
  });

  describe('credentials', () => {
    it.each(everyCombination)(
      'names a token placeholder rather than carrying a credential for %s on %s (%s)',
      (format, tool, section) => {
        const body = codeOf(build({ format, tool, section })).join('\n');

        expect(body).not.toMatch(/glpat-|--password[= ](?!-stdin)|-p\s+\S|Bearer\s/);
      },
    );

    it.each(everyCombination)(
      'names the exchanged Artifact Registry token wherever %s on %s (%s) authenticates',
      (format, tool, section) => {
        const body = codeOf(build({ format, tool, section })).join('\n');

        expect(body).toContain('ARTIFACT_REGISTRY_TOKEN');
      },
    );

    it.each`
      tool     | credentials
      ${'maven'} | ${`<username>__token__</username>
  <password>${MAVEN_TOKEN_PLACEHOLDER}</password>`}
      ${'gradle_groovy'} | ${`credentials(PasswordCredentials) {
    username = '__token__'
    password = System.getenv('ARTIFACT_REGISTRY_TOKEN')
  }`}
      ${'gradle_kotlin'} | ${`credentials(PasswordCredentials::class) {
    username = "__token__"
    password = System.getenv("ARTIFACT_REGISTRY_TOKEN")
  }`}
      ${'sbt'} | ${`credentials += Credentials("artifact-registry", "artifact-registry.example.com", "__token__", sys.env.getOrElse("ARTIFACT_REGISTRY_TOKEN", ""))`}
    `('configures $tool with Basic credentials', ({ tool, credentials }) => {
      const snippets = codeOf(build({ format: 'MAVEN', tool, section: SETUP_SECTION_INSTALL }));
      const body = snippets.join('\n');

      expect(body).toContain(credentials);
    });

    it.each`
      section                  | configuration
      ${SETUP_SECTION_INSTALL} | ${'resolvers += ("artifact-registry" at "https://artifact-registry.example.com/acme/maven/my-repository")'}
      ${SETUP_SECTION_PUBLISH} | ${'publishTo := Some("artifact-registry" at "https://artifact-registry.example.com/acme/maven/my-repository")'}
    `('configures the sbt repository for $section', ({ section, configuration }) => {
      const body = codeOf(build({ format: 'MAVEN', tool: 'sbt', section })).join('\n');

      expect(body).toContain(configuration);
    });

    it.each(['maven', 'gradle_groovy', 'gradle_kotlin'])(
      'does not configure unsupported HTTP header authentication for %s',
      (tool) => {
        const body = codeOf(build({ format: 'MAVEN', tool, section: SETUP_SECTION_INSTALL })).join(
          '\n',
        );

        expect(body).not.toContain('Private-Token');
        expect(body).not.toContain('HttpHeaderCredentials');
        expect(body).not.toContain('authentication {');
      },
    );

    it('uses the Basic-auth username in the Docker login command', () => {
      const body = codeOf(
        build({ format: 'DOCKER', tool: 'docker', section: SETUP_SECTION_INSTALL }),
      ).join('\n');

      expect(body).toContain('--username "__token__"');
    });
  });

  describe('a repository name carrying XML metacharacters', () => {
    const HOSTILE = 'a</id><url>https://evil.example/</url><id>b';

    const hostileSections = (section) =>
      setupSnippetSections({
        format: 'MAVEN',
        tool: 'maven',
        section,
        name: HOSTILE,
        repositoryUrl: urlFor('MAVEN'),
      });

    it.each(SECTIONS)('opens no new element anywhere in the %s XML', (section) => {
      const xml = codeOf(hostileSections(section)).filter((code) => code.startsWith('<'));

      expect(xml).not.toHaveLength(0);
      xml.forEach((code) => expect(code).not.toContain('<url>https://evil.example/</url>'));
    });

    it.each(SECTIONS)('escapes the name where %s embeds it', (section) => {
      const withName = codeOf(hostileSections(section)).filter((code) => code.includes('<id>'));

      expect(withName).not.toHaveLength(0);
      withName.forEach((code) => expect(code).toContain('&lt;url&gt;'));
    });

    it.each(SECTIONS)('keeps one id element per repository block in %s', (section) => {
      codeOf(hostileSections(section))
        .filter((code) => code.includes('<id>'))
        .forEach((code) => {
          expect(code.match(/<id>/g)).toHaveLength(1);
        });
    });
  });

  describe('when no artifact coordinates are given', () => {
    it('leaves the Maven dependency on the module placeholders', () => {
      const [dependency] = codeOf(
        build({ format: 'MAVEN', tool: 'maven', section: SETUP_SECTION_INSTALL }),
      );

      expect(dependency).toBe(`<dependency>
  <groupId>com.company</groupId>
  <artifactId>app</artifactId>
  <version>1.0.0</version>
</dependency>`);
    });

    it.each(['gradle_groovy', 'gradle_kotlin'])(
      'leaves the %s dependency on the module placeholders',
      (tool) => {
        const [dependency] = codeOf(
          build({ format: 'MAVEN', tool, section: SETUP_SECTION_INSTALL }),
        );

        expect(dependency).toContain('com.company:app:1.0.0');
      },
    );

    it.each`
      tool      | command
      ${'npm'}  | ${'npm install @scope/package'}
      ${'yarn'} | ${'yarn add @scope/package'}
      ${'pnpm'} | ${'pnpm add @scope/package'}
    `('pins no version onto the $tool install command', ({ tool, command }) => {
      const [install] = codeOf(build({ format: 'NPM', tool, section: SETUP_SECTION_INSTALL }));

      expect(install).toBe(command);
    });
  });

  describe('when a version names its own coordinates', () => {
    const MAVEN_COORDINATES = {
      groupId: 'com.company.payment',
      artifactId: 'core',
      version: '2.4.1',
    };
    const NPM_COORDINATES = { packageName: '@company/design-system', version: '4.2.0' };

    const buildFor = ({ format, tool, coordinates }) =>
      setupSnippetSections({
        format,
        tool,
        section: SETUP_SECTION_INSTALL,
        name: NAME,
        repositoryUrl: urlFor(format),
        ...coordinates,
      });

    it('reads them back in the Maven dependency', () => {
      const [dependency] = codeOf(
        buildFor({ format: 'MAVEN', tool: 'maven', coordinates: MAVEN_COORDINATES }),
      );

      expect(dependency).toBe(`<dependency>
  <groupId>com.company.payment</groupId>
  <artifactId>core</artifactId>
  <version>2.4.1</version>
</dependency>`);
    });

    it.each`
      tool               | declaration
      ${'gradle_groovy'} | ${"implementation 'com.company.payment:core:2.4.1'"}
      ${'gradle_kotlin'} | ${'implementation("com.company.payment:core:2.4.1")'}
    `('reads them back in the $tool declaration', ({ tool, declaration }) => {
      const [dependency] = codeOf(
        buildFor({ format: 'MAVEN', tool, coordinates: MAVEN_COORDINATES }),
      );

      expect(dependency).toBe(declaration);
    });

    it.each`
      tool      | command
      ${'npm'}  | ${'npm install @company/design-system@4.2.0'}
      ${'yarn'} | ${'yarn add @company/design-system@4.2.0'}
      ${'pnpm'} | ${'pnpm add @company/design-system@4.2.0'}
    `('pins the version onto the $tool install command', ({ tool, command }) => {
      const [install] = codeOf(buildFor({ format: 'NPM', tool, coordinates: NPM_COORDINATES }));

      expect(install).toBe(command);
    });

    it('names the package without a version when the version is absent', () => {
      const [install] = codeOf(
        buildFor({
          format: 'NPM',
          tool: 'npm',
          coordinates: { packageName: '@company/design-system' },
        }),
      );

      expect(install).toBe('npm install @company/design-system');
    });

    it('leaves the publish section alone, which names the repository rather than an artifact', () => {
      const withCoordinates = setupSnippetSections({
        format: 'MAVEN',
        tool: 'maven',
        section: SETUP_SECTION_PUBLISH,
        name: NAME,
        repositoryUrl: urlFor('MAVEN'),
        ...MAVEN_COORDINATES,
      });

      expect(withCoordinates).toStrictEqual(
        build({ format: 'MAVEN', tool: 'maven', section: SETUP_SECTION_PUBLISH }),
      );
    });
  });

  describe('when a manifest names its own image and reference', () => {
    const IMAGE = { imageName: 'payment-service', tag: 'trixie', digest: DIGEST };

    const buildContainer = ({ format = 'DOCKER', tool = 'docker', ...rest } = {}) =>
      setupSnippetSections({
        format,
        tool,
        section: SETUP_SECTION_INSTALL,
        name: NAME,
        repositoryUrl: urlFor(format),
        ...rest,
      });

    const host = (format) => urlFor(format).replace(/^https?:\/\//, '');

    it.each(['DOCKER', 'OCI'])('pulls by tag and then by digest on %s', (format) => {
      expect(codeOf(buildContainer({ format, ...IMAGE }))).toEqual([
        `docker pull ${host(format)}/payment-service:trixie`,
        `docker pull ${host(format)}/payment-service@${DIGEST}`,
        expect.stringContaining('docker login'),
      ]);
    });

    it('drops the by-tag command for an untagged manifest rather than pulling the placeholder', () => {
      const [pull] = buildContainer({ imageName: 'payment-service', digest: DIGEST });

      expect(pull.blocks).toHaveLength(1);
      expect(pull.blocks[0].code).toBe(`docker pull ${host('DOCKER')}/payment-service@${DIGEST}`);
    });

    it('labels the pair so a reader can tell the two references apart', () => {
      const [pull] = buildContainer(IMAGE);

      expect(pull.blocks.map(({ text }) => text)).toEqual(['Pull by tag:', 'Pull by digest:']);
    });

    it('names each copy button for the reference it copies, not just the pair', () => {
      const [pull] = buildContainer(IMAGE);

      expect(pull.blocks.map(({ copyText }) => copyText)).toEqual([
        'Copy the pull-by-tag command',
        'Copy the pull-by-digest command',
      ]);
    });

    it('carries the selected client through to both commands', () => {
      expect(codeOf(buildContainer({ tool: 'podman', ...IMAGE }))).toEqual([
        `podman pull ${host('DOCKER')}/payment-service:trixie`,
        `podman pull ${host('DOCKER')}/payment-service@${DIGEST}`,
        expect.stringContaining('podman login'),
      ]);
    });

    it('keeps the single placeholder command when an image is named without a digest', () => {
      const [pull] = codeOf(buildContainer({ imageName: 'payment-service' }));

      expect(pull).toBe(`docker pull ${host('DOCKER')}/payment-service:tag`);
    });

    it('pushes by tag on the publish section, never by digest', () => {
      const [push] = codeOf(buildContainer({ ...IMAGE, section: SETUP_SECTION_PUBLISH }));

      expect(push).toBe(`docker push ${host('DOCKER')}/payment-service:trixie`);
    });

    describe.each([null, undefined, ''])('with a tag given as %p', (tag) => {
      it('drops the by-tag command and keeps the rest of the panel, sign-in block included', () => {
        expect(
          codeOf(buildContainer({ imageName: 'payment-service', tag, digest: DIGEST })),
        ).toEqual([
          `docker pull ${host('DOCKER')}/payment-service@${DIGEST}`,
          expect.stringContaining('docker login'),
        ]);
      });
    });

    describe.each([null, undefined, ''])('with a digest given as %p', (digest) => {
      it('falls back to the single by-tag command rather than emptying the panel', () => {
        expect(
          codeOf(buildContainer({ imageName: 'payment-service', tag: 'trixie', digest })),
        ).toEqual([
          `docker pull ${host('DOCKER')}/payment-service:trixie`,
          expect.stringContaining('docker login'),
        ]);
      });
    });
  });

  describe('a manifest reference no registry could serve', () => {
    const buildContainer = (rest) =>
      setupSnippetSections({
        format: 'DOCKER',
        tool: 'docker',
        section: SETUP_SECTION_INSTALL,
        name: NAME,
        repositoryUrl: urlFor('DOCKER'),
        ...rest,
      });

    it.each`
      case                   | digest
      ${'uppercase hex'}     | ${`sha256:${'A1B2C3D4'.repeat(8)}`}
      ${'another algorithm'} | ${`sha512:${'a1b2c3d4'.repeat(8)}`}
      ${'a truncated hex'}   | ${'sha256:a1b2c3d4'}
      ${'no algorithm'}      | ${'a1b2c3d4'.repeat(8)}
      ${'a shell payload'}   | ${`sha256:${'a1b2c3d4'.repeat(8)}; rm -rf /`}
      ${'a non-string'}      | ${42}
    `('yields no sections for $case', ({ digest }) => {
      expect(buildContainer({ imageName: 'payment-service', digest })).toEqual([]);
    });

    it.each(['imageName', 'tag'])('yields no sections for a hostile %s', (field) => {
      expect(buildContainer({ [field]: 'a; rm -rf /', digest: DIGEST })).toEqual([]);
    });
  });

  describe('a coordinate no artifact could carry', () => {
    const HOSTILE = {
      xml: 'a</groupId><evil>x</evil><groupId>b',
      groovyQuote: "1.0'; System.exit(0); '",
      kotlinQuote: '1.0"); System.exit(0); ("',
      kotlinTemplate: '1.0-$buildDir',
      backslash: 'a\\b',
      shell: 'pkg; rm -rf /',
      space: 'com.company app',
    };

    const buildWith = (coordinates, { format = 'MAVEN', tool = 'maven' } = {}) =>
      setupSnippetSections({
        format,
        tool,
        section: SETUP_SECTION_INSTALL,
        name: NAME,
        repositoryUrl: urlFor(format),
        ...coordinates,
      });

    it.each(Object.entries(HOSTILE))('yields no sections for a groupId carrying %s', (_, value) => {
      expect(buildWith({ groupId: value })).toEqual([]);
    });

    it.each(['artifactId', 'version'])('yields no sections for a hostile %s', (field) => {
      expect(buildWith({ [field]: HOSTILE.xml })).toEqual([]);
    });

    it('yields no sections for a hostile npm package name', () => {
      expect(buildWith({ packageName: HOSTILE.shell }, { format: 'NPM', tool: 'npm' })).toEqual([]);
    });

    it.each(['maven', 'gradle_groovy', 'gradle_kotlin'])(
      'refuses it on %s, so no tool renders it',
      (tool) => {
        expect(buildWith({ version: HOSTILE.groovyQuote }, { tool })).toEqual([]);
      },
    );

    it('refuses an empty coordinate rather than composing a hole into the snippet', () => {
      expect(buildWith({ artifactId: '' })).toEqual([]);
    });

    it.each([
      ['null, which GraphQL sends for an unset field', null],
      ['a number', 2.4],
      ['a boolean', false],
    ])('refuses a version that is %s rather than falling back to the placeholder', (_, value) => {
      expect(buildWith({ version: value })).toEqual([]);
    });

    it('refuses a null npm package name', () => {
      expect(buildWith({ packageName: null }, { format: 'NPM', tool: 'npm' })).toEqual([]);
    });
  });

  describe('a coordinate a real artifact can hold', () => {
    const buildWith = (coordinates, { format = 'MAVEN', tool = 'maven' } = {}) =>
      codeOf(
        setupSnippetSections({
          format,
          tool,
          section: SETUP_SECTION_INSTALL,
          name: NAME,
          repositoryUrl: urlFor(format),
          ...coordinates,
        }),
      );

    it.each([
      [
        'a dotted group',
        { groupId: 'com.company.payment' },
        `<dependency>
  <groupId>com.company.payment</groupId>
  <artifactId>app</artifactId>
  <version>1.0.0</version>
</dependency>`,
      ],
      [
        'a hyphenated artifact',
        { artifactId: 'core-api' },
        `<dependency>
  <groupId>com.company</groupId>
  <artifactId>core-api</artifactId>
  <version>1.0.0</version>
</dependency>`,
      ],
      [
        'an underscored artifact',
        { artifactId: 'core_api' },
        `<dependency>
  <groupId>com.company</groupId>
  <artifactId>core_api</artifactId>
  <version>1.0.0</version>
</dependency>`,
      ],
      [
        'a prerelease version',
        { version: '2.4.1-rc.1' },
        `<dependency>
  <groupId>com.company</groupId>
  <artifactId>app</artifactId>
  <version>2.4.1-rc.1</version>
</dependency>`,
      ],
      [
        'a build-metadata version',
        { version: '2.4.1+build.7' },
        `<dependency>
  <groupId>com.company</groupId>
  <artifactId>app</artifactId>
  <version>2.4.1+build.7</version>
</dependency>`,
      ],
      [
        'a SNAPSHOT version',
        { version: '2.4.1-SNAPSHOT' },
        `<dependency>
  <groupId>com.company</groupId>
  <artifactId>app</artifactId>
  <version>2.4.1-SNAPSHOT</version>
</dependency>`,
      ],
    ])('composes the Maven dependency for %s', (_, coordinates, dependency) => {
      const [actual] = buildWith(coordinates);

      expect(actual).toBe(dependency);
    });

    it('composes the npm install command for a scoped package', () => {
      const [install] = buildWith(
        { packageName: '@company/design-system', version: '4.2.0' },
        { format: 'NPM', tool: 'npm' },
      );

      expect(install).toBe('npm install @company/design-system@4.2.0');
    });
  });

  describe('when the guidance cannot be composed', () => {
    it('yields no sections without a repository URL, rather than guidance with a hole in it', () => {
      expect(
        setupSnippetSections({
          format: 'MAVEN',
          tool: 'maven',
          section: SETUP_SECTION_INSTALL,
          name: NAME,
          repositoryUrl: null,
        }),
      ).toEqual([]);
    });

    it('yields no sections without a repository name', () => {
      expect(
        setupSnippetSections({
          format: 'MAVEN',
          tool: 'maven',
          section: SETUP_SECTION_INSTALL,
          name: '',
          repositoryUrl: urlFor('MAVEN'),
        }),
      ).toEqual([]);
    });

    it('yields no sections for a format it carries no guidance for', () => {
      expect(
        setupSnippetSections({
          format: 'CONAN',
          tool: 'conan',
          section: SETUP_SECTION_INSTALL,
          name: NAME,
          repositoryUrl: urlFor('MAVEN'),
        }),
      ).toEqual([]);
    });

    it.each`
      format      | tool        | field
      ${'MAVEN'}  | ${'maven'}  | ${'groupId'}
      ${'MAVEN'}  | ${'maven'}  | ${'artifactId'}
      ${'MAVEN'}  | ${'maven'}  | ${'version'}
      ${'NPM'}    | ${'npm'}    | ${'packageName'}
      ${'DOCKER'} | ${'docker'} | ${'imageName'}
    `('yields no sections for a null $field on $format', ({ format, tool, field }) => {
      expect(
        setupSnippetSections({
          format,
          tool,
          section: SETUP_SECTION_INSTALL,
          name: NAME,
          repositoryUrl: urlFor(format),
          [field]: null,
        }),
      ).toEqual([]);
    });
  });
});

describe('installSnippetBlock', () => {
  const MAVEN_COORDINATES = {
    groupId: 'com.company.payment',
    artifactId: 'core',
    version: '2.4.1',
  };

  const NPM_COORDINATES = { packageName: '@company/design-system', version: '4.2.0' };

  const blockFor = ({ format, tool, ...coordinates }) =>
    installSnippetBlock({
      format,
      tool,
      name: NAME,
      repositoryUrl: urlFor(format),
      ...coordinates,
    });

  const INSTALL_TOOLS = ['MAVEN', 'NPM'].flatMap((format) =>
    SETUP_TOOLS[format].map(({ value: tool }) => [format, tool]),
  );

  it.each(INSTALL_TOOLS)(
    'gives a %s repository on %s the first block of its install section',
    (format, tool) => {
      const [section] = setupSnippetSections({
        format,
        tool,
        section: SETUP_SECTION_INSTALL,
        name: NAME,
        repositoryUrl: urlFor(format),
      });

      expect(blockFor({ format, tool })).toStrictEqual(section.blocks[0]);
    },
  );

  it('gives the Maven dependency declaration, not the command that follows it', () => {
    expect(blockFor({ format: 'MAVEN', tool: 'maven', ...MAVEN_COORDINATES }).code)
      .toBe(`<dependency>
  <groupId>com.company.payment</groupId>
  <artifactId>core</artifactId>
  <version>2.4.1</version>
</dependency>`);
  });

  it('gives the npm install command, not the publish command that follows it', () => {
    expect(blockFor({ format: 'NPM', tool: 'npm', ...NPM_COORDINATES }).code).toBe(
      'npm install @company/design-system@4.2.0',
    );
  });

  it('gives a digest-addressed container its by-tag command, the first of the pair', () => {
    const host = urlFor('DOCKER').replace(/^https?:\/\//, '');
    const block = blockFor({
      format: 'DOCKER',
      tool: 'docker',
      imageName: 'payment-service',
      tag: 'trixie',
      digest: DIGEST,
    });

    expect(block.code).toBe(`docker pull ${host}/payment-service:trixie`);
    expect(block.copyText).toBe('Copy the pull-by-tag command');
  });

  it('gives an untagged container its by-digest command, the only one of the pair', () => {
    const host = urlFor('DOCKER').replace(/^https?:\/\//, '');
    const block = blockFor({
      format: 'DOCKER',
      tool: 'docker',
      imageName: 'payment-service',
      tag: null,
      digest: DIGEST,
    });

    expect(block.code).toBe(`docker pull ${host}/payment-service@${DIGEST}`);
    expect(block.copyText).toBe('Copy the pull-by-digest command');
  });

  it.each`
    format     | tool       | coordinates          | copyText
    ${'MAVEN'} | ${'maven'} | ${MAVEN_COORDINATES} | ${'Copy the dependency declaration'}
    ${'NPM'}   | ${'npm'}   | ${NPM_COORDINATES}   | ${'Copy the install command'}
  `(
    'names what the $format copy button copies, which the icon-only button needs',
    ({ format, tool, coordinates, copyText }) => {
      expect(blockFor({ format, tool, ...coordinates }).copyText).toBe(copyText);
    },
  );

  it.each`
    refusal                          | args
    ${'no repository URL'}           | ${{ repositoryUrl: null }}
    ${'no repository name'}          | ${{ name: '' }}
    ${'a format it cannot build'}    | ${{ format: 'CONAN' }}
    ${'a coordinate it cannot hold'} | ${{ groupId: 'a</groupId><evil>x</evil><groupId>b' }}
  `('gives no block for $refusal, rather than one with a hole in it', ({ args }) => {
    expect(
      installSnippetBlock({
        format: 'MAVEN',
        tool: 'maven',
        name: NAME,
        repositoryUrl: urlFor('MAVEN'),
        ...args,
      }),
    ).toBe(null);
  });
});
