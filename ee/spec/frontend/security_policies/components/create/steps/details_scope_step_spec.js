import { shallowMount } from '@vue/test-utils';
import { GlButton, GlFormInput, GlFormTextarea } from '@gitlab/ui';
import DetailsScopeStep from 'ee/security_policies/components/create/steps/details_scope_step.vue';
import EnforcementModeSelector from 'ee/security_policies/components/create/enforcement_mode_selector.vue';

describe('DetailsScopeStep', () => {
  let wrapper;

  const defaultValue = {
    name: '',
    description: '',
    enforcementMode: 'audit',
    scope: 'all',
  };

  const createComponent = ({ value = defaultValue, projectCount = 5 } = {}) => {
    wrapper = shallowMount(DetailsScopeStep, {
      propsData: { value, projectCount },
    });
  };

  const findNameInput = () => wrapper.findComponent(GlFormInput);
  const findDescriptionTextarea = () => wrapper.findComponent(GlFormTextarea);
  const findEnforcementSelector = () => wrapper.findComponent(EnforcementModeSelector);
  const findButtons = () => wrapper.findAllComponents(GlButton);
  const findNextButton = () => findButtons().wrappers.find((w) => w.text() === 'Next');
  const findCancelButton = () => findButtons().wrappers.find((w) => w.text() === 'Cancel');
  const findScopeButtons = () =>
    findButtons().wrappers.filter(
      (w) => w.text().includes('All projects') || w.text().includes('Targeted'),
    );

  it('renders policy name input, description textarea, enforcement mode selector, scope buttons', () => {
    createComponent();

    expect(findNameInput().exists()).toBe(true);
    expect(findDescriptionTextarea().exists()).toBe(true);
    expect(findEnforcementSelector().exists()).toBe(true);
    expect(findScopeButtons()).toHaveLength(2);
  });

  it('Next button is disabled when name is empty', () => {
    createComponent();

    expect(findNextButton().props('disabled')).toBe(true);
  });

  it('Next button is enabled when name is provided', () => {
    createComponent({ value: { ...defaultValue, name: 'My Policy' } });

    expect(findNextButton().props('disabled')).toBe(false);
  });

  it('emits input with updated name when name field changes', () => {
    createComponent();

    findNameInput().vm.$emit('input', 'New Name');

    expect(wrapper.emitted('input')[0][0]).toEqual(expect.objectContaining({ name: 'New Name' }));
  });

  it('emits next when Next button is clicked with valid name', () => {
    createComponent({ value: { ...defaultValue, name: 'Valid' } });

    findNextButton().vm.$emit('click');

    expect(wrapper.emitted('next')).toBeDefined();
  });

  it('emits cancel when Cancel button is clicked', () => {
    createComponent();

    findCancelButton().vm.$emit('click');

    expect(wrapper.emitted('cancel')).toBeDefined();
  });

  it('shows "All projects" helper text when scope is all', () => {
    createComponent({ value: { ...defaultValue, scope: 'all' }, projectCount: 5 });

    expect(wrapper.text().replace(/\s+/g, ' ')).toContain(
      'Applies to all 5 projects in this namespace',
    );
  });
});
