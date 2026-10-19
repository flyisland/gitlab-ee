import {
  FIELD_TYPES,
  FIELD_TYPE_CHECKBOX,
  FIELD_TYPE_CODE,
  FIELD_TYPE_FREEZE_WINDOWS,
  FIELD_TYPE_MULTI_BADGE,
  FIELD_TYPE_NUMBER,
  FIELD_TYPE_SEARCHABLE_SELECT,
  FIELD_TYPE_SELECT,
  FIELD_TYPE_SETTING_VALUE,
  FIELD_TYPE_TEXT,
  FIELD_TYPE_TEXTAREA,
  FIELD_TYPE_TEXT_LIST,
} from 'ee/policy_store/components/editor/constants';
import { ACTIONS } from 'ee/policy_store/catalog/actions';
import { CATEGORY_LABELS, CATEGORY_ORDER } from 'ee/policy_store/catalog/categories';
import { REGO_TEMPLATES } from 'ee/policy_store/catalog/rego_templates';
import { firstStatement } from 'ee/policy_store/catalog/validation';
import { RULES } from 'ee/policy_store/catalog/rules';
import { TRIGGERS } from 'ee/policy_store/catalog/triggers';

// Field types holding a single value, so `showIf.in.includes(...)` can match them.
const SCALAR_FIELD_TYPES = [
  FIELD_TYPE_TEXT,
  FIELD_TYPE_SELECT,
  FIELD_TYPE_SEARCHABLE_SELECT,
  FIELD_TYPE_CHECKBOX,
  FIELD_TYPE_NUMBER,
];

// How each field type's control says "no answer": `undefined`, or an empty '' / [] / false.
// Every FIELD_TYPES member must appear in exactly one of these, which is asserted below,
// so a new control cannot be added without deciding which it is.
const FIELD_TYPES_CLEARING_TO_UNDEFINED = [FIELD_TYPE_NUMBER, FIELD_TYPE_SETTING_VALUE];
const FIELD_TYPES_CLEARING_TO_EMPTY = [
  FIELD_TYPE_TEXT,
  FIELD_TYPE_TEXT_LIST,
  FIELD_TYPE_TEXTAREA,
  FIELD_TYPE_SELECT,
  FIELD_TYPE_SEARCHABLE_SELECT,
  FIELD_TYPE_CHECKBOX,
  FIELD_TYPE_MULTI_BADGE,
  FIELD_TYPE_FREEZE_WINDOWS,
  FIELD_TYPE_CODE,
];

// Spelled out rather than imported: this is the guard's own record of what
// setting_value_field.vue can draw, so adding a control there must be repeated here.
const SUPPORTED_VALUE_TYPES = ['boolean', 'enum', 'multi', 'numeric', 'text'];
const VALUE_TYPES_NEEDING_OPTIONS = ['enum', 'multi'];

const siblingOf = (entry, field) =>
  entry.fields.find(({ key }) => key === field.showIf.key && key !== field.key);

// The catalog is data, and a typo in it fails silently: ConfigWrapper renders nothing for an
// unknown field `type`, and a duplicated id shadows an entry. These assertions are the only
// thing standing between a mistyped catalog entry and a control that quietly disappears.
describe('policy store catalog', () => {
  // The default guard below is only as good as this partition: an unclassified new field
  // type would slip past it, taking the save/reload bug with it.
  it('classifies every field type by what its control clears to', () => {
    expect([...FIELD_TYPES_CLEARING_TO_UNDEFINED, ...FIELD_TYPES_CLEARING_TO_EMPTY].sort()).toEqual(
      [...FIELD_TYPES].sort(),
    );
  });

  describe.each([
    ['triggers', TRIGGERS],
    ['rules', RULES],
    ['actions', ACTIONS],
  ])('%s', (name, entries) => {
    it('is not empty', () => {
      expect(entries.length).toBeGreaterThan(0);
    });

    it('gives every entry a unique id', () => {
      const ids = entries.map(({ id }) => id);

      expect(new Set(ids).size).toBe(ids.length);
    });

    it('gives every entry an id, label, description, icon, category and fields', () => {
      entries.forEach((entry) => {
        expect(entry).toMatchObject({
          id: expect.any(String),
          label: expect.any(String),
          description: expect.any(String),
          icon: expect.any(String),
          category: expect.any(String),
          fields: expect.any(Array),
        });
      });
    });

    it('gives every field a unique key within its entry', () => {
      entries.forEach(({ fields }) => {
        const keys = fields.map(({ key }) => key);

        expect(new Set(keys).size).toBe(keys.length);
      });
    });

    // The serializer picks and omits config keys by name through lodash, which reads a
    // key containing a dot as a deep path. A field keyed `a.b` would restructure the
    // stored value instead of being carried across, and one named after an
    // Object.prototype member would be fabricated onto a config that never had it.
    it('keys every field with a plain identifier', () => {
      const badKeys = entries
        .flatMap(({ fields }) => fields.map(({ key }) => key))
        .filter((key) => !/^[A-Za-z][A-Za-z0-9_]*$/.test(key) || key in Object.prototype);

      expect(badKeys).toEqual([]);
    });

    // A mistyped key here would make the requirement unsatisfiable: the config
    // never carries the key, so validation.js would block saving forever.
    it('points requireOneOf only at keys the entry declares as fields', () => {
      const unknownKeys = entries.flatMap(({ fields, requireOneOf }) =>
        (requireOneOf ?? []).filter((key) => !fields.some((field) => field.key === key)),
      );

      expect(unknownKeys).toEqual([]);
    });

    it('never declares requireOneOf as an empty set', () => {
      const emptyDeclarations = entries.filter(
        ({ requireOneOf }) => requireOneOf && requireOneOf.length === 0,
      );

      expect(emptyDeclarations).toEqual([]);
    });

    // NumberField and SettingValueField clear themselves to `undefined`, and a key held
    // as `undefined` is dropped by JSON.stringify on save. A default on one of them would
    // survive being cleared only until the policy is saved and reloaded, then quietly come
    // back. Until a cleared value has a wire representation the backend reads as absent,
    // these types cannot carry one.
    it('declares no default on a field type that clears itself to undefined', () => {
      const withDefaults = entries.flatMap(({ id, fields }) =>
        fields
          .filter(
            ({ type, default: value }) =>
              FIELD_TYPES_CLEARING_TO_UNDEFINED.includes(type) && value !== undefined,
          )
          .map((field) => `${id}.${field.key}`),
      );

      expect(withDefaults).toEqual([]);
    });

    // No catalog entry declares a showIf yet, so the assertions over real data below pass
    // vacuously. Each guard is also run against inline fixtures, to prove that it fires on
    // the defect it names and stays quiet on a sound declaration.
    describe('showIf declarations', () => {
      const conditionals = entries.flatMap((entry) =>
        entry.fields
          .filter(({ showIf }) => showIf)
          .map((field) => ({ entry, field, sibling: siblingOf(entry, field) })),
      );

      const brokenBy = (guard) =>
        conditionals.filter(guard).map(({ entry, field }) => `${entry.id}.${field.key}`);

      it('names a sibling the same entry declares', () => {
        const guard = ({ sibling }) => !sibling;
        // A showIf naming its own field resolves to no sibling, which is why siblingOf
        // excludes it.
        const selfReferential = { key: 'a', showIf: { key: 'a', in: ['x'] } };

        expect(brokenBy(guard)).toEqual([]);
        expect(guard({ sibling: siblingOf({ fields: [selfReferential] }, selfReferential) })).toBe(
          true,
        );
        expect(guard({ sibling: { key: 'a' } })).toBe(false);
      });

      it('lists at least one value to match', () => {
        const guard = ({ field }) =>
          !Array.isArray(field.showIf.in) || field.showIf.in.length === 0;

        expect(brokenBy(guard)).toEqual([]);
        expect(guard({ field: { showIf: { in: [] } } })).toBe(true);
        // No `in` at all: visibleFields would throw rather than hide the field.
        expect(guard({ field: { showIf: { key: 'a' } } })).toBe(true);
        expect(guard({ field: { showIf: { in: ['x'] } } })).toBe(false);
      });

      // visibleFields matches by identity, so an array-valued sibling never compares equal
      // to anything in `in`.
      it('names a sibling whose value is a scalar', () => {
        const guard = ({ sibling }) => !SCALAR_FIELD_TYPES.includes(sibling?.type);

        expect(brokenBy(guard)).toEqual([]);
        expect(guard({ sibling: { type: FIELD_TYPE_MULTI_BADGE } })).toBe(true);
        expect(guard({ sibling: { type: FIELD_TYPE_SELECT } })).toBe(false);
      });

      // visibleFields is a single pass, so a sibling that is itself conditional would be
      // read from a value the author may never have seen.
      it('names a sibling that is not itself conditional', () => {
        const guard = ({ sibling }) => Boolean(sibling?.showIf);

        expect(brokenBy(guard)).toEqual([]);
        expect(guard({ sibling: { showIf: { key: 'c', in: ['y'] } } })).toBe(true);
        expect(guard({ sibling: { type: FIELD_TYPE_TEXT } })).toBe(false);
      });

      // CheckboxField renders `value ?? field.default ?? false`, so an undefaulted checkbox
      // shows unchecked while its value stays undefined, and a showIf on [false] would never
      // match until the author toggled the box twice.
      it('names a checkbox sibling that declares a default', () => {
        const guard = ({ sibling }) =>
          sibling?.type === FIELD_TYPE_CHECKBOX && sibling.default === undefined;

        expect(brokenBy(guard)).toEqual([]);
        expect(guard({ sibling: { type: FIELD_TYPE_CHECKBOX } })).toBe(true);
        expect(guard({ sibling: { type: FIELD_TYPE_CHECKBOX, default: true } })).toBe(false);
      });

      // A value absent from the sibling's own options can never be selected.
      it('matches only values the sibling can actually take', () => {
        const unmatchable = ({ field, sibling }) =>
          sibling?.options?.length
            ? (field.showIf.in ?? []).filter(
                (value) => !sibling.options.some(({ id }) => id === value),
              )
            : [];
        const unreachable = conditionals.flatMap(({ entry, field, sibling }) =>
          unmatchable({ field, sibling }).map(
            (value) => `${entry.id}.${field.key} -> ${sibling.key}=${value}`,
          ),
        );

        expect(unreachable).toEqual([]);
        expect(
          unmatchable({
            field: { showIf: { in: ['absent'] } },
            sibling: { options: [{ id: 'present' }] },
          }),
        ).toEqual(['absent']);
      });
    });

    // A setting_value field fails the same way a showIf does: silently. It picks its
    // control from the setting named by a sibling, so a mistyped settingKeyField leaves
    // the author with a permanent gap where the catalog promised a control, and the
    // clear-on-change watcher that never fires because the key is always undefined.
    describe('setting_value declarations', () => {
      const settingFields = entries.flatMap((entry) =>
        entry.fields
          .filter(({ type }) => type === FIELD_TYPE_SETTING_VALUE)
          .map((field) => ({
            entry,
            field,
            sibling: entry.fields.find(
              ({ key }) => key === field.settingKeyField && key !== field.key,
            ),
          })),
      );

      const brokenBy = (predicate) =>
        settingFields.filter(predicate).map(({ entry, field }) => `${entry.id}.${field.key}`);

      const settingsOf = ({ entry, field }) =>
        Object.entries(field.settings ?? {}).map(([key, setting]) => ({
          entry,
          field,
          key,
          setting,
        }));

      it('names a sibling the same entry declares', () => {
        expect(brokenBy(({ sibling }) => !sibling)).toEqual([]);
      });

      // The sibling holds one setting key, so an array-valued control could never
      // resolve to a single entry in the settings map.
      it('names a sibling whose value is a scalar', () => {
        expect(brokenBy(({ sibling }) => !SCALAR_FIELD_TYPES.includes(sibling?.type))).toEqual([]);
      });

      it('carries a non-empty settings map', () => {
        expect(brokenBy(({ field }) => !Object.keys(field.settings ?? {}).length)).toEqual([]);
      });

      it('declares only value types the field can draw a control for', () => {
        const unsupported = settingFields
          .flatMap(settingsOf)
          .filter(({ setting }) => !SUPPORTED_VALUE_TYPES.includes(setting.valueType))
          .map(
            ({ entry, field, key, setting }) =>
              `${entry.id}.${field.key}.${key}=${setting.valueType}`,
          );

        expect(unsupported).toEqual([]);
      });

      // String ids, because the control discards a stored value whose type does not match
      // the setting's: a numeric id would be dropped on every mount.
      it('gives every choice-carrying setting non-empty { id, label } options', () => {
        const broken = settingFields
          .flatMap(settingsOf)
          .filter(({ setting }) => VALUE_TYPES_NEEDING_OPTIONS.includes(setting.valueType))
          .filter(
            ({ setting }) =>
              !setting.options?.length ||
              setting.options.some(
                ({ id, label }) => typeof id !== 'string' || typeof label !== 'string',
              ),
          )
          .map(({ entry, field, key }) => `${entry.id}.${field.key}.${key}`);

        expect(broken).toEqual([]);
      });

      // A setting the sibling cannot offer is a control the author can never reach.
      it('maps only settings the sibling can actually select', () => {
        const unreachable = settingFields.flatMap(({ entry, field, sibling }) => {
          if (!sibling?.options?.length) return [];

          const selectable = sibling.options.map(({ id }) => id);

          return Object.keys(field.settings ?? {})
            .filter((key) => !selectable.includes(key))
            .map((key) => `${entry.id}.${field.key} -> ${sibling.key}=${key}`);
        });

        expect(unreachable).toEqual([]);
      });
    });

    // Category ids drive the drawer's grouping and sort order; the label map supplies
    // the displayed text. An id outside the order would sort unpredictably, and one
    // without a label would render as its raw id.
    it('gives every entry a category from the declared order, with a label', () => {
      entries.forEach(({ category }) => {
        expect(CATEGORY_ORDER).toContain(category);
        expect(CATEGORY_LABELS[category]).toEqual(expect.any(String));
      });
    });
  });

  // Flattened across all three catalogs: the field contract is the same wherever a field appears,
  // and triggers declare no fields, so asserting per-catalog would leave that block empty.
  describe('fields', () => {
    const allFields = [...TRIGGERS, ...RULES, ...ACTIONS].flatMap(({ fields }) => fields);

    it('has fields to check', () => {
      expect(allFields.length).toBeGreaterThan(0);
    });

    it('only uses field types ConfigWrapper can render', () => {
      allFields.forEach((field) => {
        expect(FIELD_TYPES).toContain(field.type);
      });
    });

    it('gives every field a key and a label', () => {
      allFields.forEach((field) => {
        expect(field).toMatchObject({ key: expect.any(String), label: expect.any(String) });
      });
    });

    it('gives every option-carrying field non-empty { id, label } options', () => {
      const withOptions = allFields.filter(({ type }) =>
        [
          FIELD_TYPE_SELECT,
          FIELD_TYPE_SEARCHABLE_SELECT,
          FIELD_TYPE_MULTI_BADGE,
          FIELD_TYPE_FREEZE_WINDOWS,
        ].includes(type),
      );

      expect(withOptions.length).toBeGreaterThan(0);

      withOptions.forEach(({ options }) => {
        expect(options.length).toBeGreaterThan(0);
        options.forEach((option) => {
          expect(option).toMatchObject({ id: expect.any(String), label: expect.any(String) });
        });
      });
    });

    // NumberField forwards min and max but no step, so a fractional bound makes every
    // integer a step mismatch, a non-finite bound is ignored and a reversed pair breaks the
    // spinner. None of the three blocks a save, so bounds must be whole numbers or omitted.
    it('declares no fractional, non-finite or reversed bounds on a number field', () => {
      const guard = ({ min, max }) =>
        [min, max].some((bound) => bound !== undefined && !Number.isInteger(bound)) || min > max;
      const badBounds = [...TRIGGERS, ...RULES, ...ACTIONS].flatMap(({ id, fields }) =>
        fields
          .filter(({ type }) => type === FIELD_TYPE_NUMBER)
          .filter(guard)
          .map(({ key }) => `${id}.${key}`),
      );

      expect(badBounds).toEqual([]);

      // No catalog entry declares a number field yet, so the assertion above is vacuous.
      expect(guard({ min: 10, max: 1 })).toBe(true);
      expect(guard({ min: 0.5, max: 10 })).toBe(true);
      expect(guard({ min: 1, max: NaN })).toBe(true);
      expect(guard({ min: 1, max: Infinity })).toBe(true);
      expect(guard({ min: '1', max: 10 })).toBe(true);
      expect(guard({ min: 1, max: null })).toBe(true);
      expect(guard({ min: 1, max: 10 })).toBe(false);
      expect(guard({ min: -10, max: -1 })).toBe(false);
      expect(guard({ min: undefined, max: undefined })).toBe(false);
    });
  });

  describe('categories', () => {
    // The drawer renders its groups in exactly this sequence; reordering is a UX change
    // and should fail a test rather than slip through. Literals rather than the
    // imported constants, so a mistyped constant value cannot agree with itself.
    it('presents the groups in this exact order', () => {
      expect(CATEGORY_ORDER).toEqual([
        'enforcement',
        'advanced',
        'general',
        'deployment',
        'security',
        'process',
        'ai',
        'ci_cd',
        'code',
        'compliance',
        'access',
        'integrations',
      ]);
    });

    it('gives every labelled category a place in the order', () => {
      Object.keys(CATEGORY_LABELS).forEach((category) => {
        expect(CATEGORY_ORDER).toContain(category);
      });
    });
  });

  describe('scope', () => {
    it('ships the deployment gate triggers and the project lifecycle triggers', () => {
      // The first three are Gitlab::PolicyStore::Triggers::ALL in the gitlab-policy-store
      // gem. The last four are not in the gem yet — they arrive with
      // https://gitlab.com/gitlab-org/gitlab/-/work_items/630150 — and are pinned here
      // because these are persisted wire values the frontend must not invent or rename.
      expect(TRIGGERS.map(({ id }) => id)).toEqual([
        'deployment_requested',
        'environment_advanced',
        'deployment_promoted',
        'project_settings_change_requested',
        'project_created',
        'project_transferred',
        'project_creation_requested',
      ]);
    });

    // `project_settings_drift_checked` is an evaluation the engine records rather than one
    // an author schedules, so https://gitlab.com/gitlab-org/gitlab/-/work_items/630150
    // keeps it out of the gem's authoring catalogue. Presenting it would offer a trigger
    // the store refuses to save.
    it('presents no engine-internal trigger', () => {
      expect(TRIGGERS.map(({ id }) => id)).not.toContain('project_settings_drift_checked');
    });

    it('ships the backend rules and the settings rule', () => {
      // The first three are Gitlab::PolicyStore::Rules::ALL in the gitlab-policy-store gem.
      // `setting_validation` is not in the gem yet — it arrives with
      // https://gitlab.com/gitlab-org/gitlab/-/work_items/630153 — and is pinned here
      // because these are persisted wire values the frontend must not invent or rename.
      expect(RULES.map(({ id }) => id)).toEqual([
        'custom',
        'calendar',
        'environment',
        'setting_validation',
      ]);
    });

    it('ships only the two enforcement actions', () => {
      expect(ACTIONS.map(({ id }) => id)).toEqual(['block', 'require_approval']);
    });

    it('pins the block action field keys, which are the persisted wire shape', () => {
      // The keys live inside the persisted action `value`, so renaming one changes what the
      // engine is handed. It reads the message from `message`, falling back to the retired
      // `blockMessage`. See https://gitlab.com/gitlab-org/gitlab/-/issues/628712.
      const block = ACTIONS.find(({ id }) => id === 'block');

      expect(block.fields.map(({ key }) => key)).toEqual(['message', 'overrideGroups']);
    });

    it('has no warn action, because warn is an enforcement mode', () => {
      expect(ACTIONS.map(({ id }) => id)).not.toContain('warn');
    });

    it('names the Rego rule `custom`, which is what the deployment gate reads back', () => {
      // EE::Ci::ProcessBuildService#rego_of finds `rule['type'] == 'custom'`.
      expect(RULES.map(({ id }) => id)).toContain('custom');
      expect(RULES.map(({ id }) => id)).not.toContain('rego');
    });
  });
});

// The store rejects a custom rule whose Rego does not open with
// `package governance`, so a template without it can never be saved.
describe('rego templates', () => {
  it.each(REGO_TEMPLATES.map(({ id, rego }) => [id, rego]))(
    'the %s template declares the governance package first',
    (id, rego) => {
      expect(firstStatement(rego)).toBe('package governance');
    },
  );
});
