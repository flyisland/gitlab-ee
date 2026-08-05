import { GlBadge, GlSprintf } from '@gitlab/ui';
import { RouterLinkStub } from '@vue/test-utils';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import ProjectAvatar from '~/vue_shared/components/project_avatar.vue';
import ApplicationsList from 'ee/cd/components/applications_list.vue';
import { STATUS_DEGRADED, STATUS_DEPLOYING, STATUS_HEALTHY, STATUS_PENDING } from 'ee/cd/constants';
import { makeApplication as makeSharedApplication } from './mock_data';

describe('ApplicationsList', () => {
  let wrapper;

  const makeApplication = (config = {}) =>
    makeSharedApplication({
      id: 'gid://gitlab/Cd::Application/1',
      name: 'My App',
      updatedAt: '2024-01-15T10:00:00Z',
      status: STATUS_HEALTHY,
      ...config,
    });

  const findCards = () => wrapper.findAllByTestId('application-card');
  const findCardAt = (i) => findCards().at(i);
  const findCardLinks = () => wrapper.findAllByTestId('application-card-link');
  const findCardLinkAt = (i) => findCardLinks().at(i);

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(ApplicationsList, {
      propsData: {
        applications: [],
        ...props,
      },
      stubs: {
        RouterLink: RouterLinkStub,
        GlSprintf,
        TimeAgo,
      },
    });
  };

  describe('with no applications', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders no cards', () => {
      expect(findCards()).toHaveLength(0);
    });
  });

  describe('with applications', () => {
    const app1 = makeApplication({
      id: 'gid://gitlab/Cd::Application/1',
      name: 'Alpha',
      description: 'First app',
      updatedAt: '2020-04-01T00:00:00Z',
      status: STATUS_DEGRADED,
    });
    const app2 = makeApplication({
      id: 'gid://gitlab/Cd::Application/2',
      name: 'Beta',
      description: 'Second app',
      updatedAt: '2020-05-01T00:00:00Z',
      status: STATUS_DEPLOYING,
    });
    const app3 = makeApplication({
      id: 'app-3',
      name: 'Gamma',
      description: 'Third app',
      updatedAt: '2020-06-01T00:00:00Z',
      status: STATUS_HEALTHY,
    });
    const app4 = makeApplication({
      id: 'app-4',
      name: 'Zeta',
      description: 'Fourth app',
      updatedAt: '2020-07-01T00:00:00Z',
      status: STATUS_PENDING,
    });

    beforeEach(() => {
      createComponent({ applications: [app1, app2, app3, app4] });
    });

    it('renders one card per application', () => {
      expect(findCards()).toHaveLength(4);
    });

    it('renders project avatar', () => {
      expect(findCardAt(0).findComponent(ProjectAvatar).props('projectName')).toBe('Alpha');
      expect(findCardAt(1).findComponent(ProjectAvatar).props('projectName')).toBe('Beta');
      expect(findCardAt(2).findComponent(ProjectAvatar).props('projectName')).toBe('Gamma');
      expect(findCardAt(3).findComponent(ProjectAvatar).props('projectName')).toBe('Zeta');
    });

    it('renders the application name', () => {
      expect(findCardAt(0).find('h2').text()).toBe('Alpha');
      expect(findCardAt(1).find('h2').text()).toBe('Beta');
      expect(findCardAt(2).find('h2').text()).toBe('Gamma');
      expect(findCardAt(3).find('h2').text()).toBe('Zeta');
    });

    it('renders the status badge', () => {
      expect(findCardAt(0).findComponent(GlBadge).text()).toBe('Degraded');
      expect(findCardAt(0).findComponent(GlBadge).props('variant')).toBe('warning');
      expect(findCardAt(1).findComponent(GlBadge).text()).toBe('Deploying');
      expect(findCardAt(1).findComponent(GlBadge).props('variant')).toBe('info');
      expect(findCardAt(2).findComponent(GlBadge).text()).toBe('Healthy');
      expect(findCardAt(2).findComponent(GlBadge).props('variant')).toBe('success');
      expect(findCardAt(3).findComponent(GlBadge).text()).toBe('Approval needed');
      expect(findCardAt(3).findComponent(GlBadge).props('variant')).toBe('warning');
    });

    it('renders the status description', () => {
      expect(findCardAt(0).text()).toContain('Degradation detected');
      expect(findCardAt(1).text()).toContain('Deployment in progress');
      expect(findCardAt(2).text()).toContain('All systems healthy');
      expect(findCardAt(3).text()).toContain('Waiting for your approval');
    });

    it('renders the formatted updated-at time', () => {
      expect(findCardAt(0).text()).toContain('3 months ago');
      expect(findCardAt(1).text()).toContain('2 months ago');
      expect(findCardAt(2).text()).toContain('1 month ago');
      expect(findCardAt(3).text()).toContain('5 days ago');
    });

    it('render a router-link for each card', () => {
      expect(findCardLinks()).toHaveLength(4);
    });

    it('sets the correct route for each link', () => {
      expect(findCardLinkAt(0).props('to')).toEqual({
        name: 'applications_show_route',
        params: { id: '1' },
      });
      expect(findCardLinkAt(1).props('to')).toEqual({
        name: 'applications_show_route',
        params: { id: '2' },
      });
    });
  });

  describe('with null updatedAt', () => {
    beforeEach(() => {
      createComponent({
        applications: [makeApplication({ updatedAt: null })],
      });
    });

    it('does not render updated-at text when updatedAt is null', () => {
      expect(wrapper.findByTestId('application-updated-at').exists()).toBe(false);
    });
  });
});
