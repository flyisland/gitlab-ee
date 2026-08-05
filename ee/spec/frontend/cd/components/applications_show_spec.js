import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import VueRouter from 'vue-router';
import { GlLoadingIcon } from '@gitlab/ui';
import createMockApollo from 'helpers/mock_apollo_helper';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import ApplicationsShow from 'ee/cd/components/applications_show.vue';
import OverviewCard from 'ee/cd/components/overview_card.vue';
import ServicesTable from 'ee/cd/components/services_table.vue';
import ReleasesTable from 'ee/cd/components/releases_table.vue';
import cdApplicationWithServicesQuery from 'ee/cd/graphql/cd_application_with_services.query.graphql';
import { routes } from 'ee/cd/router';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import { makeApplication, buildApplicationQueryResponse } from './mock_data';

Vue.use(VueApollo);
Vue.use(VueRouter);

const SECTION_KEYS = ['services', 'deployments', 'releases', 'links'];

// Explicit stub for <router-view>: the close/back wiring test emits those
// events on it, and Vue 2's auto-stubbed router-view is a functional component
// with no `vm` to emit from. The routed side panel is tested in
// service_side_panel_spec.js.
const RouterViewStub = { name: 'RouterViewStub', template: '<div data-testid="router-view" />' };

describe('ApplicationsShow', () => {
  let wrapper;
  let router;
  let defaultQueryHandler;

  beforeEach(() => {
    defaultQueryHandler = jest
      .fn()
      .mockResolvedValue(buildApplicationQueryResponse(makeApplication()));
  });

  // -- Finders --
  const findPageHeading = () => wrapper.findComponent(PageHeading);
  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findRouterView = () => wrapper.findComponent(RouterViewStub);
  const findNewReleaseButton = () => wrapper.findByTestId('new-release-button');
  const findOverviewCardsContainer = () => wrapper.findByTestId('overview-cards');
  const findOverviewCards = () => wrapper.findAllComponents(OverviewCard);
  const findServicesTables = () => wrapper.findAllComponents(ServicesTable);
  const findCard = (key) => wrapper.findByTestId(`${key}-card`);
  const findCardExpanded = (key) => wrapper.findByTestId(`${key}-card-expanded`);
  const findEmptyState = () => wrapper.findByTestId('applications-show-empty-state');
  const findErrorAlert = () => wrapper.findByTestId('applications-show-error-alert');

  const createRouter = (initialRoute = '/applications/5') => {
    // Use the real nested route config so tests exercise the actual wiring;
    // only the catch-all is swapped to the vue-router 4 form. <router-view> is
    // stubbed at mount, so the real routed page components are never rendered.
    const testRoutes = routes.map((route) =>
      route.path === '*' ? { ...route, path: '/:pathMatch(.*)*' } : route,
    );

    router = new VueRouter({ mode: 'abstract', routes: testRoutes });
    router.push(initialRoute);
    return router;
  };

  const createComponent = ({ queryHandler = defaultQueryHandler, route } = {}) => {
    wrapper = shallowMountExtended(ApplicationsShow, {
      propsData: { id: '5' },
      apolloProvider: createMockApollo([[cdApplicationWithServicesQuery, queryHandler]]),
      router: createRouter(route),
      stubs: { PageHeading, 'router-view': RouterViewStub },
    });
  };

  describe('while loading', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(true);
    });

    it('does not render the page heading', () => {
      expect(findPageHeading().exists()).toBe(false);
    });
  });

  describe('when the application is not found', () => {
    beforeEach(async () => {
      const handler = jest.fn().mockResolvedValue(buildApplicationQueryResponse(null));
      createComponent({ queryHandler: handler });
      await waitForPromises();
    });

    it('renders the empty state', () => {
      expect(findEmptyState().exists()).toBe(true);
    });

    it('does not render the page heading', () => {
      expect(findPageHeading().exists()).toBe(false);
    });

    it('does not render overview cards', () => {
      expect(findOverviewCardsContainer().exists()).toBe(false);
    });
  });

  describe('when the query errors', () => {
    beforeEach(async () => {
      const handler = jest.fn().mockRejectedValue(new Error('boom'));
      createComponent({ queryHandler: handler });
      await waitForPromises();
    });

    it('renders the error alert', () => {
      expect(findErrorAlert().exists()).toBe(true);
    });

    it('does not render the empty state', () => {
      expect(findEmptyState().exists()).toBe(false);
    });

    it('does not render overview cards', () => {
      expect(findOverviewCardsContainer().exists()).toBe(false);
    });
  });

  describe('after loading', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('fetches the application by id', () => {
      expect(defaultQueryHandler).toHaveBeenCalledTimes(1);
    });

    it('hides the loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });

    it('renders the application name in PageHeading', () => {
      expect(findPageHeading().props('heading')).toBe('My Application');
    });

    it('renders the overview cards container', () => {
      expect(findOverviewCardsContainer().exists()).toBe(true);
    });

    it('renders all four overview cards', () => {
      expect(findOverviewCards()).toHaveLength(4);
    });

    it('passes services to the collapsed services table', () => {
      const servicesTables = findServicesTables();

      expect(servicesTables).toHaveLength(1);
      expect(servicesTables.at(0).props('services')).toHaveLength(2);
      expect(servicesTables.at(0).props('full')).toBe(false);
    });

    it('passes the version sets to the collapsed releases table', () => {
      const releasesTable = findCard('releases').findComponent(ReleasesTable);

      expect(releasesTable.props('releases')).toHaveLength(2);
      expect(releasesTable.props('releases')[0].name).toBe('v1_1_0');
      expect(releasesTable.props('full')).toBe(false);
    });

    it('navigates to the release detail route when a release is selected', async () => {
      findCard('releases')
        .findComponent(ReleasesTable)
        .vm.$emit('select', { id: 'gid://gitlab/Cd::VersionSet/1', name: 'v1_1_0' });
      await waitForPromises();

      expect(router.currentRoute.name).toBe('release_detail_route');
      expect(router.currentRoute.params.releaseId).toBe('1');
    });

    it('marks the open release in the releases table while its panel is shown', async () => {
      findCard('releases')
        .findComponent(ReleasesTable)
        .vm.$emit('select', { id: 'gid://gitlab/Cd::VersionSet/1', name: 'v1_1_0' });
      await waitForPromises();

      expect(findCard('releases').findComponent(ReleasesTable).props('openId')).toBe(
        'gid://gitlab/Cd::VersionSet/1',
      );
    });
  });

  describe.each(SECTION_KEYS)('expand/collapse %s card', (sectionKey) => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('does not show expanded card initially', () => {
      expect(findCardExpanded(sectionKey).exists()).toBe(false);
    });

    describe('when expanded', () => {
      beforeEach(async () => {
        findCard(sectionKey).findComponent(OverviewCard).vm.$emit('toggle');
        await nextTick();
      });

      it('shows the expanded card', () => {
        expect(findCardExpanded(sectionKey).exists()).toBe(true);
      });

      it('keeps other cards visible', () => {
        const otherKeys = SECTION_KEYS.filter((k) => k !== sectionKey);

        otherKeys.forEach((key) => {
          expect(findCard(key).exists()).toBe(true);
        });
      });

      it('hides the collapsed card', () => {
        expect(findCard(sectionKey).exists()).toBe(false);
      });

      describe('when collapsed again', () => {
        beforeEach(async () => {
          findCardExpanded(sectionKey).findComponent(OverviewCard).vm.$emit('toggle');
          await nextTick();
        });

        it('hides expanded card', () => {
          expect(findCardExpanded(sectionKey).exists()).toBe(false);
        });

        it('shows collapsed card again', () => {
          expect(findCard(sectionKey).exists()).toBe(true);
        });
      });
    });
  });

  describe('services table props', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('passes full=true to the expanded services table', async () => {
      findCard('services').findComponent(OverviewCard).vm.$emit('toggle');
      await nextTick();

      const expandedTable = findCardExpanded('services').findComponent(ServicesTable);

      expect(expandedTable.exists()).toBe(true);
      expect(expandedTable.props('full')).toBe(true);
    });
  });

  describe('multi-expand', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('allows multiple cards to be expanded simultaneously', async () => {
      findCard('services').findComponent(OverviewCard).vm.$emit('toggle');
      await nextTick();

      findCard('deployments').findComponent(OverviewCard).vm.$emit('toggle');
      await nextTick();

      expect(findCardExpanded('services').exists()).toBe(true);
      expect(findCardExpanded('deployments').exists()).toBe(true);
      expect(findCard('releases').exists()).toBe(true);
      expect(findCard('links').exists()).toBe(true);
    });
  });

  describe('release panel', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('renders the "Build new release" button', () => {
      expect(findNewReleaseButton().exists()).toBe(true);
    });

    it('navigates to the new release route when the button is clicked', async () => {
      findNewReleaseButton().vm.$emit('click');
      await waitForPromises();

      expect(router.currentRoute.name).toBe('release_new_route');
    });
  });

  describe('when a release is created', () => {
    beforeEach(async () => {
      createComponent({ route: '/applications/5/releases/new' });
      await waitForPromises();

      findRouterView().vm.$emit('created', 'gid://gitlab/Cd::VersionSet/1');
      await waitForPromises();
    });

    it('returns to the overview route', () => {
      expect(router.currentRoute.name).toBe('applications_show_route');
    });

    it('expands the releases card', () => {
      expect(findCardExpanded('releases').exists()).toBe(true);
    });

    it('refetches the application', () => {
      expect(defaultQueryHandler).toHaveBeenCalledTimes(2);
    });

    it('highlights the new release in the releases table', () => {
      const table = findCardExpanded('releases').findComponent(ReleasesTable);

      expect(table.props('selectedId')).toBe('gid://gitlab/Cd::VersionSet/1');
    });
  });

  describe('when a deployment is triggered', () => {
    beforeEach(async () => {
      createComponent({ route: '/applications/5/releases/1' });
      await waitForPromises();

      findRouterView().vm.$emit('deploy-triggered');
      await waitForPromises();
    });

    it('returns to the overview route', () => {
      expect(router.currentRoute.name).toBe('applications_show_route');
    });

    it('refetches the application', () => {
      expect(defaultQueryHandler).toHaveBeenCalledTimes(2);
    });
  });

  describe('service side panel router-view', () => {
    it('renders a router-view to host the routed side panel', async () => {
      createComponent();
      await waitForPromises();

      expect(findRouterView().exists()).toBe(true);
    });

    it('navigates to the service detail route when a service row is selected', async () => {
      createComponent();
      await waitForPromises();

      findServicesTables().at(0).vm.$emit('select', { id: 'gid://gitlab/Cd::Service/10' });
      await waitForPromises();

      expect(router.currentRoute.name).toBe('service_detail_route');
      expect(router.currentRoute.params.serviceId).toBe('10');
    });

    it('navigates back to the parent route when the router-view emits close', async () => {
      createComponent({ route: '/applications/5/services/10' });
      await waitForPromises();
      expect(router.currentRoute.name).toBe('service_detail_route');

      findRouterView().vm.$emit('close');
      await waitForPromises();

      expect(router.currentRoute.name).toBe('applications_show_route');
      expect(router.currentRoute.params.serviceId).toBeUndefined();
    });
  });
});
