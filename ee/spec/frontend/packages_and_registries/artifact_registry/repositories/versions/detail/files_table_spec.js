import { GlLoadingIcon, GlTable } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import FileChecksums from 'ee/packages_and_registries/artifact_registry/repositories/versions/detail/file_checksums.vue';
import FilesTable from 'ee/packages_and_registries/artifact_registry/repositories/versions/detail/files_table.vue';
import { mockMavenFiles, mockNpmFiles } from '../../../mock_data';

describe('ArtifactRegistryFilesTable', () => {
  let wrapper;

  const createComponent = ({ files = mockMavenFiles, format = 'MAVEN', ...props } = {}) => {
    wrapper = mountExtended(FilesTable, { propsData: { files, format, ...props } });
  };

  const findTable = () => wrapper.findComponent(GlTable);
  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findHeaders = () => wrapper.findAll('th').wrappers.map((th) => th.text());
  const findCells = (testId) => wrapper.findAllByTestId(testId).wrappers.map((cell) => cell.text());
  const findToggles = () => wrapper.findAllByTestId('toggle-checksums');
  const findChecksums = () => wrapper.findAllComponents(FileChecksums);
  const findAnnouncement = () => wrapper.findByTestId('checksums-announcement');

  it('names every file', () => {
    createComponent();

    expect(findCells('file-name')).toEqual(mockMavenFiles.map(({ fileName }) => fileName));
  });

  it('derives the type from the file name, and renders an unrecognized extension raw', () => {
    createComponent();

    expect(findCells('file-type')).toEqual(['jar', 'pom', 'sources', 'javadoc', 'xml']);
  });

  it('derives the npm tarball type', () => {
    createComponent({ files: mockNpmFiles, format: 'NPM' });

    expect(findCells('file-type')).toEqual(['tgz']);
  });

  it('renders each size in human units', () => {
    createComponent();

    expect(findCells('file-size')[0]).toBe('1.00 MiB');
  });

  it('renders no links, and no row action beyond the checksum disclosure', () => {
    createComponent();

    expect(findTable().findAll('a')).toHaveLength(0);
    expect(
      findTable()
        .findAll('button')
        .wrappers.map((button) => button.attributes('data-testid')),
    ).toEqual(mockMavenFiles.map(() => 'toggle-checksums'));
  });

  describe.each`
    format     | files             | created
    ${'MAVEN'} | ${mockMavenFiles} | ${0}
    ${'NPM'}   | ${mockNpmFiles}   | ${1}
  `('a $format version', ({ format, files, created }) => {
    beforeEach(() => createComponent({ files, format }));

    it('renders the same four columns', () => {
      expect(findHeaders()).toEqual(['File', 'Type', 'Size', 'Created']);
    });

    it('fills the Created cell only for a file carrying a timestamp', () => {
      expect(wrapper.findAllByTestId('file-created')).toHaveLength(created);
    });
  });

  describe('the checksum disclosure', () => {
    beforeEach(() => createComponent());

    it('offers a toggle on every row', () => {
      expect(findToggles()).toHaveLength(mockMavenFiles.length);
    });

    it('keeps the checksums out of the DOM until a row is toggled open', () => {
      expect(findChecksums()).toHaveLength(0);
    });

    it('stands a placeholder in for the toggle a file with no checksums cannot have', () => {
      const [first, ...rest] = mockMavenFiles;
      const unchecksummed = { ...first, md5: null, sha1: null, sha256: null, sha512: null };

      createComponent({ files: [unchecksummed, ...rest] });

      expect(findToggles()).toHaveLength(rest.length);
      expect(wrapper.findAllByTestId('toggle-placeholder')).toHaveLength(1);
    });

    it('discloses the toggled row alone', async () => {
      await findToggles().at(0).trigger('click');

      expect(findChecksums()).toHaveLength(1);
      expect(findChecksums().at(0).props('file')).toMatchObject({
        fileName: mockMavenFiles[0].fileName,
      });
    });

    it('names the row in the toggle, so the label reads on its own', () => {
      expect(findToggles().at(0).attributes('aria-label')).toBe(
        `Show checksums for ${mockMavenFiles[0].fileName}`,
      );
    });

    it('reports the collapsed state rather than omitting it', () => {
      expect(findToggles().at(0).attributes('aria-expanded')).toBe('false');
    });

    it("hands the disclosure the table's format, which decides the checksum set", async () => {
      await findToggles().at(0).trigger('click');

      expect(findChecksums().at(0).props('format')).toBe('MAVEN');
    });

    it('discloses a row whose MD5 the deploy never stored', async () => {
      const index = mockMavenFiles.findIndex(({ md5 }) => md5 === null);

      await findToggles().at(index).trigger('click');

      expect(findChecksums().at(0).find('[data-testid="file-checksum-md5"]').exists()).toBe(false);
      expect(findChecksums().at(0).find('[data-testid="file-checksum-sha1"]').exists()).toBe(true);
    });

    it("announces only the checksums that row holds, not the format's full set", async () => {
      const index = mockMavenFiles.findIndex(({ md5 }) => md5 === null);

      await findToggles().at(index).trigger('click');

      expect(findAnnouncement().text()).toBe(
        `Revealed SHA-1, SHA-256, SHA-512 for ${mockMavenFiles[index].fileName}.`,
      );
    });

    it('gives each disclosure its own panel id, so two open rows stay distinct', async () => {
      await findToggles().at(0).trigger('click');
      await findToggles().at(1).trigger('click');

      const ids = findToggles()
        .wrappers.slice(0, 2)
        .map((t) => t.attributes('aria-controls'));

      expect(new Set(ids).size).toBe(2);
      ids.forEach((id) => expect(wrapper.find(`#${id}`).exists()).toBe(true));
    });

    it('names the checksums it revealed, rather than leaving it a visual change', async () => {
      expect(findAnnouncement().text()).toBe('');

      await findToggles().at(0).trigger('click');

      expect(findAnnouncement().text()).toBe(
        `Revealed MD5, SHA-1, SHA-256, SHA-512 for ${mockMavenFiles[0].fileName}.`,
      );
    });

    it('falls silent when the row closes again, then announces afresh on reopening', async () => {
      await findToggles().at(0).trigger('click');
      await findToggles().at(0).trigger('click');

      expect(findAnnouncement().text()).toBe('');

      await findToggles().at(0).trigger('click');

      expect(findAnnouncement().text()).toBe(
        `Revealed MD5, SHA-1, SHA-256, SHA-512 for ${mockMavenFiles[0].fileName}.`,
      );
    });

    it('leaves a second open row open when the first one closes', async () => {
      await findToggles().at(0).trigger('click');
      await findToggles().at(1).trigger('click');
      await findToggles().at(0).trigger('click');

      expect(findChecksums()).toHaveLength(1);
      expect(findChecksums().at(0).props('file')).toMatchObject({
        fileName: mockMavenFiles[1].fileName,
      });
      expect(findToggles().at(1).attributes('aria-expanded')).toBe('true');
      expect(findAnnouncement().text()).toBe('');
    });

    it('drops the row border so the row and its checksums read as one block', async () => {
      const cells = () => [...findToggles().at(0).element.closest('tr').querySelectorAll('td')];
      const allHave = (cls) => cells().every((td) => td.classList.contains(cls));

      expect(cells()).toHaveLength(4);
      expect(allHave('@md:!gl-border-b-0')).toBe(false);

      await findToggles().at(0).trigger('click');

      expect(allHave('@md:!gl-border-b-0')).toBe(true);

      await findToggles().at(0).trigger('click');

      expect(allHave('@md:!gl-border-b-0')).toBe(false);
    });

    it('keeps the base cell class in both states, which the disclosed class composes with', async () => {
      const cells = () => [...findToggles().at(0).element.closest('tr').querySelectorAll('td')];
      const allHave = (cls) => cells().every((td) => td.classList.contains(cls));

      expect(allHave('!gl-align-middle')).toBe(true);

      await findToggles().at(0).trigger('click');

      expect(allHave('!gl-align-middle')).toBe(true);
    });

    it('reports the expanded state and points at the panel it opened', async () => {
      const toggle = findToggles().at(0);

      await toggle.trigger('click');

      expect(toggle.attributes('aria-expanded')).toBe('true');
      expect(toggle.attributes('aria-label')).toBe(
        `Hide checksums for ${mockMavenFiles[0].fileName}`,
      );
      expect(wrapper.find(`#${toggle.attributes('aria-controls')}`).exists()).toBe(true);
    });
  });

  describe('when a further page replaces the rows', () => {
    beforeEach(async () => {
      createComponent();

      await findToggles().at(0).trigger('click');
      await wrapper.setProps({ files: mockMavenFiles.slice(1) });
    });

    it('collapses the disclosure rather than carrying it over to another file', () => {
      expect(findChecksums()).toHaveLength(0);
      expect(findToggles().at(0).attributes('aria-expanded')).toBe('false');
    });

    it('silences the announcement, so it cannot name a file the page no longer lists', () => {
      expect(findAnnouncement().text()).toBe('');
    });
  });

  describe('the checksum disclosure on an npm table', () => {
    beforeEach(() => createComponent({ files: mockNpmFiles, format: 'NPM' }));

    it('discloses the single checksum the format stores', async () => {
      await findToggles().at(0).trigger('click');

      expect(findChecksums().at(0).props('format')).toBe('NPM');
      expect(findChecksums().at(0).findAll('[data-testid="checksum-label"]')).toHaveLength(1);
    });

    it('names only that checksum in the announcement', async () => {
      await findToggles().at(0).trigger('click');

      expect(findAnnouncement().text()).toBe(`Revealed SHA-256 for ${mockNpmFiles[0].fileName}.`);
    });
  });

  describe('a row carrying no checksum at all', () => {
    const bare = { ...mockMavenFiles[0], md5: null, sha1: null, sha256: null, sha512: null };

    beforeEach(() => createComponent({ files: [bare] }));

    it('offers no toggle, so nothing points at a panel that never renders', () => {
      expect(findToggles()).toHaveLength(0);
      expect(wrapper.findByTestId('file-name').text()).toBe(bare.fileName);
    });
  });

  describe('while a further page is in flight', () => {
    it('marks the table busy and stands a spinner in place of the rows', () => {
      createComponent({ isLoading: true });

      expect(findLoadingIcon().exists()).toBe(true);
      expect(findTable().attributes('aria-busy')).toBe('true');
    });
  });
});
