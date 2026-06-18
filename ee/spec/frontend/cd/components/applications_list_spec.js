import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import ApplicationsList from 'ee/cd/components/applications_list.vue';

describe('ApplicationsList', () => {
  let wrapper;

  const makeApplication = (config = {}) => ({
    id: 'app-1',
    name: 'My App',
    description: 'An application',
    group: { id: 'group-1', name: 'My Group' },
    updatedAt: '2024-01-15T10:00:00Z',
    ...config,
  });

  const findCards = () => wrapper.findAllByTestId('application-card');
  const findCardAt = (i) => findCards().at(i);

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(ApplicationsList, {
      propsData: {
        applications: [],
        ...props,
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
      id: 'app-1',
      name: 'Alpha',
      description: 'First app',
      group: { id: 'group-1', name: 'Group A' },
      updatedAt: '2020-07-01T00:00:00Z',
    });
    const app2 = makeApplication({
      id: 'app-2',
      name: 'Beta',
      description: 'Second app',
      group: { id: 'group-2', name: 'Group B' },
      updatedAt: '2020-04-01T00:00:00Z',
    });

    beforeEach(() => {
      createComponent({ applications: [app1, app2] });
    });

    it('renders one card per application', () => {
      expect(findCards()).toHaveLength(2);
    });

    it('renders the application name', () => {
      expect(findCardAt(0).find('h2').text()).toBe('Alpha');
      expect(findCardAt(1).find('h2').text()).toBe('Beta');
    });

    it('renders the group name', () => {
      expect(findCardAt(0).find('span').text()).toBe('Group A');
      expect(findCardAt(1).find('span').text()).toBe('Group B');
    });

    it('renders the application description', () => {
      expect(findCardAt(0).find('p').text()).toBe('First app');
      expect(findCardAt(1).find('p').text()).toBe('Second app');
    });

    it('renders the formatted updated-at time', () => {
      expect(findCardAt(0).text()).toContain('5 days ago');
      expect(findCardAt(1).text()).toContain('3 months ago');
    });
  });
});
