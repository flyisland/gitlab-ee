import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import LicenseCompliancePage from 'ee/merge_requests/reports/pages/license_compliance_page.vue';
import LicenseComplianceProvider from 'ee/merge_requests/reports/components/license_compliance_provider.vue';
import LicenseComplianceContent from 'ee/merge_requests/reports/pages/license_compliance_content.vue';

describe('LicenseCompliancePage', () => {
  let wrapper;

  const DEFAULT_MR_PROP = { id: 1 };

  const findProvider = () => wrapper.findComponent(LicenseComplianceProvider);
  const findContent = () => wrapper.findComponent(LicenseComplianceContent);

  const createComponent = () => {
    wrapper = shallowMountExtended(LicenseCompliancePage, {
      propsData: {
        mr: DEFAULT_MR_PROP,
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  it('renders LicenseComplianceProvider with mr prop', () => {
    expect(findProvider().props('mr')).toBe(DEFAULT_MR_PROP);
  });

  it('renders LicenseComplianceContent inside provider', () => {
    expect(findContent().exists()).toBe(true);
  });
});
