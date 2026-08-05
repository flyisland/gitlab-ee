import Vue from 'vue';
import VueApollo from 'vue-apollo';
import VueRouter from 'vue-router';
import { getRoutes } from 'ee/groups/settings/work_items/routes';
import createDefaultClient from '~/lib/graphql';
import ProjectWorkItemSettings from './project_work_item_settings.vue';

Vue.use(VueApollo);

export const initProjectWorkItemSettings = () => {
  const el = document.querySelector('#js-project-work-item-settings');

  if (!el) {
    return null;
  }

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  const { basePath, fullPath } = el.dataset;

  return new Vue({
    el,
    router: new VueRouter({
      mode: 'history',
      base: basePath,
      routes: getRoutes(fullPath),
    }),
    apolloProvider,
    name: 'ProjectWorkItemSettings',
    render(createElement) {
      return createElement(ProjectWorkItemSettings, {
        props: {
          fullPath,
        },
      });
    },
  });
};
