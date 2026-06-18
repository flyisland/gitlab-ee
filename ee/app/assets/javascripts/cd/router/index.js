import Vue from 'vue';
import VueRouter from 'vue-router';
import { s__ } from '~/locale';
import NestedRouteApp from '~/vue_shared/spa/components/router_view.vue';
import ApplicationsIndex from '../components/applications_index.vue';
import ApplicationsShow from '../components/applications_show.vue';
import EnvironmentsIndex from '../components/environments_index.vue';
import EnvironmentsShow from '../components/environments_show.vue';

Vue.use(VueRouter);

export const createRouter = (base) => {
  const baseTitle = document.title;

  const router = new VueRouter({
    base,
    mode: 'history',
    routes: [
      {
        component: NestedRouteApp,
        path: '/applications',
        meta: {
          text: s__('ContinuousDeployment|Applications'),
        },
        children: [
          {
            name: 'applications_index_route',
            path: '',
            component: ApplicationsIndex,
            meta: {
              title: s__('ContinuousDeployment|Applications'),
            },
          },
          {
            name: 'applications_show_route',
            path: ':id(\\d+)',
            component: ApplicationsShow,
            meta: {
              useId: true,
            },
          },
        ],
      },
      {
        component: NestedRouteApp,
        path: '/environments',
        meta: {
          text: s__('ContinuousDeployment|Environments'),
        },
        children: [
          {
            name: 'environments_index_route',
            path: '',
            component: EnvironmentsIndex,
            meta: {
              title: s__('ContinuousDeployment|Environments'),
            },
          },
          {
            name: 'environments_show_route',
            path: ':id(\\d+)',
            component: EnvironmentsShow,
            meta: {
              useId: true,
            },
          },
        ],
      },
      { path: '*', redirect: '/applications' },
    ],
  });

  router.afterEach((to) => {
    const isItemPage = to.matched.some((route) => route.meta?.useId);

    if (!isItemPage && to.meta.title) {
      document.title = `${to.meta.title} · ${baseTitle}`;
    }
  });

  return router;
};
