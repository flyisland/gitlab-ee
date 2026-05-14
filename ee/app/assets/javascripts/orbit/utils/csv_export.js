// Exports query results as a sanitized CSV file download.
import Papa from 'papaparse';
import { flattenNodesToRows } from './graph_transform';

const FORMULA_PREFIX = /^[=+\-@]/;

function sanitizeValue(val) {
  const str = String(val ?? '');
  return FORMULA_PREFIX.test(str) ? `'${str}` : str;
}

/** Flattens a query response into sanitized CSV rows ready for export. */
export function prepareCsvRows(response) {
  const rows = flattenNodesToRows(response);
  if (!rows.length) return [];
  return rows.map((row) =>
    Object.fromEntries(Object.entries(row).map(([k, v]) => [k, sanitizeValue(v)])),
  );
}

/** Triggers a browser file download from a CSV string. */
export function triggerCsvDownload(csvString, filename = 'orbit-results.csv') {
  const blob = new Blob([csvString], { type: 'text/csv' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

/** Flattens a query response into sanitized CSV rows and triggers a browser download. */
export function downloadCsv(response, filename = 'orbit-results.csv') {
  const sanitized = prepareCsvRows(response);
  if (!sanitized.length) return;
  const csv = Papa.unparse(sanitized);
  triggerCsvDownload(csv, filename);
}
