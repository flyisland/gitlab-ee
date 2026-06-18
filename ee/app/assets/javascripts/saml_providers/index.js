import Vue from 'vue';

import SamlSettingsForm from 'ee/saml_providers/saml_settings_form';
import initSamlMembershipRoleSelector from 'ee/saml_providers/saml_membership_role_selector';
import { initScimTokenApp } from 'ee/saml_providers/scim_token';

import MembersApp from './saml_members/index.vue';
import createStore from './saml_members/store';

function initMembers(el) {
  const { groupId } = el.dataset;
  const store = createStore({
    groupId: Number(groupId),
  });
  // eslint-disable-next-line no-new
  new Vue({
    el,
    name: 'MembersAppRoot',
    store,
    render(createElement) {
      return createElement(MembersApp);
    },
  });
}

export function initSamlProvidersApp() {
  const membersEl = document.querySelector('.js-saml-members');
  initMembers(membersEl);

  initSamlMembershipRoleSelector();
  new SamlSettingsForm('#js-saml-settings-form').init();
  initScimTokenApp();
}
