import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import GroupSecurityConfigurationApp from 'ee/security_configuration/components/app.vue';
import GroupScannersOverview from 'ee/security_configuration/components/scan_profiles/group_scanners_overview.vue';
import ConfigureAttributes from 'ee/security_configuration/components/security_attributes/configure_attributes.vue';

describe('ee/security_configuration/components/app (group)', () => {
  let wrapper;

  const createComponent = ({ provide } = {}) => {
    wrapper = shallowMountExtended(GroupSecurityConfigurationApp, {
      provide: {
        canManageAttributes: true,
        canReadScanProfiles: true,
        groupFullPath: 'group/path',
        securityInventoryPath: '/security/inventory',
        namespaceId: '1',
        glFeatures: {},
        ...provide,
      },
    });
  };

  const findGroupScannersOverview = () => wrapper.findComponent(GroupScannersOverview);
  const findConfigureAttributes = () => wrapper.findComponent(ConfigureAttributes);

  describe('Scanners tab', () => {
    describe('when groupSecurityConfigurationScannersTab feature flag is enabled', () => {
      describe('when canReadScanProfiles is true', () => {
        beforeEach(() => {
          createComponent({
            provide: { glFeatures: { groupSecurityConfigurationScannersTab: true } },
          });
        });

        it('renders GroupScannersOverview', () => {
          expect(findGroupScannersOverview().exists()).toBe(true);
        });
      });

      describe('when canReadScanProfiles is false', () => {
        it('does not render the Scanners tab', () => {
          createComponent({
            provide: {
              canReadScanProfiles: false,
              glFeatures: { groupSecurityConfigurationScannersTab: true },
            },
          });

          expect(findGroupScannersOverview().exists()).toBe(false);
        });
      });
    });

    describe('when groupSecurityConfigurationScannersTab feature flag is disabled', () => {
      it('does not render the Scanners tab', () => {
        createComponent({
          provide: { glFeatures: { groupSecurityConfigurationScannersTab: false } },
        });

        expect(findGroupScannersOverview().exists()).toBe(false);
      });
    });
  });

  describe('Security attributes tab', () => {
    describe('when canManageAttributes is true', () => {
      it('renders ConfigureAttributes', () => {
        createComponent();

        expect(findConfigureAttributes().exists()).toBe(true);
      });
    });

    describe('when canManageAttributes is false', () => {
      it('does not render the Security attributes tab', () => {
        createComponent({ provide: { canManageAttributes: false } });

        expect(findConfigureAttributes().exists()).toBe(false);
      });
    });
  });
});
