import { s__ } from '~/locale';
import { SETTING_VALUE_TYPE_BOOLEAN } from '../components/editor/constants';

// TEMPORARY FIXTURE. The settings catalog is owned by the backend and will be served over
// GraphQL by https://gitlab.com/gitlab-org/gitlab/-/work_items/630152. This file stands in
// until then and must be deleted, not extended, once that catalog is queryable: a key here
// that the backend does not know is rejected at save time
// (https://gitlab.com/gitlab-org/gitlab/-/work_items/630153), so the two lists silently
// disagreeing is the failure mode this comment exists to prevent.
//
// Every key below is a persisted project attribute whose name follows the project API's
// own, so the polarity an author sees is the polarity the project stores.
//
// Deliberately two booleans, not a representative sample. Every key here is a contract the
// backend has to accept, and 630152's catalog is not frozen yet, so a wider list would
// commit the editor to names nobody has agreed; a boolean also needs only the boolean
// branch of the value control. Widening happens by adopting the served catalog, not by
// adding entries here.
//
// Entries mirror 630152's contract — `key`, `category`, `valueType`, `options`, `operators`,
// `enforceTreatment`, `appliesTo` — narrowed in two places: every entry is `['project']`
// because the only trigger that pairs with this rule fires on an existing project, and
// every entry is equality-only (see OPERATORS). The real catalog will widen both, so
// adopting it means growing controls, not just swapping the data source.

const SETTING_CATEGORY_MERGE_CHECKS = 'merge_checks';
const SETTING_CATEGORY_SECURITY = 'security';

// `render` means the verdict is known as the form renders, so a control can be disabled up
// front; `save` settings only answer once the policy is saved, and none exist yet.
const TREATMENT_RENDER = 'render';

// Equality is the only operator the editor can author: the rule persists `{setting, value}`
// with no operator field, and serializer.js drops any key the catalog does not declare. An
// entry offering more would promise a comparison no author can express. Adding one means
// authoring `operator` as a rule field first.
const OPERATORS = ['='];

const booleanSetting = ({ key, label, category }) => ({
  key,
  label,
  category,
  valueType: SETTING_VALUE_TYPE_BOOLEAN,
  operators: OPERATORS,
  enforceTreatment: TREATMENT_RENDER,
  appliesTo: ['project'],
});

export const SETTINGS = [
  booleanSetting({
    key: 'only_allow_merge_if_pipeline_succeeds',
    label: s__('PolicyStore|Pipelines must succeed before merging'),
    category: SETTING_CATEGORY_MERGE_CHECKS,
  }),
  booleanSetting({
    key: 'secret_push_protection_enabled',
    label: s__('PolicyStore|Secret push protection is enabled'),
    category: SETTING_CATEGORY_SECURITY,
  }),
];

// The two shapes the catalog's consumers need: the choices a setting-key field offers, and
// the entry a `setting_value` field resolves its control from (catalog/helpers.js).
export const SETTING_OPTIONS = SETTINGS.map(({ key, label }) => ({ id: key, label }));

export const SETTINGS_BY_KEY = Object.fromEntries(
  SETTINGS.map((setting) => [setting.key, setting]),
);
