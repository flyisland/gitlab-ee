import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import Banner from 'jh/groups/trials/components/trial_banner.vue';

describe('Trials banner', () => {
  let wrapper;
  const trialPath = 'https://jihulab.com/trial';
  const exploreOptionsPath = 'https://jihulab.com/exlpore_options';
  const createComponent = () => {
    wrapper = shallowMount(Banner, {
      propsData: {
        trialPath,
        exploreOptionsPath,
      },
    });
  };
  const findCtaButtons = () => wrapper.findAllComponents(GlButton);

  beforeEach(() => {
    createComponent();
  });

  it('renders the banner correctly', () => {
    const buttons = findCtaButtons();

    expect(buttons.at(0).attributes('href')).toBe(trialPath);
    expect(buttons.at(1).attributes('href')).toBe(exploreOptionsPath);
  });
});
