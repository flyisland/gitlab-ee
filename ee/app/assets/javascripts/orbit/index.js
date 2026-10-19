import Vue from 'vue';
import VueApollo from 'vue-apollo';
import VueRouter from 'vue-router';
import { parseBoolean } from '@gitlab/frontend-utils';
import { initVueApp } from '~/lib/utils/vue3compat/init_vue_app';
import createDefaultClient from '~/lib/graphql';
import OrbitDashboardApp from './dashboard/dashboard_app.vue';
import createDashboardRouter from './dashboard/router';

Vue.use(VueApollo);
Vue.use(VueRouter);

export default function initOrbit() {
  const el = document.getElementById('js-orbit-app');

  if (!el) return null;

  const {
    routerBase,
    gqlQueriesEnabled,
    adminConfigurationPath,
    duoAccessible,
    canAskDuoForQueries,
    orbitSettingsEnabled,
    trialAvailable,
    defaultGroupMissing,
    preferencesPath,
  } = el.dataset;

  return initVueApp({
    el,
    name: 'OrbitRoot',
    apolloProvider: new VueApollo({ defaultClient: createDefaultClient() }),
    router: createDashboardRouter(routerBase),
    component: OrbitDashboardApp,
    provide: {
      gqlQueriesEnabled: parseBoolean(gqlQueriesEnabled),
      canAskDuoForQueries: parseBoolean(canAskDuoForQueries),
      currentUserId: gon.current_user_id,
      trialAvailable: parseBoolean(trialAvailable),
      defaultGroupMissing: parseBoolean(defaultGroupMissing),
      preferencesPath,
    },
    props: {
      adminConfigurationPath,
      duoAccessible: parseBoolean(duoAccessible),
      orbitSettingsEnabled: parseBoolean(orbitSettingsEnabled),
    },
  });
}
