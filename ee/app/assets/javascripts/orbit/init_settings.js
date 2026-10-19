import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { parseBoolean } from '@gitlab/frontend-utils';
import { initVueApp } from '~/lib/utils/vue3compat/init_vue_app';
import createDefaultClient from '~/lib/graphql';
import { initLazyHandRaiseLeadModal } from 'ee/hand_raise_leads/hand_raise_lead/init_lazy_hand_raise_lead_modal';
import GroupSettingsPage from './settings/group_settings_page.vue';
import AdminSettingsPage from './settings/admin/admin_settings_page.vue';
import { ADMIN_CACHE_CONFIG } from './settings/admin/graphql/cache_config';

Vue.use(VueApollo);

export default function initOrbitSettings() {
  const el = document.getElementById('js-orbit-settings');

  if (!el) return null;

  const { groupFullPath } = el.dataset;

  if (!groupFullPath) {
    const {
      settingsPath,
      overviewPath,
      schemaPath,
      newGroupPath,
      autoIndexEnabled,
      duoDefaultEnabled,
    } = el.dataset;

    return initVueApp({
      el,
      name: 'OrbitAdminSettingsRoot',
      apolloProvider: new VueApollo({
        defaultClient: createDefaultClient({}, { cacheConfig: ADMIN_CACHE_CONFIG }),
      }),
      component: AdminSettingsPage,
      props: {
        settingsPath,
        overviewPath,
        schemaPath,
        newGroupPath,
        autoIndexEnabled: parseBoolean(autoIndexEnabled),
        duoDefaultEnabled: parseBoolean(duoDefaultEnabled),
      },
    });
  }

  initLazyHandRaiseLeadModal(el);

  const { saas, duoAvailable, orbitPath, usageQuotasPath, duoSettingsPath } = el.dataset;

  return initVueApp({
    el,
    name: 'OrbitGroupSettingsRoot',
    apolloProvider: new VueApollo({ defaultClient: createDefaultClient() }),
    component: GroupSettingsPage,
    props: {
      groupFullPath,
      saas: parseBoolean(saas),
      duoAvailable: parseBoolean(duoAvailable),
      orbitPath,
      usageQuotasPath,
      duoSettingsPath,
    },
  });
}
