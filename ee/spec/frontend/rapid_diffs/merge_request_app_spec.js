import { createTestingPinia } from '@pinia/testing';
import { nextTick } from 'vue';
import { setHTMLFixture } from 'helpers/fixtures';
import { createMergeRequestRapidDiffsApp } from 'ee/rapid_diffs/merge_request_app';
import { lineCodeQualityAdapter } from 'ee/rapid_diffs/adapters/line_code_quality';
import { useDiffsView } from '~/rapid_diffs/stores/diffs_view';
import { useDiffsList } from '~/rapid_diffs/stores/diffs_list';
import { useMergeRequestDiscussions } from '~/merge_request/stores/merge_request_discussions';
import { useLegacyDiffs } from '~/diffs/stores/legacy_diffs';
import { useCodeQuality } from '~/rapid_diffs/stores/code_quality';
import { initFileBrowser } from '~/rapid_diffs/app/file_browser';
import { globalAccessorPlugin } from '~/pinia/plugins';

jest.mock('~/lib/graphql');
jest.mock('~/rapid_diffs/app/view_settings');
jest.mock('~/rapid_diffs/app/init_hidden_files_warning');
jest.mock('~/rapid_diffs/app/file_browser');
jest.mock('~/rapid_diffs/app/quirks/safari_fix');
jest.mock('~/rapid_diffs/app/quirks/content_visibility_fix');
jest.mock('~/rapid_diffs/app/init_compare_versions');
jest.mock('~/rapid_diffs/app/init_new_discussions_toggle');
jest.mock('~/rapid_diffs/app/init_line_range_selection');
jest.mock('ee/diffs/components/shared/findings_drawer.vue', () => ({
  render: (h) => h('div', { attrs: { 'data-testid': 'findings-drawer' } }),
}));

const findDrawer = () => document.querySelector('[data-testid="findings-drawer"]');

describe('Merge Request Rapid Diffs app EE', () => {
  let app;

  const appData = {
    diffsStreamUrl: '/stream',
    reloadStreamUrl: '/reload',
    diffsStatsEndpoint: '/stats',
    diffFilesEndpoint: '/diff-files-metadata',
    shouldSortMetadataFiles: true,
    lazy: false,
  };

  const buildApp = (data = {}) => {
    setHTMLFixture(
      `
      <main>
        <div class="container-fluid" data-diffs-container>
          <div data-rapid-diffs data-app-data='${JSON.stringify({ ...appData, ...data })}'>
            <div data-view-settings></div>
            <div data-file-browser></div>
            <div data-file-browser-toggle></div>
            <div data-hidden-files-warning></div>
            <div data-stream-remaining-diffs></div>
            <div data-after-browser-toggle></div>
          </div>
        </div>
      </main>
      `,
    );
    app = createMergeRequestRapidDiffsApp();
  };

  beforeAll(() => {
    Object.defineProperty(window, 'customElements', {
      value: { define: jest.fn() },
      writable: true,
    });
  });

  let pinia;

  beforeEach(() => {
    window.gon = { current_user_id: 1 };
    pinia = createTestingPinia({ plugins: [globalAccessorPlugin] });
    useLegacyDiffs();
    useDiffsView().loadDiffsStats.mockResolvedValue();
    useDiffsList().streamRemainingDiffs.mockResolvedValue();
    useMergeRequestDiscussions().fetchNotesAndDrafts.mockResolvedValue();
    useCodeQuality().fetchCodeQuality.mockResolvedValue();
    initFileBrowser.mockResolvedValue();
  });

  afterEach(() => {
    window.gon = {};
  });

  it('registers the code quality adapter for the text viewers', () => {
    buildApp();

    expect(app.adapterConfig.text_inline).toContain(lineCodeQualityAdapter);
    expect(app.adapterConfig.text_parallel).toContain(lineCodeQualityAdapter);
  });

  it('fetches code quality on init when the endpoint is present', async () => {
    buildApp({ codequalityEndpoint: '/code-quality' });
    await app.init();

    expect(useCodeQuality(pinia).fetchCodeQuality).toHaveBeenCalled();
  });

  it('does not fetch code quality when the endpoint is absent', async () => {
    buildApp();
    await app.init();

    expect(useCodeQuality(pinia).fetchCodeQuality).not.toHaveBeenCalled();
  });

  it('renders the findings drawer once code quality findings are available', async () => {
    buildApp({ codequalityEndpoint: '/code-quality' });
    await app.init();

    expect(findDrawer()).toBe(null);

    const store = useCodeQuality(pinia);
    store.files = { 'foo.js': [{ line: 1, description: 'x' }] };
    store.loaded = true;
    await nextTick();

    expect(findDrawer()).not.toBe(null);
  });

  it('does not render the findings drawer when there are no findings', async () => {
    buildApp({ codequalityEndpoint: '/code-quality' });
    await app.init();

    useCodeQuality(pinia).loaded = true;
    await nextTick();

    expect(findDrawer()).toBe(null);
  });
});
