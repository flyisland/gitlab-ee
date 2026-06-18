import { GlButton, GlEmptyState } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import EnvironmentList from 'ee/cd/components/environment_list.vue';

describe('EnvironmentList', () => {
  let wrapper;

  const findEmptyState = () => wrapper.findComponent(GlEmptyState);
  const findRegisterButton = () => wrapper.findComponent(GlButton);
  const findRegisterFirstButton = () => wrapper.findByTestId('register-first-environment-button');

  beforeEach(() => {
    wrapper = mountExtended(EnvironmentList);
  });

  describe('empty state', () => {
    it('renders the title and description', () => {
      expect(findEmptyState().props('title')).toBe('Get started with environments');
      expect(findEmptyState().props('description')).toBe(
        'Environments are places where code gets deployed, such as staging or production.',
      );
    });

    it('renders the illustration', () => {
      expect(findEmptyState().props('svgPath')).toBe('file-mock');
    });
  });

  describe('register button', () => {
    it('renders the "Register your first environment" button in the actions slot', () => {
      expect(findRegisterFirstButton().text()).toBe('Register your first environment');
    });

    it('uses the confirm variant', () => {
      expect(findRegisterButton().props('variant')).toBe('confirm');
    });
  });
});
