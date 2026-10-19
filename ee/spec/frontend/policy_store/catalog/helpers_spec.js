import { configItemsFor, hiddenFieldKeys, visibleFields } from 'ee/policy_store/catalog/helpers';

describe('visibleFields', () => {
  const plain = { key: 'mode', type: 'select', label: 'Mode' };
  const conditional = {
    key: 'names',
    type: 'text',
    label: 'Names',
    showIf: { key: 'mode', in: ['detailed'] },
  };
  const fields = [plain, conditional];

  it('keeps a field that declares no showIf', () => {
    expect(visibleFields([plain], {})).toEqual([plain]);
  });

  it('hides a conditional field while the sibling does not match', () => {
    expect(visibleFields(fields, { mode: 'simple' })).toEqual([plain]);
  });

  it('shows a conditional field once the sibling matches', () => {
    expect(visibleFields(fields, { mode: 'detailed' })).toEqual(fields);
  });

  it('hides a conditional field while the sibling is unanswered', () => {
    expect(visibleFields(fields, {})).toEqual([plain]);
  });

  it('matches any of several listed values', () => {
    const anyOf = [{ ...conditional, showIf: { key: 'mode', in: ['warn', 'enforce'] } }];

    expect(visibleFields(anyOf, { mode: 'warn' })).toHaveLength(1);
    expect(visibleFields(anyOf, { mode: 'enforce' })).toHaveLength(1);
    expect(visibleFields(anyOf, { mode: 'audit' })).toHaveLength(0);
  });

  it('matches a boolean sibling by identity', () => {
    const onChecked = [{ ...conditional, showIf: { key: 'mode', in: [true] } }];

    expect(visibleFields(onChecked, { mode: true })).toHaveLength(1);
    expect(visibleFields(onChecked, { mode: false })).toHaveLength(0);
  });

  // Documented limits, guarded in catalog_spec so no entry can rely on them.
  describe('limits the catalog guard enforces', () => {
    it('never matches an array-valued sibling, since comparison is by identity', () => {
      const onArray = [{ ...conditional, showIf: { key: 'tiers', in: [['production']] } }];

      expect(visibleFields(onArray, { tiers: ['production'] })).toHaveLength(0);
    });

    it('resolves a chained showIf against the raw config, not the parent visibility', () => {
      const chained = [
        { key: 'a', type: 'select', label: 'A' },
        { key: 'b', type: 'select', label: 'B', showIf: { key: 'a', in: ['yes'] } },
        { key: 'c', type: 'text', label: 'C', showIf: { key: 'b', in: ['deep'] } },
      ];

      // `b` is hidden, yet a stale `b` still reveals `c` — the single-pass behaviour.
      expect(visibleFields(chained, { a: 'no', b: 'deep' }).map(({ key }) => key)).toEqual([
        'a',
        'c',
      ]);
    });
  });

  it('defaults to an empty list when given no fields', () => {
    expect(visibleFields()).toEqual([]);
  });
});

describe('hiddenFieldKeys', () => {
  const plain = { key: 'mode', type: 'select', label: 'Mode' };
  const conditional = {
    key: 'names',
    type: 'text',
    label: 'Names',
    showIf: { key: 'mode', in: ['detailed'] },
  };
  const fields = [plain, conditional];

  it('is empty when every field is visible', () => {
    expect(hiddenFieldKeys(fields, { mode: 'detailed' })).toEqual([]);
  });

  it('names the fields a showIf currently hides', () => {
    expect(hiddenFieldKeys(fields, { mode: 'simple' })).toEqual(['names']);
  });

  it('is empty for an entry that declares no fields', () => {
    expect(hiddenFieldKeys(undefined, undefined)).toEqual([]);
  });
});

describe('configItemsFor', () => {
  const entry = {
    fields: [
      { key: 'mode', type: 'select', label: 'Mode', options: [{ id: 'simple', label: 'Simple' }] },
      {
        key: 'names',
        type: 'text',
        label: 'Names',
        showIf: { key: 'mode', in: ['detailed'] },
      },
    ],
  };

  // The read-only views must show what the editor showed, or an author sees a value on
  // the detail page for a control the form never rendered.
  it('omits a hidden field even when the config still carries its value', () => {
    const items = configItemsFor(entry, { mode: 'simple', names: 'left over' });

    expect(items.map(({ key }) => key)).toEqual(['mode']);
  });

  it('includes the field once it is revealed', () => {
    const items = configItemsFor(entry, { mode: 'detailed', names: 'prod' });

    expect(items.map(({ key }) => key)).toEqual(['mode', 'names']);
  });
});

describe('configItemsFor with a setting_value field', () => {
  const entry = {
    fields: [
      { key: 'settingKey', type: 'searchable_select', label: 'Setting' },
      {
        key: 'value',
        type: 'setting_value',
        label: 'Required value',
        settingKeyField: 'settingKey',
        settings: {
          project_visibility: {
            valueType: 'enum',
            options: [{ id: 'private', label: 'Private' }],
          },
        },
      },
    ],
  };

  it('labels the value through the selected setting rather than the raw stored id', () => {
    const items = configItemsFor(entry, { settingKey: 'project_visibility', value: 'private' });

    expect(items.find(({ key }) => key === 'value').value).toBe('Private');
  });

  it('falls back to the stored value when no setting is selected', () => {
    const items = configItemsFor(entry, { value: 'private' });

    expect(items.find(({ key }) => key === 'value').value).toBe('private');
  });
});
