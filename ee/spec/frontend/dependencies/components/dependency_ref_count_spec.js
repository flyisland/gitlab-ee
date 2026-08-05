import { GlCollapsibleListbox, GlIcon, GlTruncate } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import DependencyRefCount from 'ee/dependencies/components/dependency_ref_count.vue';

const MOCK_TRACKED_REFS = [
  { id: 'gid://gitlab/Security::TrackedRef/1', name: 'main', refType: 'BRANCH' },
  { id: 'gid://gitlab/Security::TrackedRef/2', name: 'v1.0.0', refType: 'TAG' },
  { id: 'gid://gitlab/Security::TrackedRef/3', name: 'release/18.8', refType: 'BRANCH' },
];

describe('DependencyRefCount component', () => {
  let wrapper;

  const createComponent = ({ propsData, stubs = {} } = {}) => {
    wrapper = shallowMountExtended(DependencyRefCount, {
      propsData: {
        trackedRefsCount: 3,
        componentId: 1,
        ...propsData,
      },
      stubs,
    });
  };

  const findRefCount = () => wrapper.findByTestId('ref-count');
  const findRefCountText = () => wrapper.findByTestId('ref-count-text');
  const findListbox = () => wrapper.findComponent(GlCollapsibleListbox);
  const findIcons = () => wrapper.findAllComponents(GlIcon);
  const findTruncates = () => wrapper.findAllComponents(GlTruncate);

  const openDropdown = async () => {
    findListbox().vm.$emit('shown');
    await waitForPromises();
  };

  it('renders the ref count', () => {
    createComponent();

    expect(findRefCount().exists()).toBe(true);
  });

  it.each`
    trackedRefsCount | text
    ${1}             | ${'1 ref'}
    ${3}             | ${'3 refs'}
  `('renders "$text" when trackedRefsCount is $trackedRefsCount', ({ trackedRefsCount, text }) => {
    createComponent({ propsData: { trackedRefsCount } });

    expect(findRefCountText().text()).toBe(text);
  });

  describe('dropdown', () => {
    it('renders a listbox with the count as header', () => {
      createComponent();

      expect(findListbox().props()).toMatchObject({
        headerText: '3 refs',
        items: [],
      });
    });

    it('starts in the loading state', () => {
      createComponent();

      expect(findListbox().props()).toMatchObject({
        searching: true,
        searchable: true,
      });
    });

    describe('when opened', () => {
      it('renders the fetched refs once loaded', async () => {
        createComponent();

        await openDropdown();

        expect(findListbox().props()).toMatchObject({
          searching: false,
          searchable: false,
        });
        expect(findListbox().props('items')).toHaveLength(MOCK_TRACKED_REFS.length);
        expect(findListbox().props('items')[0]).toMatchObject({
          value: MOCK_TRACKED_REFS[0].id,
          text: MOCK_TRACKED_REFS[0].name,
        });
      });

      it('does not render a search input', async () => {
        createComponent();

        await openDropdown();

        expect(findListbox().props('searchable')).toBe(false);
      });

      describe('list items', () => {
        beforeEach(async () => {
          createComponent({ stubs: { GlCollapsibleListbox } });
          await openDropdown();
        });

        it('renders correct icon based on refType', () => {
          const [branchRef, tagRef] = MOCK_TRACKED_REFS;

          expect(findIcons().at(0).props('name')).toBe(branchRef.refType.toLowerCase());
          expect(findIcons().at(1).props('name')).toBe(tagRef.refType.toLowerCase());
        });

        it('renders the ref name', () => {
          expect(findTruncates().at(0).props('text')).toBe(MOCK_TRACKED_REFS[0].name);
        });
      });
    });
  });
});
