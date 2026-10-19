import { initVueApp } from '~/lib/utils/vue3compat/init_vue_app';
import initOrbit from 'ee/orbit';
import OrbitDashboardApp from 'ee/orbit/dashboard/dashboard_app.vue';
import createDashboardRouter from 'ee/orbit/dashboard/router';

jest.mock('~/lib/utils/vue3compat/init_vue_app');
jest.mock('ee/orbit/dashboard/router', () => jest.fn(() => 'dashboard-router'));

describe('initOrbit', () => {
  afterEach(() => {
    document.body.innerHTML = '';
  });

  describe('without the mount element', () => {
    it('mounts nothing', () => {
      expect(initOrbit()).toBe(null);
      expect(initVueApp).not.toHaveBeenCalled();
    });
  });

  describe('with the mount element', () => {
    beforeEach(() => {
      window.gon = { current_user_id: 7 };
      const el = document.createElement('div');
      el.id = 'js-orbit-app';
      Object.assign(el.dataset, {
        routerBase: '/dashboard/orbit',
        gqlQueriesEnabled: 'true',
        canAskDuoForQueries: 'false',
        duoAccessible: 'true',
        orbitSettingsEnabled: 'false',
        adminConfigurationPath: '/admin/orbit',
        trialAvailable: 'true',
        defaultGroupMissing: 'true',
        preferencesPath: '/p',
      });
      document.body.appendChild(el);
      initOrbit();
    });

    it('builds the router on the dashboard path', () => {
      expect(createDashboardRouter).toHaveBeenCalledWith('/dashboard/orbit');
    });

    it('mounts the dashboard app with its injected data and props', () => {
      expect(initVueApp).toHaveBeenCalledWith(
        expect.objectContaining({
          component: OrbitDashboardApp,
          router: 'dashboard-router',
          provide: expect.objectContaining({
            currentUserId: 7,
            gqlQueriesEnabled: true,
            canAskDuoForQueries: false,
            trialAvailable: true,
            defaultGroupMissing: true,
            preferencesPath: '/p',
          }),
          props: {
            adminConfigurationPath: '/admin/orbit',
            duoAccessible: true,
            orbitSettingsEnabled: false,
          },
        }),
      );
    });
  });
});
