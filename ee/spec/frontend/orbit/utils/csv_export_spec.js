import Papa from 'papaparse';
import { downloadCsv } from 'ee/orbit/utils/csv_export';
import { flattenNodesToRows } from 'ee/orbit/utils/graph_transform';

jest.mock('ee/orbit/utils/graph_transform');

describe('downloadCsv', () => {
  let createElementSpy;
  let clickSpy;
  let anchorEl;

  beforeEach(() => {
    clickSpy = jest.fn();
    anchorEl = { click: clickSpy };
    createElementSpy = jest.spyOn(document, 'createElement').mockReturnValue(anchorEl);
    URL.revokeObjectURL = jest.fn();
  });

  afterEach(() => {
    createElementSpy.mockRestore();
  });

  const response = {
    nodes: [
      { type: 'User', id: 1, username: 'admin' },
      { type: 'User', id: 2, username: 'dev' },
    ],
  };

  it('generates a CSV and triggers a download', () => {
    flattenNodesToRows.mockReturnValue([
      { type: 'User', id: 1, username: 'admin' },
      { type: 'User', id: 2, username: 'dev' },
    ]);

    downloadCsv(response);

    expect(createElementSpy).toHaveBeenCalledWith('a');
    expect(anchorEl.href).toContain('blob:');
    expect(anchorEl.download).toBe('orbit-results.csv');
    expect(clickSpy).toHaveBeenCalled();
    expect(URL.revokeObjectURL).toHaveBeenCalled();
  });

  it('uses a custom filename when provided', () => {
    flattenNodesToRows.mockReturnValue([{ type: 'User', id: 1 }]);

    downloadCsv(response, 'custom.csv');

    expect(anchorEl.download).toBe('custom.csv');
  });

  it('does nothing when flattened rows are empty', () => {
    flattenNodesToRows.mockReturnValue([]);

    downloadCsv(response);

    expect(createElementSpy).not.toHaveBeenCalledWith('a');
    expect(clickSpy).not.toHaveBeenCalled();
  });

  it('generates correct headers from node properties', () => {
    const rows = [{ type: 'User', id: 1, username: 'admin', email: 'a@b.com' }];
    flattenNodesToRows.mockReturnValue(rows);

    const unparseSpy = jest.spyOn(Papa, 'unparse');

    downloadCsv(response);

    const csvArg = unparseSpy.calls?.[0]?.[0] ?? unparseSpy.mock.calls[0][0];
    const headers = Object.keys(csvArg[0]);

    expect(headers).toEqual(['type', 'id', 'username', 'email']);

    unparseSpy.mockRestore();
  });

  describe('formula injection protection', () => {
    it.each([
      ['=cmd()', "'\\'=cmd()'"],
      ['+1234', "'\\'\\+1234'"],
      ['-negative', "'\\'\\-negative'"],
      ['@mention', "'\\'@mention'"],
    ])('sanitizes value starting with %s', (input) => {
      flattenNodesToRows.mockReturnValue([{ value: input }]);

      const unparseSpy = jest.spyOn(Papa, 'unparse');

      downloadCsv(response);

      const sanitizedRow = unparseSpy.mock.calls[0][0][0];

      expect(sanitizedRow.value).toMatch(/^'/);

      unparseSpy.mockRestore();
    });

    it('does not prefix safe values', () => {
      flattenNodesToRows.mockReturnValue([{ value: 'hello' }]);

      const unparseSpy = jest.spyOn(Papa, 'unparse');

      downloadCsv(response);

      const sanitizedRow = unparseSpy.mock.calls[0][0][0];

      expect(sanitizedRow.value).toBe('hello');

      unparseSpy.mockRestore();
    });

    it('converts null and undefined to empty strings', () => {
      flattenNodesToRows.mockReturnValue([{ a: null, b: undefined }]);

      const unparseSpy = jest.spyOn(Papa, 'unparse');

      downloadCsv(response);

      const sanitizedRow = unparseSpy.mock.calls[0][0][0];

      expect(sanitizedRow.a).toBe('');
      expect(sanitizedRow.b).toBe('');

      unparseSpy.mockRestore();
    });
  });
});
