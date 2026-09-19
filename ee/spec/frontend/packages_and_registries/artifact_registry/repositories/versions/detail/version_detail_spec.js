import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { RouterLinkStub } from '@vue/test-utils';
import { GlAlert, GlKeysetPagination, GlSkeletonLoader, GlTab, GlTabs } from '@gitlab/ui';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import { typePolicies as globalTypePolicies } from '~/lib/graphql';
import {
  possibleTypes,
  typePolicies as artifactRegistryTypePolicies,
} from 'ee/packages_and_registries/artifact_registry/graphql/cache_config';
import waitForPromises from 'helpers/wait_for_promises';
import BaseLayout from '~/vue_shared/components/base_layout.vue';
import DetailLayout from '~/vue_shared/components/detail_layout.vue';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import NotFound from 'ee/packages_and_registries/artifact_registry/components/not_found.vue';
import FormatLogo from 'ee/packages_and_registries/artifact_registry/repositories/components/format_logo.vue';
import VersionSidebar from 'ee/packages_and_registries/artifact_registry/repositories/versions/detail/version_sidebar.vue';
import VersionDetail from 'ee/packages_and_registries/artifact_registry/repositories/versions/detail/version_detail.vue';
import VersionOverview from 'ee/packages_and_registries/artifact_registry/repositories/versions/detail/version_overview.vue';
import getVersionQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_version.query.graphql';
import getVersionFilesQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_version_files.query.graphql';
import FilesEmptyState from 'ee/packages_and_registries/artifact_registry/repositories/versions/detail/files_empty_state.vue';
import FilesSection from 'ee/packages_and_registries/artifact_registry/repositories/versions/detail/files_section.vue';
import FilesTable from 'ee/packages_and_registries/artifact_registry/repositories/versions/detail/files_table.vue';
import {
  ARTIFACT_ID_FOR,
  CLIENT_BASE_URL,
  FIRST_PAGE_END_CURSOR,
  SECOND_PAGE_START_CURSOR,
  ORGANIZATION_GID,
  SLUG,
  mockRepository,
  mockRepositoryResponse,
  mockFilePage,
  mockMavenFiles,
  mockNpmFiles,
  mockVersionDetails,
  mockVersionFiles,
  mockVersionRepository,
} from '../../../mock_data';

Vue.use(VueApollo);

const ARTIFACT_ID = ARTIFACT_ID_FOR.MAVEN;

const VERSION_ID = mockVersionDetails().id;

const VERSION_PATH = `/${mockRepository.name}/${ARTIFACT_ID}/versions/${VERSION_ID}`;

const successHandler = (repository = mockVersionRepository()) =>
  jest.fn().mockResolvedValue(mockRepositoryResponse(repository));

const filesHandler = (version = mockVersionFiles(), format = 'MAVEN') =>
  jest.fn().mockResolvedValue(mockRepositoryResponse(mockVersionRepository({ format, version })));

describe('ArtifactRegistryVersionDetail', () => {
  let wrapper;
  let mockApollo;

  const updateArtifactName = jest.fn();
  const updateVersionName = jest.fn();

  const push = jest.fn();

  const createComponent = ({
    handler = successHandler(),
    files = filesHandler(),
    query = {},
    mountFn = shallowMountExtended,
  } = {}) => {
    mockApollo = createMockApollo(
      [
        [getVersionQuery, handler],
        [getVersionFilesQuery, files],
      ],
      {},
      {
        possibleTypes,
        typePolicies: { ...globalTypePolicies, ...artifactRegistryTypePolicies },
      },
    );

    wrapper = mountFn(VersionDetail, {
      apolloProvider: mockApollo,
      provide: {
        breadCrumbState: { updateArtifactName, updateVersionName },
        organizationGid: ORGANIZATION_GID,
        slug: SLUG,
        clientBaseUrl: CLIENT_BASE_URL,
      },
      mocks: {
        $route: {
          path: VERSION_PATH,
          params: {
            id: mockRepository.name,
            artifactId: ARTIFACT_ID,
            versionId: VERSION_ID,
          },
          query,
        },
        $router: { push },
      },
      stubs: { BaseLayout, DetailLayout, PageHeading, RouterLink: RouterLinkStub },
    });
  };

  const findSkeleton = () => wrapper.findComponent(GlSkeletonLoader);
  const findAlert = () => wrapper.findComponent(GlAlert);
  const findNotFound = () => wrapper.findComponent(NotFound);
  const findFormatLogo = () => wrapper.findComponent(FormatLogo);
  const findHeading = () => wrapper.findByTestId('page-heading');
  const findVersionName = () => wrapper.findByTestId('version-name');
  const findArtifactName = () => wrapper.findByTestId('artifact-name');
  const findFormatName = () => wrapper.findByTestId('version-format-name');
  const findAnnouncement = () => wrapper.findByTestId('version-announcement');
  const findSidebar = () => wrapper.findComponent(VersionSidebar);
  const findSidebarRegion = () => wrapper.findByRole('region', { name: 'Sidebar' });

  afterEach(() => {
    mockApollo = null;
  });

  describe('the query it issues', () => {
    it('names the repository, the artifact, and the version the route addresses', async () => {
      const handler = successHandler();
      createComponent({ handler });
      await waitForPromises();

      expect(handler).toHaveBeenCalledWith({
        organizationId: ORGANIZATION_GID,
        name: mockRepository.name,
        artifactId: ARTIFACT_ID,
        versionId: VERSION_ID,
      });
    });
  });

  describe('while the read is in flight', () => {
    beforeEach(() => createComponent({ handler: jest.fn(() => new Promise(() => {})) }));

    it('renders a loading affordance', () => {
      expect(findSkeleton().exists()).toBe(true);
    });

    it('renders no sidebar while loading', () => {
      expect(findSidebar().exists()).toBe(false);
    });

    it('renders neither the header nor an outcome state', () => {
      expect(findHeading().exists()).toBe(false);
      expect(findVersionName().exists()).toBe(false);
      expect(findAlert().exists()).toBe(false);
      expect(findNotFound().exists()).toBe(false);
    });

    it('announces that the read is in flight', () => {
      expect(findAnnouncement().text()).toBe('Loading version details.');
    });
  });

  describe('when the version loads', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('names the version in the heading', () => {
      expect(findVersionName().text()).toBe('3.2.1');
    });

    it('names the artifact beneath the version', () => {
      expect(findArtifactName().text()).toBe('com.company.payment:core');
    });

    it('renders the format logo with a text alternative beside it', () => {
      expect(findFormatLogo().props('format')).toBe('MAVEN');
      expect(findFormatName().text()).toBe('Maven');
    });

    it('renders no loading, error, or not-found affordance', () => {
      expect(findSkeleton().exists()).toBe(false);
      expect(findAlert().exists()).toBe(false);
      expect(findNotFound().exists()).toBe(false);
    });

    it('announces the active tab, the version, and the artifact it belongs to', () => {
      expect(findAnnouncement().text()).toBe(
        'Overview tab for version 3.2.1 of com.company.payment:core.',
      );
    });

    it('publishes both the artifact name and the version into the breadcrumb slots', () => {
      expect(updateArtifactName).toHaveBeenCalledWith('com.company.payment:core');
      expect(updateVersionName).toHaveBeenCalledWith('3.2.1');
    });

    it('renders the sidebar inside the layout sidebar region', () => {
      expect(findSidebarRegion().element.contains(findSidebar().element)).toBe(true);
    });

    it('passes the resolved version to the sidebar', () => {
      expect(findSidebar().props('version')).toEqual(mockVersionDetails());
    });

    it('passes the repository the version belongs to', () => {
      const { name, kind } = mockVersionRepository();

      expect(findSidebar().props('repository')).toMatchObject({ name, kind });
    });
  });

  describe('when a refetch fails after the version loaded', () => {
    beforeEach(async () => {
      createComponent({
        handler: jest
          .fn()
          .mockResolvedValueOnce(mockRepositoryResponse(mockVersionRepository()))
          .mockRejectedValue(new Error('Unavailable')),
      });
      await waitForPromises();

      wrapper.vm.$apollo.queries.repository.refetch().catch(() => {});
      await waitForPromises();
    });

    it('renders the alert without the stale header and sidebar', () => {
      expect(findAlert().exists()).toBe(true);
      expect(findHeading().exists()).toBe(false);
      expect(findSidebar().exists()).toBe(false);
    });
  });

  describe('when the read fails', () => {
    beforeEach(async () => {
      createComponent({ handler: jest.fn().mockRejectedValue(new Error('Unavailable')) });
      await waitForPromises();
    });

    it('renders a service-unavailable alert that cannot be dismissed', () => {
      expect(findAlert().text()).toBe('The Artifact Registry service is unavailable.');
      expect(findAlert().props('dismissible')).toBe(false);
    });

    it('renders no header and no not-found state', () => {
      expect(findHeading().exists()).toBe(false);
      expect(findVersionName().exists()).toBe(false);
      expect(findNotFound().exists()).toBe(false);
    });

    it('leaves the live region silent, because the alert announces the failure itself', () => {
      expect(findAlert().props('variant')).toBe('danger');
      expect(findAnnouncement().text()).toBe('');
    });

    it('renders no sidebar, because there is no version to describe', () => {
      expect(findSidebar().exists()).toBe(false);
    });
  });

  describe.each`
    outcome                              | repository
    ${'the repository does not resolve'} | ${null}
    ${'the version does not resolve'}    | ${mockVersionRepository({ version: null })}
  `('when $outcome', ({ repository }) => {
    beforeEach(async () => {
      createComponent({ handler: successHandler(repository) });
      await waitForPromises();
    });

    it('renders the not-found state', () => {
      expect(findNotFound().exists()).toBe(true);
    });

    it('renders no header and no alert', () => {
      expect(findHeading().exists()).toBe(false);
      expect(findVersionName().exists()).toBe(false);
      expect(findAlert().exists()).toBe(false);
    });

    it('announces the not-found outcome', () => {
      expect(findAnnouncement().text()).toBe('Page not found');
    });

    it('renders no sidebar, because there is no version to describe', () => {
      expect(findSidebar().exists()).toBe(false);
    });

    describe('with the Files tab selected and a files read that comes back empty', () => {
      beforeEach(async () => {
        createComponent({
          handler: successHandler(repository),
          files: filesHandler(mockVersionFiles({ files: mockFilePage([]) })),
          query: { tab: 'files' },
        });
        await waitForPromises();
      });

      it('announces the not-found outcome, rather than an empty Files tab', () => {
        expect(findAnnouncement().text()).toBe('Page not found');
      });
    });
  });

  describe('the tab set', () => {
    const findTabs = () => wrapper.findComponent(GlTabs);
    const findTabTitles = () =>
      wrapper.findAllComponents(GlTab).wrappers.map((tab) => tab.attributes('title'));

    const createWithFormat = async (format, query = {}) => {
      createComponent({ handler: successHandler(mockVersionRepository({ format })), query });
      await waitForPromises();
    };

    it('renders the Maven tabs', async () => {
      await createWithFormat('MAVEN');

      expect(findTabTitles()).toEqual(['Overview', 'Files']);
    });

    it('renders the npm tabs', async () => {
      await createWithFormat('NPM');

      expect(findTabTitles()).toEqual(['Overview', 'File']);
    });

    it('renders no tabs until the version resolves', async () => {
      createComponent({ handler: jest.fn(() => new Promise(() => {})) });
      await waitForPromises();

      expect(findTabs().exists()).toBe(false);
    });

    describe('the tab the route selects', () => {
      it.each`
        query                  | index | outcome
        ${{}}                  | ${0}  | ${'an absent value lands on Overview'}
        ${{ tab: 'overview' }} | ${0}  | ${'overview selects Overview'}
        ${{ tab: 'files' }}    | ${1}  | ${'files selects Files'}
        ${{ tab: 'nonsense' }} | ${0}  | ${'an unrecognized value lands on Overview'}
      `('$outcome', async ({ query, index }) => {
        await createWithFormat('MAVEN', query);

        expect(findTabs().props('value')).toBe(index);
      });

      it('selects the npm files tab, which the format names in the singular', async () => {
        await createWithFormat('NPM', { tab: 'files' });

        expect(findTabs().props('value')).toBe(1);
      });
    });

    describe('the Files tab', () => {
      const findFilesSection = () => wrapper.findComponent(FilesSection);
      const findFilesCount = () => wrapper.findByTestId('tab-counter-badge');
      const findCountSrText = () => findFilesCount().element.nextElementSibling;

      it('issues no files read while Overview is the tab on screen', async () => {
        const files = filesHandler();
        createComponent({
          handler: successHandler(mockVersionRepository()),
          files,
          mountFn: mountExtended,
        });
        await waitForPromises();

        expect(files).not.toHaveBeenCalled();
        expect(findFilesSection().exists()).toBe(false);
      });

      it('reads the files the version holds once the tab is on screen', async () => {
        const files = filesHandler();
        createComponent({ files, query: { tab: 'files' } });
        await waitForPromises();

        expect(files).toHaveBeenCalledWith({
          organizationId: ORGANIZATION_GID,
          name: mockRepository.name,
          artifactId: ARTIFACT_ID,
          versionId: VERSION_ID,
          first: 20,
        });
        expect(
          findFilesSection()
            .props('files')
            .map(({ fileName }) => fileName),
        ).toEqual(mockMavenFiles.map(({ fileName }) => fileName));
      });

      it('carries the statistics count on the Maven tab label', async () => {
        createComponent({ query: { tab: 'files' }, mountFn: mountExtended });
        await waitForPromises();

        expect(findFilesCount().text()).toBe(String(mockMavenFiles.length));
      });

      it('carries the count before the files read runs, because Overview does not issue it', async () => {
        const files = filesHandler();
        createComponent({ files, mountFn: mountExtended });
        await waitForPromises();

        expect(files).not.toHaveBeenCalled();
        expect(findFilesCount().text()).toBe(String(mockMavenFiles.length));
      });

      it('names the unit beside the count, which the badge itself hides', async () => {
        createComponent({ query: { tab: 'files' }, mountFn: mountExtended });
        await waitForPromises();

        expect(findFilesCount().attributes('aria-hidden')).toBe('true');
        expect(findCountSrText()).toHaveClass('gl-sr-only');
        expect(findCountSrText().textContent).toBe(`${mockMavenFiles.length} files`);
      });

      it('carries a zero as a zero, rather than dropping the badge', async () => {
        createComponent({
          handler: successHandler(
            mockVersionRepository({ version: mockVersionDetails({ filesCount: 0 }) }),
          ),
          query: { tab: 'files' },
          mountFn: mountExtended,
        });
        await waitForPromises();

        expect(findFilesCount().text()).toBe('0');
        expect(findCountSrText().textContent).toBe('0 files');
      });

      it('carries no count on the npm tab', async () => {
        createComponent({
          handler: successHandler(mockVersionRepository({ format: 'NPM' })),
          files: filesHandler(mockVersionFiles({ files: mockFilePage(mockNpmFiles) }), 'NPM'),
          query: { tab: 'files' },
          mountFn: mountExtended,
        });
        await waitForPromises();

        expect(findFilesSection().exists()).toBe(true);
        expect(findFilesCount().exists()).toBe(false);
      });

      it('carries no count when the statistics do not resolve', async () => {
        createComponent({
          handler: successHandler(
            mockVersionRepository({ version: mockVersionDetails({ filesCount: null }) }),
          ),
          query: { tab: 'files' },
          mountFn: mountExtended,
        });
        await waitForPromises();

        expect(findFilesCount().exists()).toBe(false);
      });

      describe('paging', () => {
        const findPager = () => wrapper.findComponent(GlKeysetPagination);

        const pagedFiles = (pageInfo) =>
          filesHandler(mockVersionFiles({ files: mockFilePage(mockMavenFiles, pageInfo) }));

        const onFirstPage = () =>
          createComponent({
            files: pagedFiles({ hasNextPage: true, endCursor: FIRST_PAGE_END_CURSOR }),
            query: { tab: 'files' },
          });

        it('hands the pager the connection’s own page info', async () => {
          onFirstPage();
          await waitForPromises();

          expect(findPager().props()).toMatchObject({
            hasNextPage: true,
            hasPreviousPage: false,
            endCursor: FIRST_PAGE_END_CURSOR,
          });
        });

        it('reads the first page with no cursor at all', async () => {
          const files = pagedFiles({ hasNextPage: true, endCursor: FIRST_PAGE_END_CURSOR });
          createComponent({ files, query: { tab: 'files' } });
          await waitForPromises();

          expect(files).toHaveBeenCalledWith({
            organizationId: ORGANIZATION_GID,
            name: mockRepository.name,
            artifactId: ARTIFACT_ID,
            versionId: VERSION_ID,
            first: 20,
          });
        });

        it('carries the forward cursor into the route, so a page survives a reload', async () => {
          onFirstPage();
          await waitForPromises();

          findPager().vm.$emit('next', FIRST_PAGE_END_CURSOR);

          expect(push).toHaveBeenCalledWith({
            path: VERSION_PATH,
            query: { tab: 'files', after: FIRST_PAGE_END_CURSOR },
          });
        });

        it('replaces the forward cursor with the backward one, never carrying both', async () => {
          createComponent({
            files: pagedFiles({ hasPreviousPage: true, startCursor: SECOND_PAGE_START_CURSOR }),
            query: { tab: 'files', after: FIRST_PAGE_END_CURSOR },
          });
          await waitForPromises();

          findPager().vm.$emit('prev', SECOND_PAGE_START_CURSOR);

          expect(push).toHaveBeenCalledWith({
            path: VERSION_PATH,
            query: { tab: 'files', before: SECOND_PAGE_START_CURSOR },
          });
        });

        it('asks for a forward page when the route names a forward cursor', async () => {
          const files = pagedFiles({ hasPreviousPage: true });
          createComponent({ files, query: { tab: 'files', after: FIRST_PAGE_END_CURSOR } });
          await waitForPromises();

          expect(files).toHaveBeenCalledWith(
            expect.objectContaining({ first: 20, after: FIRST_PAGE_END_CURSOR, last: undefined }),
          );
        });

        it('asks for a backward page, dropping first, when the route names a backward cursor', async () => {
          const files = pagedFiles({ hasNextPage: true });
          createComponent({ files, query: { tab: 'files', before: SECOND_PAGE_START_CURSOR } });
          await waitForPromises();

          expect(files).toHaveBeenCalledWith(
            expect.objectContaining({
              first: undefined,
              last: 20,
              before: SECOND_PAGE_START_CURSOR,
            }),
          );
        });

        it('offers previous and next alone, since the list carries no total', async () => {
          createComponent({
            files: pagedFiles({ hasNextPage: true, endCursor: FIRST_PAGE_END_CURSOR }),
            query: { tab: 'files' },
            mountFn: mountExtended,
          });
          await waitForPromises();

          expect(
            findPager()
              .findAll('button')
              .wrappers.map((b) => b.text()),
          ).toEqual(['Previous', 'Next']);
        });

        it('announces the read in flight, rather than leaving the page silent', async () => {
          createComponent({
            files: jest.fn(() => new Promise(() => {})),
            query: { tab: 'files' },
          });
          await waitForPromises();

          expect(findAnnouncement().text()).toBe('Loading files.');
        });
      });

      describe('a version that stores no files', () => {
        const emptyFiles = (filesCount) =>
          createComponent({
            handler: successHandler(
              mockVersionRepository({ version: mockVersionDetails({ filesCount }) }),
            ),
            files: filesHandler(mockVersionFiles({ files: mockFilePage([]) })),
            query: { tab: 'files' },
            mountFn: mountExtended,
          });

        it('hands the section the version string, so the empty state can name it', async () => {
          emptyFiles(0);
          await waitForPromises();

          expect(findFilesSection().props('versionString')).toBe('3.2.1');
        });

        it('renders the empty state in place of the table', async () => {
          emptyFiles(0);
          await waitForPromises();

          expect(wrapper.findComponent(FilesEmptyState).exists()).toBe(true);
          expect(wrapper.findComponent(FilesTable).exists()).toBe(false);
        });

        it('keeps the header and the whole tab set rendered around it', async () => {
          emptyFiles(0);
          await waitForPromises();

          expect(findVersionName().text()).toBe('3.2.1');
          expect(findArtifactName().text()).toBe('com.company.payment:core');
          expect(wrapper.findAllComponents(GlTab)).toHaveLength(2);
        });

        it('announces the empty result rather than leaving it a visual change', async () => {
          emptyFiles(0);
          await waitForPromises();

          expect(findAnnouncement().text()).toBe('Version 3.2.1 stores no files');
        });

        it('trusts the connection over a statistics count that disagrees', async () => {
          emptyFiles(mockMavenFiles.length);
          await waitForPromises();

          expect(findFilesCount().text()).toBe(String(mockMavenFiles.length));
          expect(findAnnouncement().text()).toBe('Version 3.2.1 stores no files');
        });

        it('says nothing about files while Overview is the tab on screen', async () => {
          createComponent({
            files: filesHandler(mockVersionFiles({ files: mockFilePage([]) })),
            mountFn: mountExtended,
          });
          await waitForPromises();

          expect(findAnnouncement().text()).toBe(
            'Overview tab for version 3.2.1 of com.company.payment:core.',
          );
        });
      });

      it('hands the section a loading state while the files read is in flight', async () => {
        createComponent({
          files: jest.fn(() => new Promise(() => {})),
          query: { tab: 'files' },
        });
        await waitForPromises();

        expect(findFilesSection().props('loading')).toBe(true);
      });

      describe('when the files read resolves the version to null', () => {
        beforeEach(async () => {
          createComponent({
            files: filesHandler(null),
            query: { tab: 'files' },
            mountFn: mountExtended,
          });
          await waitForPromises();
        });

        it('marks the section errored, since the version went away between the two reads', () => {
          expect(findFilesSection().props('hasError')).toBe(true);
          expect(wrapper.findComponent(FilesEmptyState).exists()).toBe(false);
        });

        it('leaves the live region silent rather than stating a cause it cannot know', () => {
          expect(findAnnouncement().text()).toBe('');
        });
      });

      it('keeps the header when the files read fails, and marks the section errored', async () => {
        createComponent({
          files: jest.fn().mockRejectedValue(new Error('Unavailable')),
          query: { tab: 'files' },
        });
        await waitForPromises();

        expect(findFilesSection().props('hasError')).toBe(true);
        expect(findVersionName().text()).toBe('3.2.1');
        expect(findAlert().exists()).toBe(false);
      });

      it('leaves the failed tab to its own alert rather than announcing it loaded', async () => {
        createComponent({
          files: jest.fn().mockRejectedValue(new Error('Unavailable')),
          query: { tab: 'files' },
        });
        await waitForPromises();

        expect(findAnnouncement().text()).toBe('');
      });
    });

    describe('selecting a tab', () => {
      it('writes the tab into the query without touching the path', async () => {
        await createWithFormat('MAVEN');

        findTabs().vm.$emit('input', 1);

        expect(push).toHaveBeenCalledWith({ path: VERSION_PATH, query: { tab: 'files' } });
      });

      it('keeps the rest of the query, so another page-level selection survives', async () => {
        await createWithFormat('MAVEN', { some_other: 'value' });

        findTabs().vm.$emit('input', 1);

        expect(push).toHaveBeenCalledWith({
          path: VERSION_PATH,
          query: { some_other: 'value', tab: 'files' },
        });
      });

      it('pushes nothing when the tab selected is the one already active', async () => {
        await createWithFormat('MAVEN', { tab: 'files' });

        findTabs().vm.$emit('input', 1);

        expect(push).not.toHaveBeenCalled();
      });

      it('announces the Files tab when the route selects it', async () => {
        await createWithFormat('MAVEN', { tab: 'files' });

        expect(findAnnouncement().text()).toBe(
          'Files tab for version 3.2.1 of com.company.payment:core.',
        );
      });
    });
  });

  describe('when the package does not resolve beside a resolved version', () => {
    beforeEach(async () => {
      createComponent({ handler: successHandler(mockVersionRepository({ package: null })) });
      await waitForPromises();
    });

    it('still renders the version, because the page is the version rather than its parent', () => {
      expect(findVersionName().text()).toBe('3.2.1');
      expect(findNotFound().exists()).toBe(false);
      expect(findAlert().exists()).toBe(false);
    });

    it('renders no artifact name rather than an empty one', () => {
      expect(findArtifactName().exists()).toBe(false);
    });

    it('still renders the sidebar, which describes the version rather than the package', () => {
      expect(findSidebar().exists()).toBe(true);
    });

    it('announces the version alone, with no empty gap where the artifact would be', () => {
      expect(findAnnouncement().text()).toBe('Overview tab for version 3.2.1.');
    });

    it('publishes an empty artifact name, so the crumb falls back to the id', () => {
      expect(updateArtifactName).toHaveBeenCalledWith('');
      expect(updateVersionName).toHaveBeenCalledWith('3.2.1');
    });

    it('hands the Overview tab a null artifact, which is what its guard reads', () => {
      expect(wrapper.findComponent(VersionOverview).props('artifact')).toBe(null);
    });
  });

  describe('what it publishes into the breadcrumb slots', () => {
    it('publishes nothing in flight, so the name the version list set stands', async () => {
      createComponent({ handler: jest.fn(() => new Promise(() => {})) });
      await waitForPromises();

      expect(updateArtifactName).not.toHaveBeenCalled();
      expect(updateVersionName).not.toHaveBeenCalled();
    });

    it('publishes an empty version name once the read settles without one', async () => {
      createComponent({ handler: successHandler(mockVersionRepository({ version: null })) });
      await waitForPromises();

      expect(updateVersionName).toHaveBeenCalledWith('');
      expect(updateVersionName).not.toHaveBeenCalledWith('3.2.1');
    });

    it('publishes both names once, not an empty pair then the resolved one', async () => {
      createComponent();
      await waitForPromises();

      expect(updateArtifactName.mock.calls).toEqual([['com.company.payment:core']]);
      expect(updateVersionName.mock.calls).toEqual([['3.2.1']]);
    });
  });

  describe('the Overview tab', () => {
    const findOverview = () => wrapper.findComponent(VersionOverview);

    const createWithQuery = async (query = {}, repository = mockVersionRepository()) => {
      createComponent({ handler: successHandler(repository), query });
      await waitForPromises();
    };

    it.each(['MAVEN', 'NPM'])('renders the install panel for a %s version', async (format) => {
      await createWithQuery({}, mockVersionRepository({ format }));

      expect(findOverview().props()).toMatchObject({
        format,
        name: mockRepository.name,
        artifact: expect.objectContaining({ id: ARTIFACT_ID_FOR[format] }),
        version: expect.objectContaining({ version: '3.2.1' }),
      });
    });

    it('renders it once, in the Overview panel and in no other', async () => {
      await createWithQuery();

      const [overview] = wrapper.findAllComponents(GlTab).wrappers;

      expect(wrapper.findAllComponents(VersionOverview)).toHaveLength(1);
      expect(overview.findComponent(VersionOverview).exists()).toBe(true);
    });
  });
});
