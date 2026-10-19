import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AdminGroupsWarnings from 'ee/orbit/settings/admin/admin_groups_warnings.vue';

describe('AdminGroupsWarnings', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(AdminGroupsWarnings, { propsData: props });
  };

  const findIndexStatusError = () => wrapper.findByTestId('orbit-index-status-error');
  const findExcludedError = () => wrapper.findByTestId('orbit-excluded-error');

  describe('with no errors', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders no warning', () => {
      expect(findIndexStatusError().exists()).toBe(false);
      expect(findExcludedError().exists()).toBe(false);
    });
  });

  describe('with an index status error', () => {
    beforeEach(() => {
      createComponent({ indexStatusError: 'Knowledge graph request failed' });
    });

    it('shows the server message and the hint to turn Orbit on or off', () => {
      expect(findIndexStatusError().text()).toContain('Knowledge graph request failed');
      expect(findIndexStatusError().text()).toContain('You can still turn Orbit on or off.');
      expect(findExcludedError().exists()).toBe(false);
    });
  });

  describe('with an excluded groups error', () => {
    beforeEach(() => {
      createComponent({ excludedGroupsError: 'Something went wrong on the server. Try again.' });
    });

    it('shows the excluded groups warning only, with why bulk actions wait', () => {
      expect(findExcludedError().text()).toContain('Something went wrong on the server');
      expect(findExcludedError().text()).toContain(
        'Bulk actions are not available until the excluded groups load.',
      );
      expect(findIndexStatusError().exists()).toBe(false);
    });
  });
});
