import { sprintf, s__ } from '~/locale';
import { toNounSeriesText } from '~/lib/utils/grammar';
import { visibleFields } from './helpers';

const blank = (value) => {
  if (Array.isArray(value)) return value.length === 0;
  if (typeof value === 'string') return value.trim() === '';
  if (value && typeof value === 'object') return Object.keys(value).length === 0;

  return value === undefined || value === null;
};

/**
 * The first meaningful statement of a program, with `#` comments stripped —
 * the same reading the store's transpiler applies to Rego. Shared with the
 * catalog guard specs so "first statement" has a single definition.
 *
 * @param {string} value - The program source.
 * @returns {string|undefined}
 */
export const firstStatement = (value) =>
  String(value ?? '')
    .split('\n')
    .map((line) => line.replace(/#.*/, '').trim())
    .find(Boolean);

const fieldLabel = (entry, key) =>
  (entry.fields ?? []).find((field) => field.key === key)?.label ?? key;

const visibleKeys = (entry, config, keys) => {
  const shown = new Set(visibleFields(entry.fields ?? [], config).map((field) => field.key));

  return keys.filter((key) => shown.has(key));
};

// sprintf must not escape: the sentences render through `{{ }}`, so escaping
// here would show entities for translated labels like "Noms d'environnement".
const requiredMessage = (entry, field) =>
  sprintf(
    s__('PolicyStore|%{rule} is missing %{field}.'),
    { rule: entry.label, field: field.label },
    false,
  );

const firstStatementMessage = (entry, field) =>
  sprintf(
    s__('PolicyStore|%{field} in %{rule} must open with %{statement}.'),
    { rule: entry.label, field: field.label, statement: field.firstStatement },
    false,
  );

const oneOfMessage = (entry, keys) =>
  sprintf(
    s__('PolicyStore|%{rule} needs at least one of: %{fields}.'),
    {
      rule: entry.label,
      fields: toNounSeriesText(
        keys.map((key) => fieldLabel(entry, key)),
        { onlyCommas: true },
      ),
    },
    false,
  );

// One reachable alternative is not a choice: "needs at least one of: Names" reads as a
// list of one, and repeats what the required check already said when that field is also
// required. Fall back to the plain missing-field sentence, or to nothing.
const oneOfBlockers = (entry, keys) => {
  if (keys.length > 1) return [oneOfMessage(entry, keys)];

  const field = (entry.fields ?? []).find(({ key }) => key === keys[0]);

  return field && !field.required ? [requiredMessage(entry, field)] : [];
};

const fieldBlockers = (entry, config) =>
  visibleFields(entry.fields ?? [], config).flatMap((field) => {
    const value = config[field.key];

    if (field.required && blank(value)) return [requiredMessage(entry, field)];
    if (field.firstStatement && !blank(value) && firstStatement(value) !== field.firstStatement) {
      return [firstStatementMessage(entry, field)];
    }

    return [];
  });

/**
 * Save blockers for the selected rules: human sentences naming what the
 * catalog declares as needed but the config does not satisfy. Declarations:
 * `required: true` on a field, `firstStatement` on a code field, and an
 * entry-level `requireOneOf` key set. The store refuses these shapes, so the
 * wizard blocks the submit instead of sending a known failure. A rule the
 * catalog does not know produces no blockers.
 *
 * @param {Array} catalog - RULES-shaped catalog entries.
 * @param {string[]} ruleIds - The selected rule ids.
 * @param {Object} ruleConfigs - Config objects keyed by rule id.
 * @returns {string[]}
 */
export const ruleConfigBlockers = (catalog, ruleIds, ruleConfigs = {}) =>
  ruleIds.flatMap((id) => {
    const entry = catalog.find((candidate) => candidate.id === id);

    if (!entry) return [];

    const config = ruleConfigs[id] ?? {};
    const blockers = fieldBlockers(entry, config);
    // Only the reachable keys: a requireOneOf naming fields the current config
    // hides would otherwise demand an answer with no control to give it.
    const reachable = visibleKeys(entry, config, entry.requireOneOf ?? []);

    if (reachable.length && reachable.every((key) => blank(config[key]))) {
      blockers.push(...oneOfBlockers(entry, reachable));
    }

    return blockers;
  });
