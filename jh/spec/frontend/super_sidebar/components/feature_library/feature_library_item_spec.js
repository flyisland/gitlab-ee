import { mountExtended } from 'helpers/vue_test_utils_helper';
import FeatureLibraryItem from '~/super_sidebar/components/feature_library/feature_library_item.vue';
import 'jh/super_sidebar/feature_library_overrides';

describe('FeatureLibraryItem tiers in JH', () => {
  let wrapper;

  it.each([
    ['team', 'Team'],
    ['premium', 'Premium'],
    ['ultimate', 'Ultimate'],
    ['add_on', 'Add-on'],
    ['free', 'Free'],
    [undefined, 'Free'],
  ])('renders %s as %s', (tier, label) => {
    wrapper = mountExtended(FeatureLibraryItem, {
      propsData: {
        item: {
          id: 'iterations',
          title: 'Iterations',
          description: 'Plan sprints',
          icon: 'iteration',
          link: '/groups/example/-/iterations',
          tier,
        },
      },
    });

    expect(wrapper.findByTestId('feature-library-item-tier').text()).toBe(label);
  });
});
