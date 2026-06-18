import { resetHTMLFixture, setHTMLFixture } from 'helpers/fixtures';
import { DiffFile } from '~/rapid_diffs/web_components/diff_file';
import { EXPANDED_LINES } from '~/rapid_diffs/adapter_events';
import { lineCodeQualityAdapter } from 'ee/rapid_diffs/adapters/line_code_quality';
import { useCodeQuality } from '~/rapid_diffs/stores/code_quality';
import { pinia } from '~/pinia/instance';

jest.mock('~/pinia/instance', () => {
  // eslint-disable-next-line global-require
  const { createPinia, setActivePinia } = require('pinia');
  const instance = createPinia();
  setActivePinia(instance);
  return { pinia: instance };
});

const newPath = 'app/foo.rb';

describe('lineCodeQualityAdapter', () => {
  let store;

  const setupFixture = ({ filePath = newPath } = {}) => {
    const fileData = { viewer: 'text_inline', oldPath: newPath, newPath: filePath };
    setHTMLFixture(`
      <diff-file id="abc" data-file-data='${JSON.stringify(fileData)}'>
        <div>
          <table>
            <tbody>
              <tr data-hunk-lines>
                <td data-position="old"></td>
                <td data-position="new"></td>
                <td data-position="new" class="rd-line-content">
                  <span data-line-codequality="5"></span>
                  <pre class="rd-line-text"></pre>
                </td>
              </tr>
              <tr data-hunk-lines>
                <td data-position="old"></td>
                <td data-position="new"></td>
                <td data-position="new" class="rd-line-content">
                  <span data-line-codequality="6"></span>
                  <pre class="rd-line-text"></pre>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </diff-file>
    `);
  };

  const mountWithAdapter = () => {
    document.querySelector('diff-file').mount({
      adapterConfig: { text_inline: [lineCodeQualityAdapter] },
      appData: {},
      observe: jest.fn(),
      unobserve: jest.fn(),
    });
  };

  const getSlots = () => document.querySelectorAll('[data-line-codequality]');
  const getTrigger = (slot) => slot.querySelector('button[data-click="showCodeQualityFindings"]');
  const getStaticIcon = (slot) => slot.querySelector('svg');
  const clickSlot = (slot) => {
    const button = getTrigger(slot);
    let event;
    button.addEventListener(
      'click',
      (e) => {
        event = e;
      },
      { once: true },
    );
    button.click();
    document.querySelector('diff-file').onClick(event);
  };

  beforeAll(() => {
    customElements.define('diff-file', DiffFile);
  });

  beforeEach(() => {
    store = useCodeQuality(pinia);
    store.$reset();
  });

  afterEach(() => {
    resetHTMLFixture();
  });

  it('does nothing when findings have not loaded', () => {
    setupFixture();
    mountWithAdapter();

    getSlots().forEach((slot) => {
      expect(slot.dataset.codequalityHasFindings).toBeUndefined();
      expect(getTrigger(slot)).toBe(null);
    });
  });

  it('renders a static, clickable severity icon at rest only on lines with findings', async () => {
    setupFixture();
    mountWithAdapter();

    store.files = {
      [newPath]: [{ line: 5, description: 'Method too long', severity: 'major' }],
    };
    store.loaded = true;
    await Promise.resolve();

    const [slot5, slot6] = getSlots();
    expect(slot5.dataset.codequalityHasFindings).toBe('true');
    expect(getTrigger(slot5)).not.toBe(null);
    expect(getTrigger(slot5).getAttribute('aria-label')).toBe('1 Code Quality finding detected');
    expect(getStaticIcon(slot5).classList).toContain('s14');
    expect(slot5.destroyFindings).toBeUndefined();

    expect(slot6.dataset.codequalityHasFindings).toBeUndefined();
    expect(getTrigger(slot6)).toBe(null);
  });

  it('flags the file so every line reserves the trigger slot table-wide', async () => {
    setupFixture();
    mountWithAdapter();
    const diffElement = document.querySelector('diff-file > div');

    expect(diffElement.dataset.codequalityHasFindings).toBeUndefined();

    store.files = { [newPath]: [{ line: 5, description: 'x', severity: 'major' }] };
    store.loaded = true;
    await Promise.resolve();

    expect(diffElement.dataset.codequalityHasFindings).toBe('true');
  });

  it('mounts the interactive dropdown only when the line is clicked', async () => {
    setupFixture();
    mountWithAdapter();

    store.files = {
      [newPath]: [{ line: 5, description: 'Method too long', severity: 'major' }],
    };
    store.loaded = true;
    await Promise.resolve();

    const [slot5] = getSlots();
    expect(slot5.destroyFindings).toBeUndefined();

    clickSlot(slot5);

    expect(typeof slot5.destroyFindings).toBe('function');
    expect(getTrigger(slot5)).toBe(null);
  });

  it('decorates lines revealed by EXPANDED_LINES', async () => {
    setupFixture();
    mountWithAdapter();

    store.files = { [newPath]: [{ line: 5, description: 'x', severity: 'minor' }] };
    store.loaded = true;
    await Promise.resolve();

    const newRow = document.createElement('tr');
    newRow.dataset.hunkLines = '';
    newRow.innerHTML = `
      <td data-position="old"></td>
      <td data-position="new"></td>
      <td data-position="new" class="rd-line-content">
        <span data-line-codequality="7"></span>
        <pre class="rd-line-text"></pre>
      </td>
    `;
    document.querySelector('tbody').appendChild(newRow);
    store.files = {
      [newPath]: [
        { line: 5, description: 'x', severity: 'minor' },
        { line: 7, description: 'Unused variable', severity: 'info' },
      ],
    };
    document.querySelector('diff-file').trigger(EXPANDED_LINES);

    const slot7 = document.querySelector('[data-line-codequality="7"]');
    expect(slot7.dataset.codequalityHasFindings).toBe('true');
    expect(getTrigger(slot7)).not.toBe(null);
  });

  it('does nothing when the file has no newPath', () => {
    setupFixture({ filePath: '' });
    mountWithAdapter();

    store.files = { '': [{ line: 5, description: 'x', severity: 'major' }] };
    store.loaded = true;

    getSlots().forEach((slot) => {
      expect(slot.dataset.codequalityHasFindings).toBeUndefined();
    });
  });
});
