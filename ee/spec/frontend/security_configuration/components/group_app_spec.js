import { shallowMount } from '@vue/test-utils';
import { GlTab } from '@gitlab/ui';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import App from 'ee/security_configuration/components/app.vue';
import GroupScannersOverview from 'ee/security_configuration/components/scan_profiles/group_scanners_overview.vue';
import ConfigureAttributes from 'ee/security_configuration/components/security_attributes/configure_attributes.vue';

describe('Group Security configuration', () => {
  let wrapper;

  const findPageHeading = () => wrapper.findComponent(PageHeading);
  const findGroupScannersOverview = () => wrapper.findComponent(GroupScannersOverview);
  const findConfigureSecurityAttributes = () => wrapper.findComponent(ConfigureAttributes);

  const createComponent = ({ provide } = {}) => {
    wrapper = shallowMount(App, {
      stubs: {
        GlTab,
      },
      provide: {
        canManageAttributes: false,
        canReadScanProfiles: false,
        ...provide,
      },
    });
  };

  it('renders the page heading', () => {
    createComponent();

    expect(findPageHeading().props('heading')).toBe('Security configuration');
  });

  describe('Scanners tab', () => {
    it('renders GroupScannersOverview when canReadScanProfiles is true and feature flag is enabled', () => {
      createComponent({
        provide: {
          canReadScanProfiles: true,
          glFeatures: { groupSecurityConfigurationScannersTab: true },
        },
      });

      expect(findGroupScannersOverview().exists()).toBe(true);
    });

    it('does not render GroupScannersOverview when canReadScanProfiles is false', () => {
      createComponent();

      expect(findGroupScannersOverview().exists()).toBe(false);
    });
  });

  describe('Security attributes tab', () => {
    it('renders tab description and attribute configuration when canManageAttributes is true', () => {
      createComponent({ provide: { canManageAttributes: true } });

      expect(findConfigureSecurityAttributes().exists()).toBe(true);
    });

    it('does not render the Security attributes tab when canManageAttributes is false', () => {
      createComponent();

      expect(findConfigureSecurityAttributes().exists()).toBe(false);
    });
  });
});
