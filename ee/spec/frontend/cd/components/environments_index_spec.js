import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import EnvironmentsIndex from 'ee/cd/components/environments_index.vue';
import EnvironmentList from 'ee/cd/components/environment_list.vue';
import FilterBar from 'ee/cd/components/shared/filter_bar.vue';
import PageHeading from '~/vue_shared/components/page_heading.vue';

describe('EnvironmentsIndex', () => {
  let wrapper;

  const findPageHeading = () => wrapper.findComponent(PageHeading);
  const findFilterBar = () => wrapper.findComponent(FilterBar);
  const findEnvironmentList = () => wrapper.findComponent(EnvironmentList);
  const findRegisterButton = () => wrapper.findByTestId('register-environment-button');

  beforeEach(() => {
    wrapper = shallowMountExtended(EnvironmentsIndex);
  });

  describe('page heading', () => {
    it('renders the Environments title', () => {
      expect(findPageHeading().props('heading')).toBe('Environments');
    });

    it('renders the Register environment button', () => {
      const button = findRegisterButton();

      expect(button.text()).toBe('Register environment');
      expect(button.props('variant')).toBe('confirm');
    });
  });

  describe('filter bar', () => {
    it('renders the filter bar', () => {
      expect(findFilterBar().exists()).toBe(true);
    });

    it('passes the environment status filters to the filter bar', () => {
      expect(findFilterBar().props('filters')).toEqual([
        { id: 'ALL', text: 'All types' },
        { id: 'PRODUCTION', text: 'Production' },
        { id: 'STAGING', text: 'Staging' },
      ]);
    });
  });

  describe('environment list', () => {
    it('renders the environment list', () => {
      expect(findEnvironmentList().exists()).toBe(true);
    });
  });
});
