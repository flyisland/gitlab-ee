import { GlButton, GlIcon, GlModal } from '@gitlab/ui';
import { nextTick } from 'vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import WorkItemTypesCustomization from 'ee/work_items/components/work_item_types_customization.vue';

describe('WorkItemTypesCustomization component', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMountExtended(WorkItemTypesCustomization);
  };

  const findHeading = () => wrapper.find('h3');
  const findButton = () => wrapper.findComponent(GlButton);
  const findIcon = () => wrapper.findComponent(GlIcon);
  const findModal = () => wrapper.findComponent(GlModal);
  const findStatusBlock = () => wrapper.findByTestId('status-block');

  beforeEach(() => {
    createComponent();
  });

  it('renders heading and text', () => {
    expect(findHeading().text()).toBe('Type customization in projects');
    expect(wrapper.text()).toContain('Allow types to be disabled in projects.');
  });

  it('renders initial state', () => {
    expect(findIcon().props('name')).toBe('cancel');
    expect(findStatusBlock().text()).toContain('Disabled');
    expect(findStatusBlock().classes()).toContain('gl-text-danger');
    expect(findButton().text()).toBe('Enable');
  });

  it('enables customization', async () => {
    findButton().vm.$emit('click');
    await nextTick();

    expect(findIcon().props('name')).toBe('check');
    expect(findStatusBlock().text()).toContain('Enabled');
    expect(findStatusBlock().classes()).toContain('gl-text-success');
    expect(findButton().text()).toBe('Disable');
  });

  it('disables customization', async () => {
    findButton().vm.$emit('click');
    await nextTick();
    findButton().vm.$emit('click');
    await nextTick();

    expect(findStatusBlock().text()).toContain('Enabled');
    expect(findModal().props('title')).toBe('Disable type customization in projects');
    expect(findModal().text()).toBe(
      'All available types will be enabled in all groups and projects. Re-enabling this setting later will return each group or project to its current configuration.',
    );

    findModal().vm.$emit('primary');
    await nextTick();

    expect(findStatusBlock().text()).toContain('Disabled');
  });
});
