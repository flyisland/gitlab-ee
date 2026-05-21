import Vue from 'vue';
import MinimalAccessProvisioningAlert from './components/minimal_access_provisioning_alert.vue';

export const initMinimalAccessProvisioningAlert = () => {
  const el = document.querySelector('#js-minimal-access-provisioning-alert');

  if (!el) return false;

  const {
    dismissPath,
    affectedUsersCount,
    purchaseSeatsLink,
    learnMoreLink,
    restrictedAccessLink,
  } = el.dataset;

  return new Vue({
    el,
    name: 'MinimalAccessProvisioningAlertRoot',
    render(createElement) {
      return createElement(MinimalAccessProvisioningAlert, {
        props: {
          dismissPath,
          affectedUsersCount: parseInt(affectedUsersCount, 10),
          purchaseSeatsLink,
          learnMoreLink,
          restrictedAccessLink,
        },
      });
    },
  });
};
