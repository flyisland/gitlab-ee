import path from 'path';
import SKIP_CONFIG from '../skip_list';

const ROOT_PATH = path.resolve(__dirname, '../../../../');

const specEnv = global.jasmine.getEnv();

specEnv.specFilter = (spec) => {
  const currentSpecName = spec.getFullName();
  const currentTestFile = spec.result.testPath;

  const testPath = path.relative(ROOT_PATH, currentTestFile);
  const skipTestData = SKIP_CONFIG.by_case[testPath];

  if (typeof skipTestData !== 'undefined') {
    return !skipTestData.includes(currentSpecName);
  }
  return true;
};
