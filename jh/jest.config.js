const path = require('path');
const baseConfig = require('../jest.config.base');
const SKIP_CONFIG = require('./spec/frontend/skip_list');

const ROOT_PATH = path.resolve(__dirname, '..');

const config = {
  ...baseConfig('spec/frontend', {
    roots: ['<rootDir>/spec/frontend'],
    rootsEE: ['<rootDir>/ee/spec/frontend'],
    rootsJH: ['<rootDir>/jh/spec/frontend'],
  }),
};

function generateSkipList(globalConfig) {
  let globalIgnoreTestList = Array.isArray(globalConfig.testPathIgnorePatterns)
    ? globalConfig.testPathIgnorePatterns
    : [];

  if (SKIP_CONFIG) {
    const skipListJH = SKIP_CONFIG.by_file;
    globalIgnoreTestList = globalIgnoreTestList.concat(skipListJH);
  }

  return globalIgnoreTestList;
}

const ignoreTestList = generateSkipList(config);
(config.setupFiles ||= []).push(path.join(ROOT_PATH, 'jh/spec/frontend/setup/jh_setup.js'));
config.setupFilesAfterEnv.push(path.join(ROOT_PATH, 'jh/spec/frontend/setup/jh_test_setup.js'));
config.setupFilesAfterEnv.push(
  path.join(ROOT_PATH, 'spec/frontend/__helpers__/axios_mock_adapter_setup.js'),
);
config.coveragePathIgnorePatterns.push('<rootDir>/jh/app/assets/javascripts/subscriptions');

// @jihu-fe/svgs is the JH equivalent of @gitlab/svgs and ships untransformed
// SVGs that Jest needs to run through the static asset transformer.
config.transformIgnorePatterns = config.transformIgnorePatterns.map((pattern) =>
  pattern.replace('node_modules/(?!(', 'node_modules/(?!(@jihu-fe/svgs|'),
);

module.exports = {
  ...config,
  maxWorkers: 1, // limit jest worker because ci node resource limitation
  testPathIgnorePatterns: ignoreTestList,
};
