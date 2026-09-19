import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { GlKeysetPagination, GlTabs } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { typePolicies as globalTypePolicies } from '~/lib/graphql';
import {
  possibleTypes,
  typePolicies as artifactRegistryTypePolicies,
} from 'ee/packages_and_registries/artifact_registry/graphql/cache_config';
import VersionDetail from 'ee/packages_and_registries/artifact_registry/repositories/versions/detail/version_detail.vue';
import getVersionQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_version.query.graphql';
import getVersionFilesQuery from 'ee/packages_and_registries/artifact_registry/graphql/queries/get_version_files.query.graphql';
import { createRouter } from 'ee/packages_and_registries/artifact_registry/router';
import {
  ARTIFACT_ID_FOR,
  CLIENT_BASE_URL,
  FIRST_PAGE_END_CURSOR,
  ORGANIZATION_GID,
  SECOND_PAGE_START_CURSOR,
  SLUG,
  mockFilePage,
  mockMavenFiles,
  mockNpmFiles,
  mockRepository,
  mockRepositoryResponse,
  mockVersionDetails,
  mockVersionFiles,
  mockVersionRepository,
} from '../../../mock_data';

// A real router, in its own file: `Vue.use(VueRouter)` runs on import and would
// invalidate the mocked `$route` every other test in `version_detail_spec.js` relies on.
Vue.use(VueApollo);

const BASE_PATH = '/o/gitlab-org/-/artifact_registry/acme/repositories';
const ARTIFACT_ID = ARTIFACT_ID_FOR.MAVEN;
const VERSION_ID = mockVersionDetails().id;
const VERSION_PATH = `/${mockRepository.name}/${ARTIFACT_ID}/versions/${VERSION_ID}`;

describe('ArtifactRegistryVersionDetail paging', () => {
  let wrapper;
  let router;
  let filesHandler;

  // The second page carries a different file so a served-from-cache page is visible as
  // unchanged rows rather than only as a missing network call.
  const pageFor = ({ after, before }) =>
    mockFilePage(after || before ? mockNpmFiles : mockMavenFiles, {
      hasNextPage: !after,
      hasPreviousPage: Boolean(after),
      endCursor: FIRST_PAGE_END_CURSOR,
      startCursor: SECOND_PAGE_START_CURSOR,
    });

  const createComponent = async ({ query = { tab: 'files' }, handler } = {}) => {
    filesHandler =
      handler ??
      jest.fn((variables) =>
        Promise.resolve(
          mockRepositoryResponse(
            mockVersionRepository({ version: mockVersionFiles({ files: pageFor(variables) }) }),
          ),
        ),
      );

    router = createRouter(BASE_PATH, { artifactName: '', versionName: '' });
    await router.push({ path: VERSION_PATH, query });

    wrapper = mountExtended(VersionDetail, {
      router,
      apolloProvider: createMockApollo(
        [
          [
            getVersionQuery,
            jest.fn().mockResolvedValue(mockRepositoryResponse(mockVersionRepository())),
          ],
          [getVersionFilesQuery, filesHandler],
        ],
        {},
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
    });
    await waitForPromises();
  };

  const findFileNames = () =>
    wrapper.findAllByTestId('file-name').wrappers.map((cell) => cell.text());
  const findAnnouncement = () => wrapper.findByTestId('version-announcement');

  const findPager = () => wrapper.findComponent(GlKeysetPagination);
  // The pager component mounts either way; its own root is `v-if`d on having a page to offer,
  // so only the rendered nav distinguishes "no pager" from "a pager with both buttons dead".
  const findPagerNav = () => wrapper.findByRole('navigation', { name: 'Pagination' });

  const pageForward = async () => {
    await router.push({ query: { tab: 'files', after: FIRST_PAGE_END_CURSOR } });
  };

  it('re-reads with the cursor and re-renders, rather than serving the page it holds', async () => {
    await createComponent();

    const firstPage = findFileNames();

    await pageForward();
    await waitForPromises();

    expect(filesHandler).toHaveBeenCalledTimes(2);
    expect(filesHandler.mock.calls[1][0]).toMatchObject({ after: FIRST_PAGE_END_CURSOR });
    expect(findFileNames()).not.toEqual(firstPage);
  });

  it('re-reads a page it has already held, rather than serving it from the cache', async () => {
    await createComponent();

    const firstPage = findFileNames();

    await pageForward();
    await waitForPromises();
    await router.push({ query: { tab: 'files' } });
    await waitForPromises();

    expect(filesHandler).toHaveBeenCalledTimes(3);
    expect(findFileNames()).toEqual(firstPage);
  });

  it('announces the change through the loading pass separating the two results', async () => {
    await createComponent();

    const settled = findAnnouncement().text();

    await pageForward();
    await nextTick();

    expect(findAnnouncement().text()).toBe('Loading files.');

    await waitForPromises();

    expect(findAnnouncement().text()).toBe(settled);
  });

  it('pages from the pager itself, through the route, to new rows', async () => {
    await createComponent();

    const firstPage = findFileNames();

    findPager().vm.$emit('next', FIRST_PAGE_END_CURSOR);
    await waitForPromises();

    expect(router.currentRoute.query).toEqual({ tab: 'files', after: FIRST_PAGE_END_CURSOR });
    expect(findFileNames()).not.toEqual(firstPage);
  });

  describe('when the registry rejects the cursor', () => {
    // Rejects only a cursored read, so the first page still loads. That is the state a reader
    // actually reaches: they arrive on page one and page forward from it.
    const rejectCursoredReads = () =>
      jest.fn((variables) =>
        variables.after || variables.before
          ? Promise.reject(new Error('Bad Request'))
          : Promise.resolve(
              mockRepositoryResponse(
                mockVersionRepository({ version: mockVersionFiles({ files: pageFor(variables) }) }),
              ),
            ),
      );

    it('replaces the table with the alert, and offers no pager to page on with', async () => {
      await createComponent({
        query: { tab: 'files', after: 'a-cursor-the-registry-never-issued' },
        handler: jest.fn().mockRejectedValue(new Error('Bad Request')),
      });

      expect(wrapper.findByTestId('files-error').exists()).toBe(true);
      expect(findFileNames()).toEqual([]);
      expect(findPagerNav().exists()).toBe(false);
    });

    describe('after a page already on screen fails to page forward', () => {
      beforeEach(async () => {
        await createComponent({ handler: rejectCursoredReads() });
        await pageForward();
        await waitForPromises();
      });

      it('retires the pager, rather than leaving Next live on the cursor that just failed', () => {
        expect(wrapper.findByTestId('files-error').exists()).toBe(true);
        expect(findPagerNav().exists()).toBe(false);
      });

      it('leaves the live region to the alert rather than announcing the tab loaded', () => {
        expect(findAnnouncement().text()).toBe('');
      });
    });

    it('recovers on a tab round-trip, which strips the cursor', async () => {
      await createComponent({
        query: { tab: 'files', after: FIRST_PAGE_END_CURSOR },
        handler: rejectCursoredReads(),
      });

      expect(wrapper.findByTestId('files-error').exists()).toBe(true);

      wrapper.findComponent(GlTabs).vm.$emit('input', 0);
      await waitForPromises();
      wrapper.findComponent(GlTabs).vm.$emit('input', 1);
      await waitForPromises();

      expect(router.currentRoute.query).toEqual({ tab: 'files' });
      expect(wrapper.findByTestId('files-error').exists()).toBe(false);
      expect(findFileNames()).toEqual(mockMavenFiles.map(({ fileName }) => fileName));
    });
  });

  it('disables the pager while a page is in flight, then hands it back', async () => {
    await createComponent();

    expect(findPager().props('disabled')).toBe(false);

    await pageForward();
    await nextTick();

    expect(findPager().props('disabled')).toBe(true);

    await waitForPromises();

    expect(findPager().props('disabled')).toBe(false);
  });

  it('drops the cursor when the reader leaves the tab', async () => {
    await createComponent({ query: { tab: 'files', after: FIRST_PAGE_END_CURSOR } });

    wrapper.findComponent(GlTabs).vm.$emit('input', 0);
    await waitForPromises();

    expect(router.currentRoute.query).toEqual({ tab: 'overview' });
  });
});
