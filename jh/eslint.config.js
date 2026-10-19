const plugin = require('@jihu-fe/eslint-plugin');

const jestConfig = {
  files: ['jh/spec/frontend/**/*.js'],

  settings: {
    // We have to teach eslint-plugin-import what node modules we use
    // otherwise there is an error when it tries to resolve them
    'import/core-modules': ['events', 'fs', 'path'],
    'import/resolver': {
      jest: {
        jestConfigFile: 'jest.config.js',
      },
    },
  },

  rules: {
    '@gitlab/vtu-no-explicit-wrapper-destroy': 'error',
    'jest/expect-expect': [
      'off',
      {
        assertFunctionNames: ['expect*', 'assert*', 'testAction'],
      },
    ],
    '@gitlab/no-global-event-off': 'off',
    'import/no-unresolved': [
      'off',
      // The test fixtures and graphql schema are dynamically generated in CI
      // during the `frontend-fixtures` and `graphql-schema-dump` jobs.
      // They may not be present during linting.
      {
        ignore: ['^test_fixtures/', 'tmp/tests/graphql/gitlab_schema.graphql'],
      },
    ],
  },
};

module.exports = [
  {
    plugins: { '@jihu-fe': plugin },
    files: ['jh/**/*.{js,vue}'], // Target specific files
    rules: {
      '@jihu-fe/prefer-ee-modules': 'error', // Disable the rule for these files
      'no-restricted-imports': 'off',
      'local-rules/vue-require-valid-help-page-link-component': 'off',
      'vue/require-name-property': 'off',
      'vue/v-on-event-hyphenation': 'off',
      'vue/custom-event-name-casing': 'off',
      'vue/no-deprecated-v-on-native-modifier': 'off',
      'vue/require-explicit-emits': 'off',
      '@gitlab/no-hardcoded-urls': 'off',
      '@gitlab/vue-no-hardcoded-urls': 'off',
      'local-rules/vue-require-vue-constructor-name': 'off',
      'local-rules/no-orphaned-feature-flag-references': 'off',
    },
  },
  jestConfig,
  {
    files: ['{,jh/}scripts/frontend/po_to_json.js'],
    rules: {
      '@gitlab/require-i18n-strings': 'off',
      'import/no-extraneous-dependencies': 'off',
      'import/no-commonjs': 'off',
      'import/no-nodejs-modules': 'off',
      'filenames/match-regex': 'off',
      'no-console': 'off',
    },
  },
  {
    files: ['jh/**/*.graphql'],
    rules: {
      'filenames/match-regex': 'off',
      'spaced-comment': 'off',
      '@graphql-eslint/no-anonymous-operations': 'off',
      '@graphql-eslint/unique-operation-name': 'off',
      '@graphql-eslint/require-id-when-available': 'off',
      '@graphql-eslint/no-unused-variables': 'off',
      '@graphql-eslint/no-unused-fragments': 'off',
      '@graphql-eslint/no-duplicate-fields': 'off',
      'vue/no-deprecated-v-bind-sync': 'off',
      'local-rules/graphql-require-feature-category': 'off',
    },
  },
  {
    files: [
      'jh/app/assets/javascripts/analytics/performance_analytics/components/performance_table.vue',
      'jh/app/assets/javascripts/performance_measurement/people_summary/components/summary_table.vue',
    ],
    rules: {
      'vue/no-deprecated-v-bind-sync': 'off',
      'no-restricted-imports': 'off',
      'import/no-extraneous-dependencies': 'off',
    },
  },
];
