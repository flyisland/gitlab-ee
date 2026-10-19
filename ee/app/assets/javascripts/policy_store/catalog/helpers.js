import {
  FIELD_TYPE_CODE,
  FIELD_TYPE_FREEZE_WINDOWS,
  FIELD_TYPE_SETTING_VALUE,
} from '../components/editor/constants';

/**
 * The settings catalog entry a `setting_value` field is currently rendering, named by a
 * sibling field the catalog points it at through `settingKeyField`.
 *
 * @param {Object} field - A `setting_value` field definition.
 * @param {Object} config - The entry's current config, keyed by field key.
 * @returns {Object|undefined}
 */
export const settingFor = (field, config = {}) => field.settings?.[config[field.settingKeyField]];

// A `setting_value` field takes its choices from the selected setting, so a summary
// reading `field.options` would show a stored id where every other field shows a label.
const labelSourceFor = (field, config) =>
  field.type === FIELD_TYPE_SETTING_VALUE
    ? { ...field, options: settingFor(field, config)?.options }
    : field;

/**
 * The fields a config should render, honouring an optional
 * `showIf: { key, in: [...] }` naming a sibling and the values that reveal this field.
 * A hidden field is not rendered, validated, displayed or kept. Matching is by identity,
 * so the sibling must be scalar-valued and not itself conditional; catalog_spec rejects both.
 *
 * @param {Array} fields - A catalog entry's field definitions.
 * @param {Object} config - The entry's current config, keyed by field key.
 * @returns {Array}
 */
export const visibleFields = (fields = [], config = {}) =>
  fields.filter(({ showIf }) => !showIf || showIf.in.includes(config[showIf.key]));

/**
 * The keys `visibleFields` hides for this config. The editor drops these when a field goes
 * hidden, but a value that arrived already hidden survives until some control is touched —
 * so the serializer applies them again on the way out.
 *
 * Only add a `showIf` to a field introduced in the same release: on one with persisted
 * values the next save silently drops whatever the condition hides, so an existing field
 * needs a migration instead.
 *
 * @param {Array} fields - A catalog entry's field definitions.
 * @param {Object} config - The entry's current config, keyed by field key.
 * @returns {string[]}
 */
export const hiddenFieldKeys = (fields = [], config = {}) => {
  const shown = new Set(visibleFields(fields, config).map(({ key }) => key));

  return fields.map(({ key }) => key).filter((key) => !shown.has(key));
};

const configEntryLabel = (field, entry) => {
  if (field.type === FIELD_TYPE_FREEZE_WINDOWS) {
    // Not ', ': that separator already divides one window from the next, so a
    // multi-tier window would blur into the window after it.
    const tiers = (entry.tiers || [])
      .map((tier) => field.options?.find((option) => option.id === tier)?.label ?? tier)
      .join(' / ');
    const bounds = [entry.starts_at, entry.ends_at].filter(Boolean).join(' → ');

    return [entry.name, tiers, bounds].filter(Boolean).join(' · ');
  }

  return field.options?.find((option) => option.id === entry)?.label ?? String(entry);
};

const configValueFor = (field, value) => {
  const values = Array.isArray(value) ? value : [value];
  const labelled = values
    .filter((entry) => entry !== undefined && entry !== null && entry !== '')
    .map((entry) => configEntryLabel(field, entry))
    .filter(Boolean);

  return labelled.join(', ');
};

/**
 * Resolves an entry's persisted config into displayable items through the
 * catalog's field definitions, mirroring what the editor's form shows.
 */
export const configItemsFor = (entry, config = {}) =>
  visibleFields(entry.fields || [], config)
    .map((field) => ({
      key: field.key,
      label: field.label,
      code: field.type === FIELD_TYPE_CODE,
      value: configValueFor(labelSourceFor(field, config), config[field.key]),
    }))
    .filter(({ value }) => value !== '');

// A persisted id the catalog no longer knows still resolves to its raw id
// rather than disappearing from read-only summaries.
export const resolveCatalogEntry = (catalog, id, config = {}) => {
  const entry = catalog.find((candidate) => candidate.id === id) ?? {
    id,
    label: id,
    description: '',
    icon: 'question-o',
  };

  return { ...entry, configItems: configItemsFor(entry, config) };
};
