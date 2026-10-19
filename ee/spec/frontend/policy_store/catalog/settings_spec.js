import { RULES } from 'ee/policy_store/catalog/rules';
import { SETTINGS, SETTINGS_BY_KEY, SETTING_OPTIONS } from 'ee/policy_store/catalog/settings';
import { settingFor } from 'ee/policy_store/catalog/helpers';
import { ruleConfigBlockers } from 'ee/policy_store/catalog/validation';

const settingValidation = () => RULES.find(({ id }) => id === 'setting_validation');

describe('policy store settings catalog', () => {
  it('keys every setting uniquely', () => {
    const keys = SETTINGS.map(({ key }) => key);

    expect(new Set(keys).size).toBe(keys.length);
  });

  it('gives every setting the contract 630152 defines', () => {
    SETTINGS.forEach((setting) => {
      expect(setting).toMatchObject({
        key: expect.any(String),
        label: expect.any(String),
        category: expect.any(String),
        valueType: expect.any(String),
        operators: expect.any(Array),
        enforceTreatment: expect.any(String),
        appliesTo: expect.any(Array),
      });
      expect(setting.operators.length).toBeGreaterThan(0);
      expect(setting.appliesTo.length).toBeGreaterThan(0);
    });
  });

  // The rule persists no operator and the serializer keeps only declared keys, so an entry
  // offering a second operator would promise a comparison no author can express or save.
  it('offers equality only, the one comparison the rule can author', () => {
    SETTINGS.forEach(({ operators }) => {
      expect(operators).toEqual(['=']);
    });
  });

  // Each key names a persisted project attribute and is rejected at save time if the
  // backend catalog does not know it
  // (https://gitlab.com/gitlab-org/gitlab/-/work_items/630152). Pinned at two while that
  // catalog is unfrozen, so adding one is a deliberate claim about the backend rather than
  // a guess.
  it('offers only settings that name a real project attribute', () => {
    expect(SETTINGS.map(({ key }) => key)).toEqual([
      'only_allow_merge_if_pipeline_succeeds',
      'secret_push_protection_enabled',
    ]);
  });

  describe('derived shapes', () => {
    it('offers one choice per setting, labelled', () => {
      expect(SETTING_OPTIONS).toEqual(SETTINGS.map(({ key, label }) => ({ id: key, label })));
    });

    it('resolves each key back to its own entry', () => {
      SETTINGS.forEach((setting) => {
        expect(SETTINGS_BY_KEY[setting.key]).toBe(setting);
      });
    });
  });

  describe('the setting_validation rule', () => {
    it('persists the setting key and the required value under 630153 field names', () => {
      expect(settingValidation().fields.map(({ key }) => key)).toEqual(['setting', 'value']);
    });

    it('draws its value control from the setting the author picked', () => {
      const [, value] = settingValidation().fields;

      expect(settingFor(value, { setting: 'secret_push_protection_enabled' })).toBe(
        SETTINGS_BY_KEY.secret_push_protection_enabled,
      );
    });

    it('blocks saving until a required value is given', () => {
      const config = { setting: 'secret_push_protection_enabled' };

      expect(
        ruleConfigBlockers(RULES, ['setting_validation'], { setting_validation: config }),
      ).toEqual(['Setting validation is missing Required value.']);
    });

    it('does not block once the value is answered', () => {
      const config = { setting: 'secret_push_protection_enabled', value: true };

      expect(
        ruleConfigBlockers(RULES, ['setting_validation'], { setting_validation: config }),
      ).toEqual([]);
    });

    // `false` is an answer, not an absence: a boolean setting required to be off would
    // otherwise be unsaveable.
    it('accepts false as an answer for a boolean setting', () => {
      const config = { setting: 'secret_push_protection_enabled', value: false };

      expect(
        ruleConfigBlockers(RULES, ['setting_validation'], { setting_validation: config }),
      ).toEqual([]);
    });
  });
});
