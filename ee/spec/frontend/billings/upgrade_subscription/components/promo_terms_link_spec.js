import { GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { PROMO_URL } from '~/constants';
import PromoTermsLink from 'ee/billings/upgrade_subscription/components/promo_terms_link.vue';

describe('PromoTermsLink component', () => {
  let wrapper;

  const defaultHref = `${PROMO_URL}/pricing/#promo-terms`;

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(PromoTermsLink, {
      propsData: {
        href: defaultHref,
        ...props,
      },
      stubs: {
        GlSprintf,
      },
    });
  };

  const findLink = () => wrapper.findComponent(GlLink);

  beforeEach(() => {
    createComponent();
  });

  it('renders the promo terms text', () => {
    expect(wrapper.text()).toContain('Limited time offer');
    expect(wrapper.text()).toContain('See details and promo terms.');
  });

  it('renders the correct link with the correct href and target', () => {
    const link = findLink();

    expect(link.attributes('href')).toBe(defaultHref);
    expect(link.attributes('target')).toBe('_blank');
    expect(link.attributes('variant')).toBe('inline');
  });
});
