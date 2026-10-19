import path from 'path';

const ROOT_PATH = path.resolve(__dirname, '../../../../');

const injectTestFileMap = {
  'spec/frontend/repository/components/tree_content_spec.js': async () => {
    const appealApi = await import('jh/api/appeal_api');
    jest
      .spyOn(appealApi, 'getTreeContentBlockedState')
      .mockReturnValue(Promise.resolve({ data: null }));
  },
  'ee/spec/frontend/trials/components/trial_create_lead_form_spec.js': async () => {
    const provinceApi = await import('jh/api/province_api');

    jest
      .spyOn(provinceApi, 'getProvinces')
      .mockReturnValue(Promise.resolve({ data: ['United States', 'US'] }));
  },
};

beforeEach(() => {
  const testPath = path.relative(ROOT_PATH, global.jasmine.testPath);

  if (typeof injectTestFileMap[testPath] !== 'undefined') {
    injectTestFileMap[testPath]();
  }
});
