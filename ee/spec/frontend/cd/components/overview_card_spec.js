import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import OverviewCard from 'ee/cd/components/overview_card.vue';

describe('OverviewCard', () => {
  let wrapper;

  const findCollapsedCard = () => wrapper.findByTestId('overview-card-collapsed');
  const findExpandedCard = () => wrapper.findByTestId('overview-card-expanded');
  const findExpandButton = () => wrapper.findByTestId('expand-button');
  const findCollapseButton = () => wrapper.findByTestId('collapse-button');
  const findContent = () => wrapper.findByTestId('card-content');
  const findTitle = () => wrapper.find('h3');

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(OverviewCard, {
      propsData: {
        title: 'Services',
        expanded: false,
        expandAriaLabel: 'Expand services',
        collapseAriaLabel: 'Collapse services',
        ...props,
      },
      slots: {
        default: '<div data-testid="card-content">body</div>',
      },
    });
  };

  it('renders the title and slot content', () => {
    createComponent();

    expect(findTitle().text()).toBe('Services');
    expect(findContent().exists()).toBe(true);
  });

  describe('when collapsed', () => {
    beforeEach(() => {
      createComponent({ expanded: false });
    });

    it('renders the collapsed card that stacks on mobile and shares the row from sm up', () => {
      expect(findCollapsedCard().exists()).toBe(true);
      expect(findExpandedCard().exists()).toBe(false);
      expect(findCollapsedCard().classes()).toEqual(
        expect.arrayContaining(['gl-grow', 'gl-basis-full', 'sm:gl-basis-0']),
      );
    });

    it('renders the expand button and emits toggle on click', () => {
      expect(findExpandButton().exists()).toBe(true);

      findExpandButton().vm.$emit('click');

      expect(wrapper.emitted('toggle')).toHaveLength(1);
    });
  });

  describe('when expanded', () => {
    beforeEach(() => {
      createComponent({ expanded: true });
    });

    it('renders the expanded card spanning a full row', () => {
      expect(findExpandedCard().exists()).toBe(true);
      expect(findCollapsedCard().exists()).toBe(false);
      expect(findExpandedCard().classes()).toContain('gl-basis-full');
    });

    it('renders the collapse button and emits toggle on click', () => {
      expect(findCollapseButton().exists()).toBe(true);

      findCollapseButton().vm.$emit('click');

      expect(wrapper.emitted('toggle')).toHaveLength(1);
    });
  });
});
